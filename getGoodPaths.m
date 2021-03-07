function [goodPaths, totalTx, totalRx] = getGoodPaths(src, dest, linkMatrix)
% Finds all links from src to dest without duplicates
% 
% Input
%   src - scalar id of the source node
%   dest - scalar id of the dest node (These are the inds of the
%       linkMatrix)
%   linkMatrix - nxn link matrix (non-zero is link). n must be > src & dest
% 
% Output
%   totalTx - nx1 vector indicating how much each node transmits
%   totalRx - nx1 vector indicating how much each node receives
% 
% Test
% % simple 1 path
% linkMatrix = [0 1 0; 1 0 1; 0 1 0]; 
% [goodPaths, totalTx, totalRx] = getGoodPaths(3, 1, linkMatrix)
% % simple 2 path
% linkMatrix = [0 1 1; 1 0 1; 1 1 0]; 
% [goodPaths, totalTx, totalRx] = getGoodPaths(3, 1, linkMatrix)
% % complex 2 path
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% [goodPaths, totalTx, totalRx] = getGoodPaths(1, 5, linkMatrix)
% 
% History
% Created 3/27/2021 ZV - helper for routeDiscoveryPhase

numNodes = size(linkMatrix, 1);
totalTx = zeros(numNodes, 1);
totalRx = zeros(numNodes, 1);

msgSize = 500;

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
    
    if ~isempty(find(myPath == dest, 1)) 
        %Made it to destination!
        goodPaths{numel(goodPaths) + 1} = myPath;
    elseif numel(myPath) > numel(unique(myPath))
        %Loop has a duplicate
        %nop
    else
        %retransmit
        neighbors = find(linkMatrix(thisNode,:));
        totalTx(thisNode) = totalTx(thisNode) + msgSize;
        totalRx(neighbors) = totalRx(neighbors) + 500;
        for ii = 1:numel(neighbors)
            paths{numel(paths) + 1} = [myPath, neighbors(ii)];
        end
    end
end
