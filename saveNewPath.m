function pathMemArr = saveNewPath(pathMemArr, newPath)
% Saves the path to memory. Saves it as a path from each node in the path
% to each node in the path (forwards and backwards)
% 
% Inputs:
%   pathMemArr - numNodes x numNodes cell array. In each cell is  path from
%       rowNode to colNode as a 1d vector
% 
% Outputs:
%   newPath - 1d vector indicating the path. This will be exactly what goes
%       in pathMemArr{src, dest}. Variations will go in other cells
% 
% Test
% pathMemArr = cell(5,5);
% newPath = [1, 3, 2, 5, 4];
% pathMemArr = saveNewPath(pathMemArr, newPath)
% 
% History
% ZV Created 3/9/2021

numNodes = numel(newPath);

%This isn't gonna be pretty. So many for loops!
%We will add them going forward and backward at the same time
for srcInd = 1:numNodes
    for destInd = 1:numNodes
        if srcInd == destInd
            continue;
        end
        srcNode = newPath(srcInd);
        destNode = newPath(destInd);
        if srcInd < destInd
            pathMemArr{srcNode, destNode} = newPath(srcInd:destInd);
        else
            pathMemArr{srcNode, destNode} = newPath(srcInd : -1 : destInd);
        end
    end
end