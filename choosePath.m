function bestPath = choosePath(paths, remainingBW, tickMatrix, tickThreshold)
% Helper for routeDiscoveryPhase - to be used elsewhere
% 
% Inputs
%   paths - nx1 cell arr of paths
%   remainingBW - numNodesx1 arr of available radio BW
%   tickMatrix - numNodesxnumNodes matrix of ticks between drones
%   tickThreshold - the threshold to use in comparison
% 
% Output
%   bestPath - 1x1 cell array containing vector describing the best path
% 
% Test
% tickMatrix = zeros(5,5);
% tickMatrix(1,2) = 9;
% tickMatrix(1,3) = 100;
% remainingBW = 100 * ones(5,1);
% paths = {[1, 2, 5], [1, 3, 5]};
% tickThreshold = 10;
% bestPath = choosePath(paths, remainingBW, tickMatrix, tickThreshold)

% Now choose the best path
numPaths = numel(paths);
numOverloads = zeros(numPaths, 1);
numSteps = zeros(numPaths, 1);
tickScores = zeros(numPaths, 1);

%Capture the important metrics
for ii = 1:numPaths
    thisPath = paths{ii};
    numOverloads(ii) = sum(remainingBW(thisPath) <= 0);
    numSteps(ii) = numel(thisPath);
    tickScores(ii) = getTickScore(thisPath, tickMatrix, tickThreshold);
end

%Downfilter on acceptable paths (no overloads)
acceptablePaths = paths(numOverloads == 0);
numSteps = numSteps(numOverloads == 0);
tickScores = tickScores(numOverloads == 0);

%Find the minimum number of steps
minPaths = numSteps == min(numSteps);
acceptablePaths = acceptablePaths(minPaths);
tickScores = tickScores(minPaths);

[~, ind] = max(tickScores);
if ~isempty(ind) %no usable paths
    bestPath = acceptablePaths{ind};
end