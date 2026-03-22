function [x, y, z] = autosimComputeSpawnPose(indexOneBased, count, spacingM)
% autosimComputeSpawnPose
% Match Gazebo multi-drone spawn grid to recover each drone's home pad.

idx = max(1, round(double(indexOneBased)));
n = max(1, round(double(count)));
spacing = max(0.1, double(spacingM));

if n <= 3
    cols = n;
else
    cols = ceil(sqrt(double(n)));
end
rows = ceil(double(n) / double(cols));

indexZeroBased = idx - 1;
row = floor(double(indexZeroBased) / double(cols));
col = mod(double(indexZeroBased), double(cols));

xCenter = 0.5 * double(cols - 1);
yCenter = 0.5 * double(rows - 1);

x = (col - xCenter) * spacing;
y = (yCenter - row) * spacing;
z = 0.05;
end
