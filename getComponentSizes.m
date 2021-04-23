function compSizes = getComponentSizes(matrix, numComponents)
% Return a sorted list of the top numComponent compSizes. Fills in with 0s
% if there are not enough components
%
% Returns a row vector
% 
% Test
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0;
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0];
% compSizes = getComponentSizes(linkMatrix, 3)
% 
% History
% 4/23/2021 For plotting for DNA

myGraph = graph(matrix); %don't care about the network of each link
[~, compSizes] = conncomp(myGraph);
compSizes = sort(compSizes, 'descend');

padLen = numComponents - numel(compSizes);
if padLen > 0
    compSizes = [compSizes(:); zeros(padLen, 1)].';
else
    compSizes = compSizes(1:padLen);
end