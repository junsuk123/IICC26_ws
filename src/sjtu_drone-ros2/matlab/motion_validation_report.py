#!/usr/bin/env python3
"""
motion_validation_report.py
cmd_vel 로그와 gt_pose 로그를 분석하여,
"진짜 1대만 이동"인지, "4대 모두 이동하지만 크기가 다른지" 판정
"""
import csv
import sys
from pathlib import Path
from collections import defaultdict
import statistics

def load_csv_data(filepath):
    """CSV 파일 로드"""
    data = []
    if not Path(filepath).exists():
        print(f"File not found: {filepath}")
        return data
    
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            data.append(row)
    return data

def analyze_cmd_vel(cmd_vel_file):
    """cmd_vel 데이터 분석"""
    data = load_csv_data(cmd_vel_file)
    if not data:
        print(f"No cmd_vel data found in {cmd_vel_file}")
        return {}
    
    # 드론별로 그룹화
    drone_cmds = defaultdict(list)
    for row in data:
        drone = row['drone_name']
        try:
            vx = float(row['vx'])
            vy = float(row['vy'])
            vz = float(row['vz'])
            drone_cmds[drone].append({'vx': vx, 'vy': vy, 'vz': vz})
        except (ValueError, KeyError):
            continue
    
    # 드론별 통계
    cmd_stats = {}
    for drone, velocities in drone_cmds.items():
        if not velocities:
            continue
        
        vx_vals = [v['vx'] for v in velocities]
        vy_vals = [v['vy'] for v in velocities]
        vz_vals = [v['vz'] for v in velocities]
        
        # 0이 아닌 명령 카운트
        nonzero_vx = sum(1 for v in vx_vals if abs(v) > 0.01)
        nonzero_vy = sum(1 for v in vy_vals if abs(v) > 0.01)
        nonzero_vz = sum(1 for v in vz_vals if abs(v) > 0.01)
        
        cmd_stats[drone] = {
            'total_commands': len(velocities),
            'nonzero_vx': nonzero_vx,
            'nonzero_vy': nonzero_vy,
            'nonzero_vz': nonzero_vz,
            'avg_vx': statistics.mean(vx_vals) if vx_vals else 0,
            'avg_vy': statistics.mean(vy_vals) if vy_vals else 0,
            'avg_vz': statistics.mean(vz_vals) if vz_vals else 0,
            'max_vx': max(vx_vals) if vx_vals else 0,
            'max_vy': max(vy_vals) if vy_vals else 0,
            'max_vz': max(vz_vals) if vz_vals else 0,
        }
    
    return cmd_stats

def analyze_gt_pose(gt_pose_file):
    """gt_pose 데이터 분석"""
    data = load_csv_data(gt_pose_file)
    if not data:
        print(f"No gt_pose data found in {gt_pose_file}")
        return {}
    
    # 드론별로 그룹화
    drone_poses = defaultdict(list)
    for row in data:
        drone = row['drone_name']
        try:
            x = float(row['x'])
            y = float(row['y'])
            z = float(row['z'])
            dx_5sec = float(row['dx_5sec'])
            dy_5sec = float(row['dy_5sec'])
            dxy_mag = float(row['dxy_magnitude'])
            drone_poses[drone].append({
                'x': x, 'y': y, 'z': z,
                'dx_5sec': dx_5sec, 'dy_5sec': dy_5sec,
                'dxy_mag': dxy_mag
            })
        except (ValueError, KeyError):
            continue
    
    # 드론별 통계
    pose_stats = {}
    for drone, poses in drone_poses.items():
        if not poses:
            continue
        
        dxy_mags = [p['dxy_mag'] for p in poses]
        
        # 5초 윈도우에서 이동한 거리가 0이 아닌 관측값
        moved_count = sum(1 for m in dxy_mags if m > 0.01)
        
        pose_stats[drone] = {
            'total_observations': len(poses),
            'moved_count': moved_count,
            'move_ratio': moved_count / len(poses) if poses else 0,
            'avg_dxy_5sec': statistics.mean(dxy_mags) if dxy_mags else 0,
            'max_dxy_5sec': max(dxy_mags) if dxy_mags else 0,
            'min_dxy_5sec': min(dxy_mags) if dxy_mags else 0,
            'total_distance': sum(m for m in dxy_mags),
            'final_x': poses[-1]['x'] if poses else 0,
            'final_y': poses[-1]['y'] if poses else 0,
            'final_z': poses[-1]['z'] if poses else 0,
        }
    
    return pose_stats

