function out = autosimGetActiveProcessSnapshot()
    cmd = ['bash -c "' ...
        'pgrep -af \"[r]os2 launch sjtu_drone_bringup|[c]omponent_container|[a]priltag|[j]oint_state_publisher|[r]obot_state_publisher|[s]tatic_transform_publisher|[r]viz2|[j]oy_node|[g]azebo|[g]zserver|[g]zclient|[s]pawn_drone|[g]azebo_wind_plugin_node\" ' ...
        '| sed -n \"1,120p\" || true"'];
    [~, txt] = system(cmd);
    out = autosimTrimSnapshotLines(string(txt), 260);
end

function out = autosimTrimSnapshotLines(in, maxLen)
    lines = splitlines(string(in));
    for i = 1:numel(lines)
        s = lines(i);
        if strlength(s) > maxLen
            lines(i) = extractBefore(s, maxLen) + " ...";
        end
    end
    out = join(lines, newline);
end


