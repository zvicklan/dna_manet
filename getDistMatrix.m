function distMatrix = getDistMatrix(enLocs)
% makes the matrix of distances from each loc to the others. Matrix is
% symmetric
% 
% Inputs:
%   enLocs    - nx2 EN vector for each node
% 
% Outputs:
%   distMatrix  - nxn symmetric matrix of distance between nodes
% 
% Test:
% enLocs = [0, 0; 4, 0; 4, 4; 0, 4];
% distMatrix = getDistMatrix(enLocs)
% 
% History
% Created ZV 3/6/2021

numNodes = size(enLocs, 1);

distMatrix = zeros(numNodes, numNodes); %intermediate values
for ii = 1:numNodes
    thisEN = enLocs(ii,:);
    deltas = enLocs - thisEN;
    dists = diag(sqrt(deltas * deltas.'));
    distMatrix(ii,:) = dists;
end
