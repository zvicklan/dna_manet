function [totalTx, totalRx, bwMatrix, abrPathMem] = routeDeletionPhase(src, dest, ...
    linkMatrix, abrPathMem, msgSize)
% Deletes routes from src to dest in abrPathMem
% ABR uses a full broadcast to alert the network to remove a route. We will
% simplify this to a two step process. We will do a full BFS like in the
% routeDiscovery phase to determine the full network usage. We will then
% separately erase messages (assuming full transmission)
% This assumption is acceptable because we are planning to erase unwanted
% links at the end of each time step, so links will not have shifted
% 
% Input
%   src - scalar id of the source node
%   dest - scalar id of the dest node (These are the inds of the
%       linkMatrix)
%   linkMatrix - nxn link matrix (non-zero is link). n must be > src & dest
%   abrPathMem - ABR memory structure
%   msgSize - optional size of message (default 500;
% 
% Output
%   totalTx - nx1 vec of transmissions by each node
%   totalRx - nx1 vec of receive by each node
%   bwMatrix - nxn matrix of total BW usage over each link
%   abrPathMem - updated ABR memory structure
%   
% Test
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% remainingBW = 100 * ones(5,1);
% abrPathMem = createMemStruct(5);
% newPath = [1, 2, 4, 5];
% abrPathMem = saveNewPathABR(abrPathMem, newPath)
% [totalTx, totalRx, bwMatrix, abrPathMem] = routeDeletionPhase(1, 5, ...
%     linkMatrix, abrPathMem)
% 
% History
% Created 3/7/2021 ZV
% Modified 3/8/2021 ZV to do route selection and allow msgSize input

if ~exist('msgSize', 'var')
    msgSize = 500;
end
fullBroadcastFlag = 1; %make getGoodPaths go everywhere!
[~, totalTx, totalRx, bwMatrix] = getGoodPaths(src, dest, ...
    linkMatrix, msgSize, fullBroadcastFlag);

%Then remove from memory
nodeList = find(totalRx | totalTx);
numNodes = numel(nodeList);
removeFlag = 1;
for ii = 1:numNodes
    node = nodeList(ii);
    [~, ~, abrPathMem] = getAbrRoutingEntry(src, dest, node, abrPathMem, ...
        removeFlag);
end
