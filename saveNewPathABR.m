function [totalTx, totalRx, bwMatrix, abrPathMem] = saveNewPathABR(abrPathMem, newPath, msgSize)
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
%[totalTx, totalRx, bwMatrix, abrPathMem] = saveNewPathABR(abrPathMem, newPath, msgSize)
% 
% History
% ZV Created 3/9/2021 - from saveNewPath

if ~exist('msgSize', 'var')
    msgSize = 500;
end

%Initialize output
numNodes = numel(abrPathMem);
%Initialize outputs
totalTx = zeros(numNodes, 1);
totalRx = zeros(numNodes, 1);
bwMatrix = zeros(numNodes, numNodes);

pathLength = numel(newPath);
srcNode = newPath(1);
destNode = newPath(end);
%Need to add a row into the table of everyone (not including Dest)
for ii = 1:pathLength - 1
    thisNode = newPath(ii);
    if ii == 1
        preceder = 0;
    else
        preceder = newPath(ii - 1);
    end
    if ii == pathLength
        nextNode = 0;
    else
        nextNode = newPath(ii + 1);
        %Reversing because message is going back other way
        bwMatrix(nextNode, thisNode) = bwMatrix(nextNode, thisNode) + msgSize;
    end
    srcDist = ii - 1;
    destDist = pathLength - ii;
    newPathEntry = [srcNode, destNode, preceder, nextNode, srcDist, destDist];
    abrPathMem(thisNode).pathTable = [newPathEntry; abrPathMem(thisNode).pathTable];
end
totalTx(newPath(2:end)) = totalTx(newPath(2:end)) + msgSize;
totalRx(newPath(1:end-1)) = totalRx(newPath(1:end-1)) + msgSize;
fprintf('    Added path from %d to %d\n', srcNode, destNode);