#!/usr/bin/env python3
"""
wind_tuner.py

Automated experiment runner that sweeps wind plugin parameters by creating
temporary world files, launching `gzserver` with each world, and recording
`/wind_condition` topic messages for a fixed duration.

Usage (after sourcing ROS2 and workspace install/setup.bash):

  python3 scripts/wind_tuner.py \
    --world src/sjtu_drone_description/worlds/playground.world \
    --area 0.1 0.2 0.5 \
    --coeff 0.5 1.0 2.0 \
    --speed 2.0 5.0 \
    --dir 0 90 180 \
    --duration 15 \
    --out results

Requirements:
- `gzserver` (Gazebo) available in PATH
- ROS2 environment sourced (so `rclpy` is importable and `/wind_condition` topic is available)

This script intentionally keeps the experiment logic simple: it records the
wind topic published by the world plugin and writes CSV logs per-experiment.
"""

import argparse
import csv
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import threading
import time
from datetime import datetime

# try importing rclpy; if not available, we still write worlds but cannot record
try:
    import rclpy
    from rclpy.node import Node
    from std_msgs.msg import Float32MultiArray
    RCLPY_AVAILABLE = True
except Exception:
    RCLPY_AVAILABLE = False


class WindRecorder(Node):
    def __init__(self, topic_name='/wind_condition'):
        super().__init__('wind_tuner_recorder')
        self.sub = self.create_subscription(Float32MultiArray, topic_name, self.cb, 10)
        self.msgs = []
        self.lock = threading.Lock()

    def cb(self, msg):
        with self.lock:
            now = self.get_clock().now().to_msg()
            ts = now.sec + now.nanosec * 1e-9
            self.msgs.append((ts, list(msg.data)))

    def pop_msgs(self):
        with self.lock:
            m = list(self.msgs)
            self.msgs.clear()
            return m


def generate_world_with_plugin(orig_world_path, out_world_path, params):
    """Copy original world and insert plugin block before closing </world> tag.
    params is a dict with keys: wind_speed, wind_direction, area, force_coeff, publish_rate_hz
    """
    with open(orig_world_path, 'r') as f:
        content = f.read()

    plugin_block = f"""
  <plugin name=\"wind_plugin\" filename=\"libwind_plugin.so\">
    <wind_speed>{params['wind_speed']}</wind_speed>
    <wind_direction>{params['wind_direction']}</wind_direction>
    <area>{params['area']}</area>
    <force_coeff>{params['force_coeff']}</force_coeff>
    <publish_rate_hz>{params.get('publish_rate_hz',10.0)}</publish_rate_hz>
  </plugin>
"""
    if '</world>' in content:
        content = content.replace('</world>', plugin_block + '\n</world>')
    else:
        # append at end if no closing tag found
        content = content + '\n' + plugin_block

    with open(out_world_path, 'w') as f:
        f.write(content)


def run_experiment(world_path, duration, out_dir, label):
    """Launch gzserver with world_path, record `/wind_condition` for duration seconds.
    Returns path to saved CSV (or None if no data)."""

    print(f'[{label}] Starting gzserver with world: {world_path}')
    # Start gzserver
    proc = subprocess.Popen(['gzserver', world_path], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    recorder = None
    csv_path = None

    try:
        if RCLPY_AVAILABLE:
            print(f'[{label}] Initializing rclpy to subscribe to /wind_condition')
            rclpy.init(args=None)
            recorder = WindRecorder()
            start_t = time.time()
            # spin and collect messages until duration elapsed
            while time.time() - start_t < duration:
                rclpy.spin_once(recorder, timeout_sec=0.1)
        else:
            # fallback: just wait if rclpy not available
            print(f'[{label}] rclpy not available; sleeping for {duration} seconds')
            time.sleep(duration)

        # get messages
        if recorder is not None:
            msgs = recorder.pop_msgs()
            if msgs:
                csv_path = os.path.join(out_dir, f'{label}_wind.csv')
                with open(csv_path, 'w', newline='') as csvfile:
                    writer = csv.writer(csvfile)
                    writer.writerow(['timestamp', 'wind_speed', 'wind_direction'])
                    for ts, data in msgs:
                        # data expected length >=2
                        ws = data[0] if len(data) > 0 else ''
                        wd = data[1] if len(data) > 1 else ''
                        writer.writerow([ts, ws, wd])
                print(f'[{label}] Saved {len(msgs)} messages to {csv_path}')
            else:
                print(f'[{label}] No messages recorded on /wind_condition')

    finally:
        # teardown recorder
        if recorder is not None:
            try:
                recorder.destroy_node()
                rclpy.shutdown()
            except Exception:
                pass
        # terminate gzserver
        if proc.poll() is None:
            print(f'[{label}] Terminating gzserver (pid {proc.pid})')
            proc.send_signal(signal.SIGINT)
            try:
                proc.wait(timeout=5)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait()
        # collect output
        stdout, stderr = proc.communicate(timeout=1)
        log_path = os.path.join(out_dir, f'{label}_gzserver.log')
        with open(log_path, 'wb') as f:
            f.write(b'--- STDOUT ---\n')
            f.write(stdout or b'')
            f.write(b'\n--- STDERR ---\n')
            f.write(stderr or b'')
        print(f'[{label}] gzserver logs saved to {log_path}')

    return csv_path


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--world', required=True, help='Path to world template')
    p.add_argument('--area', nargs='+', type=float, required=True)
    p.add_argument('--coeff', nargs='+', type=float, required=True)
    p.add_argument('--speed', nargs='+', type=float, required=True)
    p.add_argument('--dir', nargs='+', type=float, required=True)
    p.add_argument('--duration', type=float, default=10.0, help='Seconds to run each simulation')
    p.add_argument('--out', default='wind_tuning_results', help='Output directory to store logs')
    p.add_argument('--publish_rate_hz', type=float, default=10.0)
    args = p.parse_args()

    if not os.path.isfile(args.world):
        print('World template not found:', args.world)
        sys.exit(1)

    os.makedirs(args.out, exist_ok=True)

    combos = []
    for a in args.area:
        for c in args.coeff:
            for s in args.speed:
                for d in args.dir:
                    combos.append({'area': a, 'force_coeff': c, 'wind_speed': s, 'wind_direction': d})

    print(f'Will run {len(combos)} experiments; output -> {args.out}')

    for idx, params in enumerate(combos, start=1):
        label = f'exp_{idx:03d}_a{params["area"]}_c{params["force_coeff"]}_s{params["wind_speed"]}_d{int(params["wind_direction"]) }'
        out_dir = os.path.join(args.out, label)
        os.makedirs(out_dir, exist_ok=True)

        # create temporary world file
        tmp_world = os.path.join(out_dir, f'{label}.world')
        pparams = dict(params)
        pparams['publish_rate_hz'] = args.publish_rate_hz
        generate_world_with_plugin(args.world, tmp_world, pparams)

        # run experiment
        csv = run_experiment(tmp_world, args.duration, out_dir, label)

        print(f'[{label}] done. result_csv={csv}')
        # small pause between experiments
        time.sleep(1)

    print('All experiments finished.')


if __name__ == '__main__':
    main()
