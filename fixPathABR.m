function [bestPath, totalTx, totalRx, bwMatrix, pathMemArr] = fixPathABR(pathMemArr, ...
    linkMatrix, remainingBW, tickMatrix, src, dest, thisNode, msgSize)
% Performs a route recovery. Attempts to fix with the same number of steps
% until we get halfway back to the start. Then we restart

% Test
% abrPathMem = createMemStruct(5);
% newPath = [1, 3, 2, 5, 4];
% abrPathMem = saveNewPathABR(abrPathMem, newPath)
% src = 1;
% dest = 4;
% [hasRoute, success, usedPath] = readRouteABR(src, dest, abrPathMem)
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% remainingBW = 100 * ones(5,1);
% [path, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(1, 5, linkMatrix, remainingBW)
% % Can't use node 3
% remainingBW(3) = 0; %say you can't use 3
% [path, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(1, 5, linkMatrix, remainingBW)
% 
% History
% Created 3/7/2021 ZV
% Modified 3/8/2021 ZV to do route selection and allow msgSize input

