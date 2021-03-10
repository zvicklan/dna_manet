function [hasRoute, abrRow] = getAbrRoutingEntry(src, dest, node, abrPathMem)
% Helper to grab info from ABR path memory
% Returns the row of the next step
% 
% Input:
%   src - scalar node number 
%   dest - scalar node number
%   node - the node we are at  
%   abrPathMem - the data struct
% 
% Output
%   abrRow - the 1x6 row from the path
% 
% Test
% abrPathMem = createMemStruct(5);
% newPath = [1, 3, 2, 5, 4];
% abrPathMem = saveNewPathABR(abrPathMem, newPath)
% [hasRoute, abrRow] = getAbrRoutingEntry(1, 4, 1, abrPathMem)
% [hasRoute, abrRow] = getAbrRoutingEntry(1, 4, 3, abrPathMem)
% [hasRoute, abrRow] = getAbrRoutingEntry(1, 5, 1, abrPathMem)
% 
% History
% 3/9/2021 ZV Created to help useRouteABR

hasRoute = 0;
abrRow = [];
nodePaths = abrPathMem(node).pathTable;
pathInd = find((nodePaths(:,1) == src) & (nodePaths(:,2) == dest));
if numel(pathInd) > 1
    disp(nodePaths)
    hasRoute = 1;
    error('%s: Routing table in node %d had %d paths to destNode %d\n', ...
        mfilename, src, numel(pathInd), dest);
elseif numel(pathInd) == 0
    %no paths.
    hasRoute = 0;
    return;
end

hasRoute = 1;
abrRow = nodePaths(pathInd, :);