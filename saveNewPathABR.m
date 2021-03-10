function abrPathMem = saveNewPathABR(abrPathMem, newPath)
% Saves the path to memory. Saves it as a path from each node in the path
% to each node in the path (forwards and backwards)
% 
% Inputs:
%   abrPathMem - struct of memory for each node. Memory is essentially an
%       nx6 table: src, dest, preceeding node, next node, srcDist, destDist
%   newPath - array indicating the path to add
% 
% Outputs:
%   abrPathMem - struct of memory for each node. Memory is essentially an
%       nx6 table: src, dest, preceeding node, next node, srcDist, destDist
% 
% Test
% abrPathMem = createMemStruct(6);
% newPath = [1, 3, 2, 5, 4];
% abrPathMem = saveNewPathABR(abrPathMem, newPath)
% 
% History
% ZV Created 3/9/2021 - from saveNewPath

numNodes = numel(newPath);
srcNode = newPath(1);
destNode = newPath(end);
%Need to add a row into the table of everyone (not including Dest)
for ii = 1:numNodes - 1
    thisNode = newPath(ii);
    if ii == 1
        preceder = 0;
    else
        preceder = newPath(ii - 1);
    end
    if ii == numNodes
        nextNode = 0;
    else
        nextNode = newPath(ii + 1);
    end
    srcDist = ii - 1;
    destDist = numNodes - ii;
    newPathEntry = [srcNode, destNode, preceder, nextNode, srcDist, destDist];
    abrPathMem(thisNode).pathTable = [newPathEntry; abrPathMem(thisNode).pathTable];
end