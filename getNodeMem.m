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

nodeObj.paths = cell(numNodes, 1); %path to each other node
nodeObj.newMsgs = {};
nodeObj.outMsgCount = 0; %used for iding each message
nodeObj.seenList = []; %we're gonna store this as a hash table