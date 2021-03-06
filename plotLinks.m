function legendItem = plotLinks(linkMatrix, nodePosEN, colorStr)
% Plots links between all nodes
% 
% Inputs:
%   linkMatrix    - nxn link matrix. ignores diagonals. Plots for non-zero
%       elements
%   nodePosEN     - nx2 vector of en positions for each node. Must align
%       with indexing in the linkMatrix
% 
% Outputs:
%   none
% 
% Test:
% nodePosEN = [0, 0; 4, 0; 4, 4; 0, 4];
% radius = 5;
% linkMatrix = getPossibleLinks(nodePosEN, radius);
% plotLinks(linkMatrix, nodePosEN)
% 
% History
% Created ZV 3/1/2021

if ~exist('colorStr', 'var')
    colorStr = 'k';
end
hold all;
numNodes = size(nodePosEN, 1);

for ii = 1:numNodes - 1
    startEN = nodePosEN(ii,:);
    for jj = ii+1:numNodes
        %loop accross upper right triangle and plot for every nonzero
        %element
        if linkMatrix(ii, jj)
            endEN = nodePosEN(jj,:);
            legendItem = plot([startEN(1), endEN(1)], [startEN(2), endEN(2)], colorStr);
        end
    end
end