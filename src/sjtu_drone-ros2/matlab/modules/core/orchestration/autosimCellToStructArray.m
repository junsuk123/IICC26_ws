function structArray = autosimCellToStructArray(cellArray)
    % Convert cell array of structs to struct array
    % If cell array is empty, return empty struct array from template
    if isempty(cellArray)
        structArray = repmat(autosimEmptyScenarioResult(), 0, 1);
    else
        structArray = [cellArray{:}]';  % Transpose to get column vector
    end
end
