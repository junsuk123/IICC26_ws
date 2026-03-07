#!/usr/bin/env python3
"""Simple ROS2 wind publisher (Python)

Publishes a near-surface wind vector to /environment/wind (geometry_msgs/Vector3)
and a legacy /wind_condition (std_msgs/Float32MultiArray [speed, direction_deg]).

Model: steady mean + power-law shear + AR(1) turbulence + intermittent gusts + slow direction variation

Usage:
  source /opt/ros/<distro>/setup.bash
  python3 scripts/wind_publisher_py.py --rate 10

This is provided as a quick fallback when MATLAB-based publisher is not running.
"""
import math
import time
import random
import argparse

try:
    import rclpy
    from rclpy.node import Node
    from geometry_msgs.msg import Vector3
    from std_msgs.msg import Float32MultiArray
except Exception as e:
    raise RuntimeError('rclpy or ROS2 Python packages not available: %s' % e)


class WindPublisher(Node):
    def __init__(self, rate_hz=10, base_mean=4.0, height=10.0, shear_exp=0.14,
                 ti=0.2, gust_rate_per_min=1.0):
        super().__init__('py_wind_publisher')
        self.rate = rate_hz
        self.dt = 1.0 / float(rate_hz)
        self.base_mean = base_mean
        self.z_ref = 10.0
        self.height = height
        self.shear_exp = shear_exp
        self.ti = ti
        self.gust_rate_per_sec = gust_rate_per_min / 60.0

        self.pub_vec = self.create_publisher(Vector3, '/environment/wind', 10)
    self.pub_arr = self.create_publisher(Float32MultiArray, '/wind_condition', 10)
    self.pub_cmd = self.create_publisher(Float32MultiArray, '/wind_command', 10)

        # turbulence AR(1)
        fc_turb = 0.3
        self.turba = math.exp(-2.0 * math.pi * fc_turb * self.dt)
        self.turb_b = math.sqrt(max(0.0, 1.0 - self.turba * self.turba))

        self.u_turb_prev = 0.0
        self.v_turb_prev = 0.0
        self.w_turb_prev = 0.0

        self.wind_dir = 0.0  # radians
        self.dir_a = math.exp(-2.0 * math.pi * 0.01 * self.dt)
        self.dir_sigma = 0.3

        self.gust_amp_mean = 3.0
        self.gust_amp_std = 1.5
        self.gust_tau = 4.0
        self.active_gusts = []

        self.timer = self.create_timer(self.dt, self.timer_cb)

    def timer_cb(self):
        # diurnal small term
        t = time.time()
        diurnal = 1.2 * math.sin(2.0 * math.pi * (t / 86400.0))
        mean_speed_ref = max(0.0, self.base_mean + diurnal)

        # shear
        if self.height > 0:
            mean_speed = mean_speed_ref * (self.height / self.z_ref) ** self.shear_exp
        else:
            mean_speed = mean_speed_ref

        # wind direction lowpass random walk
        dir_noise = self.dir_sigma * math.sqrt(1 - self.dir_a * self.dir_a) * random.gauss(0, 1)
        self.wind_dir = self.dir_a * self.wind_dir + dir_noise

        u_mean = -mean_speed * math.cos(self.wind_dir)
        v_mean = -mean_speed * math.sin(self.wind_dir)

        # turbulence
        sigma_u = max(0.01, self.ti * mean_speed)
        sigma_v = 0.8 * sigma_u
        sigma_w = 0.5 * sigma_u

        u_turb = self.turba * self.u_turb_prev + self.turb_b * sigma_u * random.gauss(0, 1)
        v_turb = self.turba * self.v_turb_prev + self.turb_b * sigma_v * random.gauss(0, 1)
        w_turb = self.turba * self.w_turb_prev + self.turb_b * sigma_w * random.gauss(0, 1)
        self.u_turb_prev = u_turb
        self.v_turb_prev = v_turb
        self.w_turb_prev = w_turb

        # gust arrivals
        if random.random() < self.gust_rate_per_sec * self.dt:
            amp = max(0.0, random.gauss(self.gust_amp_mean, self.gust_amp_std))
            gdir = self.wind_dir + random.gauss(0, 0.3)
            self.active_gusts.append({'t0': time.time(), 'amp': amp, 'dir': gdir})

        gust_u = 0.0
        gust_v = 0.0
        now = time.time()
        keep = []
        for g in self.active_gusts:
            age = now - g['t0']
            if age < 6.0 * self.gust_tau:
                gval = g['amp'] * math.exp(-0.5 * (age / self.gust_tau) ** 2)
                gust_u += -gval * math.cos(g['dir'])
                gust_v += -gval * math.sin(g['dir'])
                keep.append(g)
        self.active_gusts = keep

        u = u_mean + u_turb + gust_u
        v = v_mean + v_turb + gust_v
        w = w_turb

        # publish Vector3
        vec = Vector3()
        vec.x = float(u)
        vec.y = float(v)
        vec.z = float(w)
        self.pub_vec.publish(vec)

    # publish Float32MultiArray [speed, direction_deg]
    spd = math.sqrt(u * u + v * v)
    dir_rad = math.atan2(v, u)
    dir_deg = (math.degrees(dir_rad) + 360.0) % 360.0
    arr = Float32MultiArray()
    arr.data = [float(spd), float(dir_deg)]
    self.pub_arr.publish(arr)
    # also publish command for gazebo plugin
    cmd = Float32MultiArray()
    cmd.data = [float(spd), float(dir_deg)]
    self.pub_cmd.publish(cmd)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--rate', type=float, default=10.0)
    parser.add_argument('--base_mean', type=float, default=4.0)
    parser.add_argument('--height', type=float, default=10.0)
    parser.add_argument('--ti', type=float, default=0.2)
    parser.add_argument('--gust_rate', type=float, default=1.0, help='gusts per minute')
    args = parser.parse_args()

    rclpy.init()
    node = WindPublisher(rate_hz=args.rate, base_mean=args.base_mean, height=args.height, ti=args.ti, gust_rate_per_min=args.gust_rate)
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
