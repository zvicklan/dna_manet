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
%       within radius of each other. 
% 
% Test:
% enVector = [0, 0; 4, 0; 4, 4; 0, 4];
% radius = 5;
% linkMatrix = getPossibleLinks(enVector, radius)
% 
% History
% Created ZV 3/1/2021

numNodes = size(nodePosEN, 1);

distMatrix = getDistMatrix(nodePosEN); %intermediate values
linkMatrix = zeros(numNodes, numNodes);
connectCount = zeros(numNodes, 1);

%then do a logic check to make linkMatrix
linkMatrix = double(distMatrix <= radius);

linkMatrix = linkMatrix - eye(numNodes); %0 diagonal