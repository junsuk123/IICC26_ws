function autosimCleanupGazebo()
% autosimCleanupGazebo
% Comprehensive cleanup of Gazebo, ROS, and all related processes.
% Prevents port conflicts, orphaned processes, and ROS node zombies.

    fprintf('[AUTOSIM] ===== COMPREHENSIVE PRE-STARTUP CLEANUP =====\n');
    
    % Phase 1: Kill all Gazebo process instances (most aggressive)
    fprintf('[AUTOSIM] Phase 1: Gazebo processes...\n');
    try
        system('pkill -9 gzserver 2>/dev/null || true');
        system('pkill -9 gzclient 2>/dev/null || true');
        system('pkill -9 -f "gazebo.*server" 2>/dev/null || true');
        system('pkill -9 -f "gazebo.*client" 2>/dev/null || true');
        fprintf('[AUTOSIM]   ✓ Killed all Gazebo processes\n');
    catch
        warning('[AUTOSIM] Phase 1 partial failure (pkill may not be available)');
    end
    pause(0.5);
    
    % Phase 2: Kill ROS-related Python and C++ nodes
    fprintf('[AUTOSIM] Phase 2: ROS/RViz nodes...\n');
    try
        % Kill ROS 2 daemon
        system('pkill -9 -f "ros2_daemon" 2>/dev/null || true');
        system('pkill -9 -f "ros2/daemon" 2>/dev/null || true');
        
        % Kill RViz processes
        system('pkill -9 -f "rviz" 2>/dev/null || true');
        system('pkill -9 rviz2 2>/dev/null || true');
        
        % Kill Python ROS nodes (multi_drone_command_fanout, apriltag, etc)
        system('pkill -9 -f "ros2 run" 2>/dev/null || true');
        system('pkill -9 -f "multi_drone_command_fanout" 2>/dev/null || true');
        system('pkill -9 -f "apriltag" 2>/dev/null || true');
        
        % Kill any remaining Python3 ROS nodes
        system('pkill -9 -f "python3.*ros" 2>/dev/null || true');
        
        fprintf('[AUTOSIM]   ✓ Killed all ROS/RViz nodes\n');
    catch
        warning('[AUTOSIM] Phase 2 partial failure');
    end
    pause(0.5);
    
    % Phase 3: Kill joy_node and teleop processes
    fprintf('[AUTOSIM] Phase 3: Input/Control nodes...\n');
    try
        system('pkill -9 joy_node 2>/dev/null || true');
        system('pkill -9 -f "teleop" 2>/dev/null || true');
        system('pkill -9 -f "joy" 2>/dev/null || true');
        fprintf('[AUTOSIM]   ✓ Killed input/control nodes\n');
    catch
    end
    pause(0.5);
    
    % Phase 4: Wait and verify port cleanup
    fprintf('[AUTOSIM] Phase 4: Port verification...\n');
    pause(1.5);
    
    % Check multiple Gazebo ports (11345 is default, but can vary)
    gazebo_ports = [11345, 11346, 11347, 11348, 13000:14000];
    cleanup_retry_count = 0;
    max_retries = 2;
    
    while cleanup_retry_count < max_retries
        ports_in_use = [];
        for port = gazebo_ports(1:4)  % Check first 4 common ports
            try
                [st, ~] = system(sprintf('lsof -i :%d 2>/dev/null', port));
                if st == 0
                    ports_in_use = [ports_in_use, port];
                end
            catch
            end
        end
        
        if ~isempty(ports_in_use)
            fprintf('[AUTOSIM]   - Ports still in use: %s\n', sprintf('%d ', ports_in_use));
            if cleanup_retry_count < max_retries - 1
                fprintf('[AUTOSIM]   - Retrying aggressive kill...\n');
                system('pkill -9 -f gazebo 2>/dev/null || true');
                system('pkill -9 -f gzserver 2>/dev/null || true');
                system('pkill -9 -f gzclient 2>/dev/null || true');
                pause(2.0);
                cleanup_retry_count = cleanup_retry_count + 1;
            else
                fprintf('[AUTOSIM]   - Warning: Some ports still in use, proceeding anyway\n');
                break;
            end
        else
            fprintf('[AUTOSIM]   ✓ All Gazebo ports are free\n');
            break;
        end
    end
    
    % Phase 5: ROS environment cleanup (clear stale node information)
    fprintf('[AUTOSIM] Phase 5: ROS environment...\n');
    try
        % Clear ROS daemon data
        system('ros2 daemon stop 2>/dev/null || true');
        pause(0.5);
        system('rm -rf ~/.ros/latest_run 2>/dev/null || true');
        fprintf('[AUTOSIM]   ✓ ROS environment cleaned\n');
    catch
        % Silent fail
    end
    
    % Phase 6: Gazebo cache cleanup
    fprintf('[AUTOSIM] Phase 6: Gazebo cache...\n');
    try
        system('rm -rf ~/.gazebo/client_* 2>/dev/null || true');
        fprintf('[AUTOSIM]   ✓ Gazebo cache cleared\n');
    catch
    end
    
    fprintf('[AUTOSIM] ===== CLEANUP COMPLETE =====\n');
    fprintf('[AUTOSIM] Ready to start fresh simulation.\n\n');
    
end
