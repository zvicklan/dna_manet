function linkMatrix = getPossibleLinks(nodePosEN, radius)
% Function for determining if which nodes can have links based on a radius
% in en
% 
% Inputs:
%   enVector    - nx2 EN vector for each node
%   radius      - scalar for comparison. in same units as en vectors
% 
% Outputs:
%   linkMatrix  - nxn symmetric matrix of potential links indicating nodes
%       within radius of each other. The diagonal indicates number of
%       potential links to that node
% 
% Test:
% enVector = [0, 0; 4, 0; 4, 4; 0, 4];
% radius = 5;
% linkMatrix = getPossibleLinks(enVector, radius)
% 
% History
% Created ZV 3/1/2021

numNodes = size(nodePosEN, 1);

distMatrix = zeros(numNodes, numNodes); %intermediate values
linkMatrix = zeros(numNodes, numNodes);
connectCount = zeros(numNodes, 1);
for ii = 1:numNodes
    thisEN = nodePosEN(ii,:);
    deltas = nodePosEN - thisEN;
    dists = diag(sqrt(deltas * deltas.'));
    distMatrix(ii,:) = dists;
end

%then do a logic check to make linkMatrix
linkMatrix = double(distMatrix <= radius);

%Then insert the counts into the diagonal
connectCount = sum(linkMatrix, 2) - 1;
linkMatrix(1:numNodes+1:numNodes^2) = connectCount; %nifty way to insert