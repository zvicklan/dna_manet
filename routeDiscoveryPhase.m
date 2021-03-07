function [totalTx, totalRx] = routeDiscoveryPhase(src, dest, linkMatrix, nodeBW)
% Performs a route discover from src to dest over links in linkMatrix
% Anything non-zero is interpreted as a link
% 
% Input
%   src - scalar id of the source node
%   dest - scalar id of the dest node (These are the inds of the
%       linkMatrix)
%   linkMatrix - nxn link matrix (non-zero is link). n must be > src & dest
% 
% Output
%   bwUsage - nxn link matrix indicating bandwidth used over each link.
%       Note, this is actually directional (non-symmetric)
% 
% Test
% linkMatrix = [0 1 0; 1 0 1; 0 1 0]; 
% bwUsage = routeDiscoveryPhase(3, 1, linkMatrix)
% 
% History
% Created 3/27/2021 ZV

%get potential paths
[goodPaths, totalTx, totalRx] = getGoodPaths(src, dest, linkMatrix);

%Now choose the best path