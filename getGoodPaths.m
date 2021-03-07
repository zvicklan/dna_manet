function [goodPaths, bwUsage] = getGoodPaths(src, dest, linkMatrix)
% Finds all links from src to dest without duplicates
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
% linkMatrix = [0 1 0; 1 0 1; 0 1 0]; 
% [goodPaths, bwUsage] = getGoodPaths(3, 1, linkMatrix)
% linkMatrix = [0 1 0; 1 0 1; 0 1 0]; 
% [goodPaths, bwUsage] = getGoodPaths(3, 1, linkMatrix)
% 
% History
% Created 3/27/2021 ZV - helper for routeDiscoveryPhase

bwUsage = zeros(size(linkMatrix));

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
    
    if ~isempty(find(myPath == dest)) 
        %Made it to destination!
        goodPaths{numel(goodPaths) + 1} = myPath;
    elseif numel(myPath) > numel(unique(myPath))
        %Loop has a duplicate
        %nop
    else
        %retransmit
        neighbors = find(linkMatrix(thisNode,:));
        bwUsage(thisNode, neighbors) = bwUsage(thisNode, neighbors) + 500;
        for ii = 1:numel(neighbors)
            paths{numel(paths) + 1} = [myPath, neighbors(ii)];
        end
    end
end
