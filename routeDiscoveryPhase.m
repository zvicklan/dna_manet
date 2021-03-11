function [bestPath, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(src, dest, ...
    linkMatrix, remainingBW, tickMatrix, msgSize)
% Performs a route discover from src to dest over links in linkMatrix
% Anything non-zero is interpreted as a link
% 
% Input
%   src - scalar id of the source node
%   dest - scalar id of the dest node (These are the inds of the
%       linkMatrix)
%   linkMatrix - nxn link matrix (non-zero is link). n must be > src & dest
% 
% Output
%   bwUsage - nxn link matrix indicating bandwidth used over each link.
%       Note, this is actually directional (non-symmetric)
% 
% Test
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% remainingBW = 100 * ones(5,1);
% [path, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(1, 5, linkMatrix, remainingBW)
% Use Ticks
% linkMatrix = [0 1 1 0 0;
%     1 0 0 0 1; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% tickMatrix = zeros(5,5);
% tickMatrix(1,2) = 9;
% tickMatrix(1,3) = 100;
% remainingBW = 100 * ones(5,1);
% [path, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(1, 5, linkMatrix, remainingBW)
% [path, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(1, 5, linkMatrix, remainingBW, tickMatrix)
% % Can't use node 3
% remainingBW(3) = 0; %say you can't use 3
% [path, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(1, 5, linkMatrix, remainingBW)
% 
% History
% Created 3/7/2021 ZV
% Modified 3/8/2021 ZV to do route selection and allow msgSize input

if ~exist('msgSize', 'var')
    msgSize = 500;
end
if ~exist('tickMatrix', 'var')
    tickMatrix = zeros(size(linkMatrix));
end
tickThreshold = 10;

%Initialize output
bestPath = [];

%% Get potential paths
[goodPaths, totalTx, totalRx, bwMatrix] = getGoodPaths(src, dest, linkMatrix, msgSize);
if isempty(goodPaths) %no paths found
    return;
end

%% Now choose the best path
numPaths = numel(goodPaths);
numOverloads = zeros(numPaths, 1);
numSteps = zeros(numPaths, 1);
tickScores = zeros(numPaths, 1);

%Capture the important metrics
for ii = 1:numPaths
    thisPath = goodPaths{ii};
    numOverloads(ii) = sum(remainingBW(thisPath) <= 0);
    numSteps(ii) = numel(thisPath);
    tickScores(ii) = getTickScore(thisPath, tickMatrix, tickThreshold);
end

%Downfilter on acceptable paths (no overloads)
acceptablePaths = goodPaths(numOverloads == 0);
numSteps = numSteps(numOverloads == 0);
tickScores = tickScores(numOverloads == 0);

%Find the minimum number of steps
minPaths = numSteps == min(numSteps);
acceptablePaths = acceptablePaths(minPaths);
tickScores = tickScores(minPaths);

[~, ind] = max(tickScores);
if ~isempty(ind) %no usable paths
    bestPath = acceptablePaths(ind);
end
    
