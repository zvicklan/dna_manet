function nodeObj = getNodeMem(numNodes)
% Creates the memory of each node
% Input
%   numNodes - scalar number of nodes
%   
% Output
%   nodeObj - struct containing everything a node needs
% 
% Test
% getNodeMem(3)
% 
% History
% Created 3/7/2021 ZV

startingSize = 10;
%Stores all of the information of paths that we're on
%src, dest, incomingNode, outgoingNode, srcDist, destDist
nodeObj.pathTable = zeros(startingSize, 6); %path to each other node