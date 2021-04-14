function [bestPath, totalTx, totalRx, bwMatrix] = routeDiscoveryDSR(src, dest, ...
                linkMatrix, pathMemArr, msgSize)
% Performs a route discover from src to dest over links in linkMatrix
% Uses optimizations of the DSR algorithm to allow for using existing paths
% in the DSR memory
% 
% Input
%   src - scalar id of the source node
%   dest - scalar id of the dest node (These are the inds of the
%       linkMatrix)
%   linkMatrix - nxn link matrix (non-zero is link). n must be > src & dest
%   pathMemArr  - numNodes x numNodes cell arr - if each entry is empty,
%       then there is (supposed to be) a path there
% 
% Output
%   bestPath    - mx1 array of the path
%   totalTx     - numNodesx1 vector of transmit by each node   
%   totalRx     - numNodesx1 vector of receive by each node
%   bwMatrix    - nxn link matrix indicating bandwidth used over each link.
%       Note, this is NOW actually symmetric
% 
% % Test
% linkMatrix = [0 1 1 0 0;
%     1 0 0 1 0; 
%     1 0 0 0 1;
%     0 1 0 0 1;
%     0 0 1 1 0]; 
% pathMemArr = cell(5);
% [path, totalTx, totalRx, bwMatrix] = routeDiscoveryDSR(1, 5, linkMatrix, pathMemArr)
% pathMemArr = saveNewPath(pathMemArr, path);
% [path, totalTx, totalRx, bwMatrix] = routeDiscoveryDSR(3, 1, linkMatrix, pathMemArr)
% 
% History
% ZV created 4/13/2021

% Going to be somewhat similar to getGoodPaths, but at each step we will
% check to see if there is an existing path

if ~exist('msgSize', 'var')
    msgSize = 1;
end

numNodes = size(linkMatrix, 1);
totalTx = zeros(numNodes, 1);
totalRx = zeros(numNodes, 1);
bwMatrix = zeros(numNodes, numNodes);
bestPath = []; %one main change is that we will return the first one found
%Due to how we're doing it, it'll probably be about the best, but it isn't
%checked like in ABR

%Adding vector to track if each node has transmitted. If it has, it doesn't
%do it again
hasTXed = zeros(numNodes, 1);

%I think we want to do a breadth-first search. Except it'll keep going
%until we've gotten from src to dest every possible way. However, we'll
%only keep the first way that we get there (Blame Johnson)
paths = {src};
while numel(paths) > 0
    % Grab a path, add neighbors
    %pop from paths
    myPath = paths{1};
    thisNode = myPath(end);
    if numel(paths) == 1
        paths = {};
    else
        paths = paths(2:end);
    end
    
    %Check for a hit in the path memory
    memPath = pathMemArr{thisNode, dest};
    memPath = memPath(:); %ensure column vector for appending
    if ~isempty(memPath)
        if memPath(end) ~= dest
            disp('Bad path... bad!')
            disp(memPath)
            error('%s: pathMemArr{%d,%d} did not arrive to dest\n', mfilename, ...
                thisNode, dest);
        end
        hasTXed(thisNode) = 1; %mark to not tx again
        if isempty(bestPath)
            fprintf('%s: Using existing path from %d to %d. Orig src %d\n', ...
                mfilename, thisNode, dest, src);
            wouldBePath = [myPath(:); memPath(2:end)];
            disp(wouldBePath.')
            %check that there are no loops in here
            if numel(wouldBePath) == numel(unique(wouldBePath))
                bestPath = wouldBePath;
            end
        end
    end
    
    if numel(myPath) > numel(unique(myPath)) || hasTXed(thisNode) 
        %Loop has a duplicate OR has already transmitted
        %nop
    else
        if ~isempty(find(myPath == dest, 1))
            %Made it to destination!
            %If we don't have a solution yet, this is it!
            if isempty(bestPath)
                bestPath = [myPath(:); memPath(2:end)];
            end
        end
        %retransmit
        neighbors = find(linkMatrix(thisNode,:));
        totalTx(thisNode) = totalTx(thisNode) + msgSize;
        totalRx(neighbors) = totalRx(neighbors) + msgSize;
        bwMatrix(thisNode, neighbors) = bwMatrix(thisNode, neighbors) + msgSize;
        hasTXed(thisNode) = 1; %mark to not tx again
        for ii = 1:numel(neighbors)
            paths{numel(paths) + 1} = [myPath, neighbors(ii)];
        end
    end
end