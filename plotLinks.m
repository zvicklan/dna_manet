function [legBiDir, legMonoDir] = plotLinks(linkMatrix, nodePosEN, colorStr, lineWidth)
% Plots links between all nodes. (Note: Plots if i->j or j->i exists
% 
% Inputs:
%   linkMatrix    - nxn link matrix. ignores diagonals. Plots for non-zero
%       elements
%   nodePosEN     - nx2 vector of en positions for each node. Must align
%       with indexing in the linkMatrix
%   colorStr      - string for color to use for lines
%   lineWidth     - scalar for size of lines
% 
% Outputs:
%   none 
% 
% Test:
% nodePosEN = [0, 0; 4, 0; 4, 4; 0, 4];
% radius = 5;
% linkMatrix = getPossibleLinks(nodePosEN, radius);
% lineWidth = 5;
% plotLinks(linkMatrix, nodePosEN, 'k', lineWidth)
% 
% History
% Created ZV 3/1/2021

if ~exist('colorStr', 'var')
    colorStr = 'k';
end
if ~exist('lineWidth', 'var')
    lineWidth = 0.5; %matlab default
end
hold all;
numNodes = size(nodePosEN, 1);
legBiDir = plot([NaN, NaN], [NaN, NaN], ...
                colorStr, 'LineWidth', lineWidth);
legMonoDir = plot([NaN, NaN], [NaN, NaN], ...
                [':', colorStr], 'LineWidth', lineWidth);
for ii = 1:numNodes - 1
    startEN = nodePosEN(ii,:);
    for jj = ii+1:numNodes
        %loop accross upper right triangle and plot for every nonzero
        %element
        if linkMatrix(ii, jj) && linkMatrix(jj, ii)
            endEN = nodePosEN(jj,:);
            legBiDir = plot([startEN(1), endEN(1)], [startEN(2), endEN(2)], ...
                colorStr, 'LineWidth', lineWidth);
        elseif linkMatrix(ii, jj) || linkMatrix(jj, ii) %dotted if not bi-directional
            endEN = nodePosEN(jj,:);
            legMonoDir = plot([startEN(1), endEN(1)], [startEN(2), endEN(2)], ...
                [':', colorStr], 'LineWidth', lineWidth);
        end
    end
end