function srcDestPairs = getSrcDestPairs(numNodes, numPairs)
% Little way to get unique src dest pairs in a useful way
% 
% Inputs:
%   numNodes - scalar number of nodes (src and dest will be 1:numNodes)
%   numPairs - number of pairs to make
% 
% Outputs:
%   srcDestPairs - numPairs x 2 array of src and dest. Two columns will be
%       unique from each other (not sending to self)
% 
% Test
% getSrcDestPairs(10,12)
% 
% History
% Created 3/8/2021 ZV

srcDestPairs = zeros(numPairs, 2);

for ii = 1:numPairs
    srcDestPairs(ii,:) = randsample(numNodes, 2);
end