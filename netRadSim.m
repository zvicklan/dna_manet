% netRadSim
% ZV 2/26/2021
% Want to play with a ratio of the velocity and range and how long the
% connection lasts between two nodes

% Make the sim consistent
rng('default');
% close all;
clear;
clc

%Sim setup
simTime = 10; %seconds?
debugMode = 0;

%Save setup
saveDir = '..\saveData\';

%Plot characteristics
boxSize = 100;
startSize = 50;

%Node setup
numPlat1s = 50;     %numbers
numPlat2s = 5;
numPlat3s = 2;
numPlats = numPlat1s + numPlat2s + numPlat3s;
vel1 = 5;           %Speeds
vel2 = 3;
vel3 = 0;   
maxBW1 = 50e3;      %Bandwidths
maxBW2 = 200e3;
maxBW3 = 500e3;
maxBWVec = [maxBW1 * ones(numPlat1s, 1); 
    maxBW2 * ones(numPlat2s, 1); ...
    maxBW3 * ones(numPlat3s, 1)]; %total bytes?
stopPerc1 = .1;     %Prob of not moving
stopPerc2 = .5;
stopPerc3 = 1;
pathMemArr = cell(numPlats, numPlats); %memory for all nodes path to all

%create starting spots
plat1s = startSize * (rand(numPlat1s, 2) - .5);
angles = 360/5 * (0:4);
plat2s = genENSpots(angles, 15);
plat3s = [ -10 0; 10 0];
threats = [0, 40];

%Update vels
vel1s = genRandVelsStop(numPlat1s, stopPerc1, 0, vel1);
vel2s = genRandVelsStop(numPlat2s, stopPerc2, 0, vel2);
vel3s = genRandVelsStop(numPlat3s, stopPerc3, 0, vel3);

