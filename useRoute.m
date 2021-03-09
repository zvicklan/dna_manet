function [success, usedPath, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
                links, thisPath, msgSize)
% Attempt to use a specific route. If unavailable, return success = 0 and
% the extent of the path that you could use
% 
% Inputs
%   src - scalar node to start from (s/b first node of memPath)
%   dest - scalar - node to end at (s/b last node of memPath)
%   links - numNodes x numNodes matrix of links (nonzero = link)
%   thisPath - steps+1 x 1 vector indicating our path
%   msgSize - scalar size of each message
% 
% Outputs
%   success - boolean indicating success/failure
%   usedPath - how far we could go from start (if success, s/b memPath)
%   totalTx - numNodes x1 vec - messages sent by each node
%   totalRx - numNodes x 1 vec - messages received by each node
%   bwMatrix - numNodes x numNodex matrix of BW used per link
% 
% Test
% links = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% src = 1;
% dest = 5;
% memPath = [1, 2, 4, 5];
% msgSize = 500;
% [success, usedPath, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
%                 links, memPath, msgSize)
% 
% % And with a failure
% links = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 0;
%     0 0 1 1 0]; 
% src = 1;
% dest = 5;
% memPath = [1, 2, 4, 5];
% msgSize = 500;
% [success, usedPath, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
%                 links, memPath, msgSize)
% 
% History
% 3/9/2021 Created ZV

if ~exist('msgSize', 'var')
    msgSize = 1;
end
%always need this
numNodes = size(links, 1);
pathLength = numel(thisPath);

%Initialize output
usedPath = zeros(pathLength, 1);
usedPath(1) = src;
totalTx = zeros(numNodes, 1);
totalRx = zeros(numNodes, 1);
bwMatrix = zeros(numNodes, numNodes);
success = 0;

%check the path
if thisPath(1) ~= src
    warning('%s: 1st element of path is %d. Does not match src %d\n', ...
        mfilename, thisPath(1), src);
    success = 0;
end
if thisPath(end) ~= dest
    warning('%s: last element of path is %d. Does not match dest %d\n', ...
        mfilename, thisPath(end), dest);
    success = 0;
end

%Now, we just step through the path and make sure each link is valid
for ii = 1:pathLength - 1
    rInd = thisPath(ii);
    cInd = thisPath(ii + 1);
    if links(rInd, cInd)
        %link is good
        totalTx(rInd) = totalTx(rInd) + msgSize;
        totalRx(cInd) = totalRx(cInd) + msgSize;
        bwMatrix(rInd, cInd) = bwMatrix(rInd, cInd) + msgSize;
        usedPath(ii + 1) = cInd;
    else
        %msg Fails. Attempt 3 times (but we know it won't work)
        totalTx(rInd) = totalTx(rInd) + 3*msgSize;
        usedPath = usedPath(1:ii); %trim down
        return;
    end
end
if usedPath(end) == dest
    success = 1;
else
    warning('%s: Bad path? This shouldn''t really happen\n', mfilename);
end