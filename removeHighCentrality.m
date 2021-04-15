function outMatrix = removeHighCentrality(matrix, numNodes, centTypeStr)
% Remove the <numNodes> highest nodes in <matrix> per centrality of type
% <centTypeStr>. Return the resulting matrix
% 
% Test
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% numNodes = 2;
% centTypeStr = 'degree';
% outMatrix = removeHighCentrality(linkMatrix, numNodes, centTypeStr)
% 
% History
% 4/14/2021 ZV to remove nodes for UAV sim

% First, we make our graph
myGraph = graph(matrix);
centScores = centrality(myGraph, centTypeStr);
[~, inds] = sort(centScores, 'descend'); %pretty sure I just want inds though

%Make the output
outMatrix = matrix;
for ii= 1:numNodes
    %probably could've been a helper function, but ain't nobody got time
    %for that
    thisInd = inds(ii);
    outMatrix(thisInd, :) = 0;
    outMatrix(:, thisInd) = 0;
end