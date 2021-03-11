function [goodPaths, totalTx, totalRx, bwMatrix] = getGoodPaths(src, dest, ...
    linkMatrix, msgSize, fullBroadcastFlag)
% Finds all links from src to dest without duplicates
%
% Input
%   src - scalar id of the source node
%   dest - scalar id of the dest node (These are the inds of the
%       linkMatrix)
%   linkMatrix - nxn link matrix (non-zero is link). n must be > src & dest
%   msgSize - optional flag - size of msg
%   fullBroadcastFlag - bool to make it do a full broadcast, not stop at
%       dest
%
% Output
%   goodPaths - mx1 cell array of m possible paths
%   totalTx  - nx1 vector indicating how much each node transmits
%   totalRx  - nx1 vector indicating how much each node receives
%   bwMatrix - nxn matrix indicating bw used over each link (non-symmetric)
%
% Test
% % simple 1 path
% linkMatrix = [0 1 0; 1 0 1; 0 1 0];
% [goodPaths, totalTx, totalRx, bwMatrix] = getGoodPaths(3, 1, linkMatrix)
% % simple 2 path
% linkMatrix = [0 1 1; 1 0 1; 1 1 0];
% [goodPaths, totalTx, totalRx, bwMatrix] = getGoodPaths(3, 1, linkMatrix)
% % complex 2 path
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0;
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0];
% [goodPaths, totalTx, totalRx, bwMatrix] = getGoodPaths(1, 5, linkMatrix)
% % No path
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0;
%     1 0 0 0 0;
%     0 1 0 0 0;
%     0 0 0 0 0];
% [goodPaths, totalTx, totalRx, bwMatrix] = getGoodPaths(1, 5, linkMatrix)
% % two options then through same point (should only return 1)
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0;
%     1 0 0 1 0;
%     0 1 1 0 1;
%     0 0 0 1 0];
% [goodPaths, totalTx, totalRx, bwMatrix] = getGoodPaths(1, 5, linkMatrix)
%
% History
% Created 3/7/2021 ZV - helper for routeDiscoveryPhase
% 3/8/2021 - Modified so that each node will only send each msg once

if ~exist('msgSize', 'var')
    msgSize = 1;
end
if ~exist('fullBroadcastFlag', 'var')
    fullBroadcastFlag = 0;
end

numNodes = size(linkMatrix, 1);
totalTx = zeros(numNodes, 1);
totalRx = zeros(numNodes, 1);
bwMatrix = zeros(numNodes, numNodes);

%Adding vector to track if each node has transmitted. If it has, it doesn't
%do it again
hasTXed = zeros(numNodes, 1);

%I think we want to do a breadth-first search. Except it'll keep going
%until we've gotten from src to dest every possible way. Then we'll store
%all the paths and choose the best
paths = {[src]};
goodPaths ={};
while numel(paths) > 0
    % Grab a path, add neighbors
    %pop from paths
    myPath = paths{1};
    thisNode = myPath(end);
    if numel(paths) == 1
        paths = {};
    else
        paths = paths(2:end);
    end
    
    
    if numel(myPath) > numel(unique(myPath)) || hasTXed(thisNode)
        %Loop has a duplicate OR has already transmitted
        %nop
    else
        if ~isempty(find(myPath == dest, 1))
            %Made it to destination!
            goodPaths{numel(goodPaths) + 1} = myPath;
            if ~fullBroadcastFlag
                continue; %stop here unless we're doing a full broadcast
            end
        end
        %retransmit
        neighbors = find(linkMatrix(thisNode,:));
        totalTx(thisNode) = totalTx(thisNode) + msgSize;
        totalRx(neighbors) = totalRx(neighbors) + msgSize;
        bwMatrix(thisNode, neighbors) = bwMatrix(thisNode, neighbors) + msgSize;
        hasTXed(thisNode) = 1; %mark to not tx again
        for ii = 1:numel(neighbors)
            paths{numel(paths) + 1} = [myPath, neighbors(ii)];
        end
    end
end