def generate_report(cmd_vel_file, gt_pose_file, output_file=None):
    """최종 리포트 생성"""
    print("\n" + "="*80)
    print("  4대 드론 움직임 검증 리포트")
    print("="*80)
    
    print(f"\n📊 입력 데이터:")
    print(f"   cmd_vel:  {cmd_vel_file}")
    print(f"   gt_pose:  {gt_pose_file}")
    
    # 데이터 분석
    cmd_stats = analyze_cmd_vel(cmd_vel_file)
    pose_stats = analyze_gt_pose(gt_pose_file)
    
    if not cmd_stats and not pose_stats:
        print("\n❌ 분석할 데이터가 없습니다.")
        return
    
    # cmd_vel 리포트
    print("\n" + "-"*80)
    print("1️⃣  cmd_vel 명령 분석")
    print("-"*80)
    for drone in sorted(cmd_stats.keys()):
        stats = cmd_stats[drone]
        print(f"\n  [{drone}]")
        print(f"    총 명령: {stats['total_commands']}")
        print(f"    비영 vx: {stats['nonzero_vx']:3d} | 비영 vy: {stats['nonzero_vy']:3d} | 비영 vz: {stats['nonzero_vz']:3d}")
        print(f"    평균: vx={stats['avg_vx']:+.3f}, vy={stats['avg_vy']:+.3f}, vz={stats['avg_vz']:+.3f}")
        print(f"    최대: vx={stats['max_vx']:+.3f}, vy={stats['max_vy']:+.3f}, vz={stats['max_vz']:+.3f}")
    
    # gt_pose 리포트
    print("\n" + "-"*80)
    print("2️⃣  gt_pose 위치 변화 분석 (5초 윈도우)")
    print("-"*80)
    for drone in sorted(pose_stats.keys()):
        stats = pose_stats[drone]
        print(f"\n  [{drone}]")
        print(f"    관측: {stats['total_observations']} | 이동한 관측: {stats['moved_count']}")
        print(f"    이동률: {stats['move_ratio']*100:.1f}%")
        print(f"    5초 평균 dxy: {stats['avg_dxy_5sec']:.4f} m")
        print(f"    5초 최대 dxy: {stats['max_dxy_5sec']:.4f} m")
        print(f"    총 이동거리: {stats['total_distance']:.3f} m")
        print(f"    최종 위치: ({stats['final_x']:.2f}, {stats['final_y']:.2f}, {stats['final_z']:.2f})")
    
    # 최종 판정
    print("\n" + "-"*80)
    print("🎯 최종 판정")
    print("-"*80)
    
    moving_drones = {d: s for d, s in pose_stats.items() if s['total_distance'] > 0.05}
    
    if len(moving_drones) == 0:
        conclusion = "✅ 모든 드론이 내내 정지 상태"
    elif len(moving_drones) == 1:
        moving_drone = list(moving_drones.keys())[0]
        distance = moving_drones[moving_drone]['total_distance']
        conclusion = f"⚠️  진짜 1대만 이동: [{moving_drone}] (이동거리={distance:.3f}m)"
    else:
        # 4대 모두 이동하는 경우, 크기 비교
        distances = {d: s['total_distance'] for d, s in moving_drones.items()}
        min_dist = min(distances.values())
        max_dist = max(distances.values())
        ratio = max_dist / min_dist if min_dist > 0 else 0
        
        print(f"\n  이동 드론 목록:")
        for d in sorted(distances.keys()):
            print(f"    [{d:10s}] 이동거리={distances[d]:.4f} m")
        
        print(f"\n  크기 비교: 최대/최소 = {ratio:.2f}x")
        
        if ratio > 2.0:
            conclusion = f"❌ 4대 모드 이동 중 크기 차이 큼 (비율={ratio:.2f}x)"
        else:
            conclusion = f"✓ 4대 모두 유사한 크기로 이동 (비율={ratio:.2f}x)"
    
    print(f"\n  결론: {conclusion}\n")
    
    # 파일로 저장
    if output_file is None:
        output_file = Path.home() / ".ros" / "motion_validation_report.txt"
    
    with open(output_file, 'w') as f:
        f.write("="*80 + "\n")
        f.write("  4대 드론 움직임 검증 리포트\n")
        f.write("="*80 + "\n")
        f.write(f"\nInput: {cmd_vel_file}\n")
        f.write(f"Input: {gt_pose_file}\n")
        f.write(f"\nConclusion: {conclusion}\n")
    
    print(f"📁 리포트 저장: {output_file}")

def main():
    # 최신 로그 파일 찾기
    log_dir = Path.home() / ".ros"
    
    # cmd_vel 최신 파일
    cmd_vel_files = sorted(log_dir.glob("cmd_vel_logs/cmd_vel_log_*.csv"), reverse=True)
    cmd_vel_file = cmd_vel_files[0] if cmd_vel_files else None
    
    # gt_pose 최신 파일
    gt_pose_files = sorted(log_dir.glob("gt_pose_logs/gt_pose_dxy_log_*.csv"), reverse=True)
    gt_pose_file = gt_pose_files[0] if gt_pose_files else None
    
    if cmd_vel_file is None or gt_pose_file is None:
        print("Error: cmd_vel 또는 gt_pose 로그 파일을 찾을 수 없습니다.")
        print(f"cmd_vel_dir: {log_dir / 'cmd_vel_logs'}")
        print(f"gt_pose_dir: {log_dir / 'gt_pose_logs'}")
        sys.exit(1)
    
    generate_report(str(cmd_vel_file), str(gt_pose_file))

if __name__ == '__main__':
    if len(sys.argv) > 2:
        generate_report(sys.argv[1], sys.argv[2])
    else:
        main()
