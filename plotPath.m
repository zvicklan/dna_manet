function legendItem = plotPath(pathVec, linkMatrix, nodePosEN, colorStr, ...
    markBadLinks)
% Plots links between all nodes
% 
% Inputs:
%   pathVec     - pathLenx1 vector of the nodes in the path
%   linkMatrix  - nxn link matrix. ignores diagonals. Plots for non-zero
%                   elements
%   nodePosEN   - nx2 vector of en positions for each node. Must align
%                   with indexing in the linkMatrix
%   colorStr    - color to draw the path in. if not in linkMatrix, will
%                   be red (default is black)
%   markBadLinks- bool to enable/disable drawing red for links that don't
%                   exist (default 1 = draw them red)
% 
% Outputs:
%   legendItem  - outputs the handle of the last good segment. For the
%                   legend
% 
% Test:
% pathVec = [1, 2, 3];
% nodePosEN = [0, 0; 4, 0; 4, 4; 0, 4];
% radius = 5;
% linkMatrix = getPossibleLinks(nodePosEN, radius);
% plotPath(pathVec, linkMatrix, nodePosEN, 'g')
% 
% % And with a failure
% pathVec = [1, 2, 4];
% nodePosEN = [0, 0; 4, 0; 4, 4; 0, 4];
% radius = 5;
% linkMatrix = getPossibleLinks(nodePosEN, radius);
% plotPath(pathVec, linkMatrix, nodePosEN, 'g')
% 
% History
% Created ZV 3/1/2021

if ~exist('colorStr', 'var')
    colorStr = 'k';
end
if ~exist('markBadLinks', 'var')
    markBadLinks = 1;
end
hold all;
pathLen = numel(pathVec);

%Error checking on the input
if pathLen == 0
    error('%s: Called with no path\n', mfilename);
elseif pathLen == 1
    startNode = pathVec(1);
    startEN = nodePosEN(startNode,:);
    legendItem = plot(startEN(1), startEN(2), 'rx');
    return;
end

startNode = pathVec(1);
startEN = nodePosEN(startNode,:);
for ii = 1:pathLen - 1
    endNode = pathVec(ii+1);
    endEN = nodePosEN(endNode,:);
        if linkMatrix(startNode, endNode) || ~markBadLinks
            legendItem = plot([startEN(1), endEN(1)], [startEN(2), endEN(2)], colorStr);
        else
            legendItem = plot([startEN(1), endEN(1)], [startEN(2), endEN(2)], 'r');
        end
    %don't really need a speed enhancement, but we'll do it
    startNode = endNode;
    startEN = endEN;
end