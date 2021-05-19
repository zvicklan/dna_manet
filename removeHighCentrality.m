function outMatrix = removeHighCentrality(matrix, nodeList)
% Remove the <numNodes> highest nodes in <matrix> per centrality of type
% <centTypeStr>. Return the resulting matrix
% 
% Test
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% nodeList = [2 3];
% outMatrix = removeHighCentrality(linkMatrix, nodeList)
% 
% History
% 4/14/2021 ZV to remove nodes for UAV sim
% 4/15/2021 broken into helper function... as i should've at first
% 5/19/2021 added logic to skip 0 indices

%Make the output
outMatrix = matrix;
for ii= 1:numel(nodeList)
    thisInd = nodeList(ii);
    if thisInd > 0
        outMatrix(thisInd, :) = 0;
        outMatrix(:, thisInd) = 0;
    end
end