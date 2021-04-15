function msgPairs = getCommNetPairs(nodePosEN, numNet, numComm, tgtEN, linkMatrix)
%Finds the net node and comm node closest to each target
% returns this as pairs
%
% Test
% nodePosEN = genENSpots(0:45:360-1,50);
% nodePosEN = [nodePosEN; genENSpots(0:90:270,50)];
% tgtEN = genENSpots(0:90:270,100);
% numNet = 8;
% numComm = 4;
% linkMatrix = zeros(12);
% linkMatrix(1,9) = 1;
% linkMatrix(3,10) = 1;
% linkMatrix(5,11) = 1;
% linkMatrix(6,12) = 1;
% linkMatrix = linkMatrix | linkMatrix.';
% msgPairs = getCommNetPairs(nodePosEN, numNet, numComm, tgtEN, linkMatrix)
% 
% History
% 4/15/2021 ZV created for msg pairing for enemies

%Initialize output
numTgts = size(tgtEN, 1);
msgPairs = zeros(numTgts, 2);

%We will way overgenerate distances then go through and pick nodes
originalDim = size(nodePosEN, 1); %original num rows
nodePosEN = [nodePosEN; tgtEN];
finalDim = size(nodePosEN, 1); % dims with targets added

distMatrix = getDistMatrix(nodePosEN); %intermediate values
myGraph = graph(linkMatrix);

%Now loop through each target
assert(finalDim - originalDim == numTgts)
for tt = (originalDim+1) : finalDim
    dists = distMatrix(:,tt); %s/b symmetric, so row/col doesn't matter
    commDists = dists(numNet+1 : numNet + numComm);
    [~, minCommInd] = min(commDists);
    commInd = minCommInd + numNet;
    
    %Now we want to pick the closest net that connects to that comm
    connects = 0;
    nodeInd = 1;
    netDists = dists(1:numNet);
    [~, nodeInds] = sort(netDists, 'ascend');
    while ~connects
        if nodeInd > numel(nodeInds)
            error('%s: Could not find any node to send to\n', mfilename);
        end
        netInd = nodeInds(nodeInd);
        %use a fancy method to do very little
        shortestPath = shortestpath(myGraph, commInd, netInd);
        if isempty(shortestPath)
            nodeInd = nodeInd + 1;
        else
            connects = 1;
        end
    end
    msgPairs(tt - originalDim,:) = [commInd, netInd];
end
    