%Link setup (3 types (1-1,2; 2-2,3; 3-3)
linkRadius1 = 10;
linkRadius2 = 20;
linkRadius3 = inf;
linkFail1 = 1;%0.6;
linkFail2 = 1;%0.9;
linkFail3 = 1;

%Set up the messages to send (same for all routing strategies)
numConvos = 5;
newMsgsPerSec = 5; 
numMsgs = newMsgsPerSec + numConvos;
totalMsgs = (simTime + 1) * numMsgs; %because counting 0 and max
convoMsgPairs = getSrcDestPairs(numPlats, numConvos);
newMsgPairs = getSrcDestPairs(numPlats, totalMsgs);
msgSuccess = zeros(totalMsgs, 1);
loadMemLength = 10;
loadHistory = zeros(numPlats, simTime + 1);

%Associativity Based Routing stuff
abrTickTable = zeros(numPlats);
tickSize = 50;
msgSize = 500;
abrPathMem = createMemStruct(numPlats); %ABR memory for paths

%plot everybody
simFig = 1;
debugFig = 2;
legendHandle = 0;
for ii = 0:simTime
    %Get state information for this time stamp
    nodePosEN = [plat1s; plat2s; plat3s];
    linkMatrix1 = getPossibleLinks(nodePosEN, linkRadius1);
    
    %Get msgs for this time stamp
    newMsgs = newMsgPairs(ii*newMsgsPerSec + 1 : (ii+1)*newMsgsPerSec, :);
    nowMsgs = [convoMsgPairs; newMsgs];
    %Alternate this every time stamp to simulate a conversation
    convoMsgPairs = fliplr(convoMsgPairs); 
    
    if ii == 0 %no load history
        remainingBW = maxBWVec;
    else
        remainingBW = maxBWVec - mean(loadHistory(:, max(ii-loadMemLength, 1):ii));
    end
    linkUsageMatrix = zeros(numPlats, numPlats);
    
    %Then do the same for plat 2s to plat 3s. Note that we'll just
    %overwrite the link types
    nodePosEN2 = [plat2s; plat3s];
    linkMatrix2 = getPossibleLinks(nodePosEN2, linkRadius2);
    linkMatrix3 = 1 - eye(numPlat3s); %only 0 on diagonal
    
    %Induce failures
    linkMatrix1 = zeroRandomFields(linkMatrix1, 1-linkFail1);
    linkMatrix2 = zeroRandomFields(linkMatrix2, 1-linkFail2);
    linkMatrix3 = zeroRandomFields(linkMatrix3, 1-linkFail3);
    
    linkMatrix = combineLinks(linkMatrix1, 2*linkMatrix2, 3*linkMatrix3);
    
    %everyone pings
    theseTicks = double(linkMatrix > 0);
    abrTickTable = abrTickTable + theseTicks;
    
    %Visualize overall Sim
    figure(simFig)
    cla
    hold all
    legNet  = plot(plat1s(:,1), plat1s(:,2), 'ob');
    legComm = plot(plat2s(:,1), plat2s(:,2), 'og', 'markerfacecolor', 'g');
    legGS   = plot(plat3s(:,1), plat3s(:,2), 'ok', 'markerfacecolor', 'k');
    legUAV   = plot(threats(:,1), threats(:,2), 'or', 'markerfacecolor', 'r');
    legLinks3 = plotLinks(linkMatrix == 3, nodePosEN);
    legLinks = plotLinks(linkMatrix == 1, nodePosEN, 'b');
    legLinks2 = plotLinks(linkMatrix == 2, nodePosEN, 'g');
    
    xlabel('E')
    ylabel('N')
    title(['t = ', num2str(ii)]);
    xlim(startSize * [-1, 1])
    ylim(startSize * [-1, 1])
    legend([legNet, legComm, legGS, legUAV, legLinks3, legLinks2, legLinks], {'Net Drones', ...
        'Comm Drones', 'Ground Stations', 'Enemy UAVs', 'Gnd Links', 'G2S Links', 'Swarm Links'});
    
    %Send all msgs for this timestamp
    for mm = 1:numMsgs
        thisMsg = nowMsgs(mm,:);
        src = thisMsg(1);
        dest = thisMsg(2);
        msgInd = ii*numMsgs + mm;
        %First, we need to check if we have this path
        memPath = pathMemArr{src, dest};
        [hasRoute, success, abrPath] = readRouteABR(src, dest, abrPathMem);
        
        %ABR Stuff
        if success 
            %Now check against links
            [msgSuccess(msgInd), usedPath, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
                linkMatrix, abrPath);
            %Update each node's BW usage and BW over each link
            loadHistory(:,1) = loadHistory(:,1) + totalTx + totalRx;
            linkUsageMatrix = linkUsageMatrix + bwMatrix;
            
            fprintf('t=%d,m=%d. Using existing route for %d to %d. Success %d\n', ...
                ii, mm, src, dest, msgSuccess(msgInd));
            if ~msgSuccess(msgInd)
                %Report broken path
                [usedPath, totalTx, totalRx, bwMatrix, abrPathMem] = ...
                    fixPathABR(abrPathMem, linkMatrix, remainingBW, abrTickTable, ...
                    src, dest, usedPath(end), msgSize);
                msgSuccess(msgInd) = ~isempty(bestPath);
                %Update each node's BW usage and BW over each link
                loadHistory(:,1) = loadHistory(:,1) + totalTx + totalRx;
                linkUsageMatrix = linkUsageMatrix + bwMatrix;
                fprintf('t=%d,m=%d. Existing route broken for %d to %d. Success %d\n', ...
                    ii, mm, src, dest, msgSuccess(msgInd));
                
                %And save it so all nodes have memory
                if msgSuccess(msgInd)
                    pathMemArr = saveNewPath(pathMemArr, usedPath);
                    
                    %Save the ABR way
                    [totalTx, totalRx, bwMatrix, abrPathMem] = ...
                        saveNewPathABR(abrPathMem, usedPath, msgSize);
                    %Update each node's BW usage and BW over each link
                    loadHistory(:,1) = loadHistory(:,1) + totalTx + totalRx;
                    linkUsageMatrix = linkUsageMatrix + bwMatrix;
                end 
            end
            %super cool plotting
            if msgSuccess(msgInd) && debugMode
                legendHandle = debugPlot(debugFig, msgInd, linkMatrix, bwMatrix, ...
                    nodePosEN, src, dest, usedPath, plat1s, plat2s, plat3s, ...
                    startSize, ii, msgSuccess(msgInd), legendHandle);
            end
        end
        
%         %If so, attempt to use path
%         if ~isempty(memPath)
%             [msgSuccess(msgInd), usedPath, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
%                 linkMatrix, memPath);
%             
%             if ~msgSuccess(msgInd)
%                 %Report broken path
%                 pathMemArr = removePath(pathMemArr, oldPath, existingPath); %TODO - do I want to restart?
%                 msgSuccess(msgInd) = 0; %reinitialize to 0 each time'
%             end
%             if msgSuccess(msgInd) && debugMode
%                 %super cool plotting
%                 legendHandle = debugPlot(debugFig, msgInd, linkMatrix, bwMatrix, ...
%                     nodePosEN, src, dest, usedPath, plat1s, plat2s, plat3s, ...
%                     startSize, ii, msgSuccess(msgInd), legendHandle);
%             end
%         end
        
        if ~msgSuccess(msgInd)
            %If we need a new route, we find it
            [bestPath, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(src, dest, ...
                linkMatrix, remainingBW, abrTickTable, msgSize);
            msgSuccess(msgInd) = ~isempty(bestPath);
                
            fprintf('t=%d,m=%d. Route discovery for %d to %d. Success %d\n', ...
                ii, mm, src, dest, msgSuccess(msgInd));
            %Update each node's BW usage and BW over each link
            loadHistory(:,1) = loadHistory(:,1) + totalTx + totalRx;
            linkUsageMatrix = linkUsageMatrix + bwMatrix;
            
            
            %super cool plotting - just want to see output of discovery
            if debugMode
                legendHandle = debugPlot(debugFig, msgInd, linkMatrix, bwMatrix, ...
                    nodePosEN, src, dest, bestPath, plat1s, plat2s, plat3s, ...
                    startSize, ii, msgSuccess(msgInd), legendHandle);
            end
            
            %And save it so all nodes have memory
            if msgSuccess(msgInd)
                pathMemArr = saveNewPath(pathMemArr, bestPath);
                
                %Save the ABR way
                [totalTx, totalRx, bwMatrix, abrPathMem] = ...
                    saveNewPathABR(abrPathMem, bestPath, msgSize);
                %Update each node's BW usage and BW over each link
                loadHistory(:,1) = loadHistory(:,1) + totalTx + totalRx;
                linkUsageMatrix = linkUsageMatrix + bwMatrix;
            end
            
            % Delete routes that we don't want to keep for long term
            if mm > numConvos
                %Just check it isn't also a convo first
                if ~any(ismember(convoMsgPairs, [src, dest], 'rows')) && ...
                    ~any(ismember(convoMsgPairs, [dest, src], 'rows'))
                    [totalTx, totalRx, bwMatrix, abrPathMem] = routeDeletionPhase(src, dest, ...
                        linkMatrix, abrPathMem, msgSize);
                    %Update each node's BW usage and BW over each link
                    loadHistory(:,1) = loadHistory(:,1) + totalTx + totalRx;
                    linkUsageMatrix = linkUsageMatrix + bwMatrix;
                end
            end
        end
    end
    
    %Add ticks as well
    linkUsageMatrix = linkUsageMatrix + tickSize*theseTicks;  
    
    
    %And update
    plat1s = plat1s + vel1s;
    plat2s = plat2s + vel2s;
    plat3s = plat3s + vel3s;
    
    %Update vels
    vel1s = genRandVelsStop(numPlat1s, stopPerc1, 0, vel1);
    vel2s = genRandVelsStop(numPlat2s, stopPerc2, 0, vel2);
    vel3s = genRandVelsStop(numPlat3s, stopPerc3, 0, vel3);
    
    %Update radio usage - shift right, increment total counter
    loadHistory = [zeros(numPlats, 1), loadHistory(:, 1:loadMemLength - 1)];
    
    %Write out linkUsageMatrix to csv - network data
    filename = sprintf('%slinkUsage_t_%d.csv', saveDir, ii);
    writematrix(linkUsageMatrix, [saveDir, filename]);
end
%write out loadHistory
writematrix(loadHistory, [saveDir, 'loadHistory.csv']);
    