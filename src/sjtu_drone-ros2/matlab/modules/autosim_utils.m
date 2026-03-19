function varargout = autosim_utils(action, varargin)
% autosim_utils
% Shared utility helpers extracted for modular reuse.

switch lower(string(action))
    case "clamp"
        varargout{1} = clamp(varargin{1}, varargin{2}, varargin{3});
    case "clampnan"
        varargout{1} = clamp_nan(varargin{1}, varargin{2});
    case "nanmean"
        varargout{1} = nan_mean(varargin{1});
    case "nanstd"
        varargout{1} = nan_std(varargin{1});
    case "nanmax"
        varargout{1} = nan_max(varargin{1});
    case "tail"
        varargout{1} = tail(varargin{1}, varargin{2});
    case "safediv"
        varargout{1} = safe_div(varargin{1}, varargin{2});
    otherwise
        error("autosim_utils:unknownAction", "Unknown action: %s", string(action));
end
end

function y = clamp(x, lo, hi)
if ~isfinite(lo)
    lo = -inf;
end
if ~isfinite(hi)
    hi = inf;
end
y = min(max(x, lo), hi);
end

function y = clamp_nan(x, fallback)
if isfinite(x)
    y = x;
else
    y = fallback;
end
end

function v = nan_mean(x)
x = double(x(:));
x = x(isfinite(x));
if isempty(x)
    v = nan;
else
    v = mean(x);
end
end

function v = nan_std(x)
x = double(x(:));
x = x(isfinite(x));
if numel(x) <= 1
    v = 0.0;
else
    v = std(x);
end
end

function v = nan_max(x)
x = double(x(:));
x = x(isfinite(x));
if isempty(x)
    v = nan;
else
    v = max(x);
end
end

function out = tail(x, n)
x = x(:);
if nargin < 2 || ~isfinite(n)
    n = numel(x);
end
n = max(0, floor(n));
if n == 0
    out = x([]);
elseif numel(x) <= n
    out = x;
else
    out = x(end-n+1:end);
end
end

function v = safe_div(num, den)
if ~isfinite(den) || abs(den) < 1e-12
    v = 0.0;
else
    v = num / den;
end
end
