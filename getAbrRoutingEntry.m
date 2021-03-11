function [hasRoute, abrRow, abrPathMem] = getAbrRoutingEntry(src, dest, ...
    node, abrPathMem, removeFlag)
% Helper to grab info from ABR path memory
% Returns the row of the next step
% 
% Input:
%   src - scalar node number 
%   dest - scalar node number
%   node - the node we are at  
%   abrPathMem - the data struct
%   removeFlag - removes the row from the table as returning it
% 
% Output
%   hasRoute - bool indicating if the route was there
%   abrRow - the 1x6 row from the path
%   abrPathMem - updated ABR data struct
% 
% Test
% abrPathMem = createMemStruct(5);
% newPath = [1, 3, 2, 5, 4];
% abrPathMem = saveNewPathABR(abrPathMem, newPath)
% [hasRoute, abrRow] = getAbrRoutingEntry(1, 4, 1, abrPathMem)
% [hasRoute, abrRow] = getAbrRoutingEntry(1, 4, 3, abrPathMem)
% [hasRoute, abrRow] = getAbrRoutingEntry(1, 5, 1, abrPathMem)
% % Then try to remove it
% [hasRoute, abrRow, abrPathMem] = getAbrRoutingEntry(1, 4, 1, abrPathMem, 1)
% [hasRoute, abrRow] = getAbrRoutingEntry(1, 4, 1, abrPathMem)
% 
% History
% 3/9/2021 ZV Created to help useRouteABR

if ~exist('removeFlag', 'var')
    removeFlag = 0;
end

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
if removeFlag
    abrPathMem(node).pathTable = [abrPathMem(node).pathTable(1:pathInd - 1, :);
        abrPathMem(node).pathTable(pathInd + 1:end, :)];
end