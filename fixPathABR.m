function [bestPath, totalTx, totalRx, bwMatrix, abrPathMem] = fixPathABR(abrPathMem, ...
    linkMatrix, remainingBW, tickMatrix, src, dest, thisNode, msgSize)
% Performs a route recovery. Attempts to fix with the same number of steps
% until we get halfway back to the start. Then we restart
% 
% Test
% linkMatrix = [0 1 1 0 0;
%     1 0 1 1 0;
%     1 1 0 1 1;
%     0 1 1 0 0;
%     0 0 1 0 0];
% remainingBW = 100*ones(5,1);
% abrPathMem = createMemStruct(6);
% newPath = [1, 2, 4, 5];
% [~,~,~, abrPathMem] = saveNewPathABR(abrPathMem, newPath);
% tickMatrix = zeros(5,5);
% tickMatrix(1,2) = 9;
% tickMatrix(1,3) = 100;
% src = 1;
% dest = 5;
% thisNode = 4;
% msgSize = 500;
% [bestPath, totalTx, totalRx, bwMatrix, abrPathMem] = fixPathABR(abrPathMem, ...
%     linkMatrix, remainingBW, tickMatrix, src, dest, thisNode, msgSize)
% 
% %Make it redo
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0;
%     1 0 0 1 1;
%     0 1 1 0 0;
%     0 0 1 0 0];
% [bestPath, totalTx, totalRx, bwMatrix, abrPathMem] = fixPathABR(abrPathMem, ...
%     linkMatrix, remainingBW, tickMatrix, src, dest, thisNode, msgSize)
% 
% History
% Created 3/10/2021 ZV

numNodes = size(linkMatrix,1);
%Initialize outputs
bestPath = [];
totalTx = zeros(numNodes, 1);
totalRx = zeros(numNodes, 1);
bwMatrix = zeros(numNodes, numNodes);

if ~exist('msgSize', 'var')
    msgSize = 1;
end

tickThreshold = 10;

%First, we will try to do an H-step query. We need to know how far we are
[hasRoute, abrRow] = getAbrRoutingEntry(src, dest, thisNode, abrPathMem);
if ~hasRoute
    return;
end
%Continue on if we had the route
srcDist = abrRow(5);
destDist = abrRow(6);
totalSteps = srcDist + destDist + 1; %numSteps + 1

%We also need the path from src to dest to make sure we don't loop on it
[srcHasRoute, success, abrPath] = readRouteABR(src, dest, abrPathMem);
if ~srcHasRoute || ~success
    %path is incomplete. Delete it
    [tempTx, tempRx, tempBwMatrix, abrPathMem] = routeDeletionPhase(src, dest, ...
        linkMatrix, abrPathMem, msgSize);
    totalTx = totalTx + tempTx;
    totalRx = totalRx + tempRx;
    bwMatrix = bwMatrix + tempBwMatrix;
    return;
end
%Otherwise, we need the portion of the path that extends up to us
ind = find(abrPath == thisNode);

if numel(ind) > 1
    disp(abrPath)
    error('%s: Duplicate nodes (%d) found in path\n', mfilename, thisNode);
end

currentPath = abrPath(1:ind);

%Look for paths
fullBroadcastFlag = 0;
[goodPaths, tempTx, tempRx, tempBwMatrix] = getGoodPaths(src, dest, ...
    linkMatrix, msgSize, fullBroadcastFlag, totalSteps, currentPath);
totalTx = totalTx + tempTx;
totalRx = totalRx + tempRx;
bwMatrix = bwMatrix + tempBwMatrix;

if isempty(goodPaths)
    %We have to recurse backward or do a full search again
    if srcDist >= destDist && ind > 1 %I think the latter is obvious, but double checking
        %take a step back and try again
        previousNode = abrPath(ind - 1); %error covered above
        [bestPath, tempTx, tempRx, tempBwMatrix, abrPathMem] = fixPathABR(abrPathMem, ...
            linkMatrix, remainingBW, tickMatrix, src, dest, previousNode, msgSize);
        totalTx = totalTx + tempTx;
        totalRx = totalRx + tempRx;
        bwMatrix = bwMatrix + tempBwMatrix;
    else
        fprintf('Re-discovering route from %d to %d\n', src, dest);
        %Delete the old and re-discover
        [tempTx, tempRx, tempBwMatrix, abrPathMem] = routeDeletionPhase(src, dest, ...
            linkMatrix, abrPathMem, msgSize);
        totalTx = totalTx + tempTx;
        totalRx = totalRx + tempRx;
        bwMatrix = bwMatrix + tempBwMatrix;
        %Rediscovery
        [bestPath, tempTx, tempRx, tempBwMatrix] = routeDiscoveryPhase(src, dest, ...
            linkMatrix, remainingBW, tickMatrix, msgSize);
        totalTx = totalTx + tempTx;
        totalRx = totalRx + tempRx;
        bwMatrix = bwMatrix + tempBwMatrix;
    end
else
    %We got one!
    bestPath = choosePath(goodPaths, remainingBW, tickMatrix, tickThreshold);
    %Delete the old and rewrite with yours
    [tempTx, tempRx, tempBwMatrix, abrPathMem] = routeDeletionPhase(src, dest, ...
        linkMatrix, abrPathMem, msgSize);
    totalTx = totalTx + tempTx;
    totalRx = totalRx + tempRx;
    bwMatrix = bwMatrix + tempBwMatrix;
end