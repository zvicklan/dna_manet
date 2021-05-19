function highestNodes = getHighCentralityNodes(matrix, numNodes, centTypeStr)
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
% highestNodes = getHighCentralityNodes(linkMatrix, numNodes, centTypeStr)
% 
% History
% 4/14/2021 ZV to remove nodes for UAV sim
% 5/19/2021 modified to operate recursively

%Operating recursively
highestNodes = zeros(numNodes, 1);

for ii = 1:numNodes
    % First, we make our graph
    myGraph = graph(matrix);
    centScores = centrality(myGraph, centTypeStr);
    [~, inds] = sort(centScores, 'descend'); %pretty sure I just want inds though

    %Make the output
    highestNodes(ii) = inds(1);
    matrix = removeHighCentrality(matrix, highestNodes);
end