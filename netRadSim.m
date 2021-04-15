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
debugMode = 1;

%Save setup
saveDir = '..\saveData\';
abrFile = [saveDir, 'abrlinks.csv'];
dsrFile = [saveDir, 'dsrlinks.csv'];

if exist(abrFile, 'file')
    delete(abrFile);
end
if exist(dsrFile, 'file')
    delete(dsrFile);
end

%Plot characteristics
boxSize = 250;

%Node setup
numPlat1s = 50;     %numbers
numPlat2s = 5;
numPlat3s = 2;
numPlats = numPlat1s + numPlat2s + numPlat3s;
vel1 = 10;           %Speeds
vel2 = 5;
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
plat1s = boxSize * (rand(numPlat1s, 2) - .5);
angles = 360/5 * (0:4);
plat2s = genENSpots(angles, 50);
plat3s = [ -10 0; 10 0];
threats = [0, 200];

%Update vels
vel1s = genRandVelsStop(numPlat1s, stopPerc1, 0, vel1);
vel2s = genRandVelsStop(numPlat2s, stopPerc2, 0, vel2);
vel3s = genRandVelsStop(numPlat3s, stopPerc3, 0, vel3);

%Link setup (3 types (1-1,2; 2-2,3; 3-3)
linkRadius1 = 50;
linkRadius2 = 100;
linkRadius3 = inf;
linkProb1 = 0.6;
linkProb2 = 0.9;
linkProb3 = 1;

%Set up the messages to send (same for all routing strategies)
numConvos = 5;
newMsgsPerSec = 5; 
numMsgs = newMsgsPerSec + numConvos;
totalMsgs = (simTime + 1) * numMsgs; %because counting 0 and max
convoMsgPairs = getSrcDestPairs(numPlats, numConvos);
newMsgPairs = getSrcDestPairs(numPlats, totalMsgs);

%Success logging info
msgSuccessABR = zeros(totalMsgs, 1);
inMemABR = zeros(totalMsgs, 1);
memSuccessABR = zeros(totalMsgs, 1);
totalBWABR = zeros(totalMsgs, 1);

msgSuccessDSR = zeros(totalMsgs, 1);
inMemDSR = zeros(totalMsgs, 1);
memSuccessDSR = zeros(totalMsgs, 1);
totalBWDSR = zeros(totalMsgs, 1);

loadMemLength = 10;
loadHistoryABR = zeros(numPlats, simTime + 1);
loadHistoryDSR = zeros(numPlats, simTime + 1);

%Associativity Based Routing stuff
abrTickTable = zeros(numPlats);
tickSize = 50;
msgSize = 500;
abrPathMem = createMemStruct(numPlats); %ABR memory for paths

%plot everybody
simFig = 1;
debugFigABR = 2;
debugFigDSR = 3;
legendHandle = 0;
for tt = 0:simTime
    %Get state information for this time stamp
    nodePosEN = [plat1s; plat2s; plat3s];
    linkMatrix1 = getPossibleLinks(nodePosEN, linkRadius1);
    
    %Get msgs for this time stamp
    newMsgs = newMsgPairs(tt*newMsgsPerSec + 1 : (tt+1)*newMsgsPerSec, :);
    nowMsgs = [convoMsgPairs; newMsgs];
    %Alternate this every time stamp to simulate a conversation
    convoMsgPairs = fliplr(convoMsgPairs); 
    
    if tt == 0 %no load history
        remainingBW = maxBWVec;
    else
        remainingBW = maxBWVec - mean(loadHistoryABR(:, max(tt-loadMemLength, 1):tt));
    end
    linkUsageABR = zeros(numPlats, numPlats);
    linkUsageDSR = zeros(numPlats, numPlats);
    
    %Then do the same for plat 2s to plat 3s. Note that we'll just
    %overwrite the link types
    nodePosEN2 = [plat2s; plat3s];
    linkMatrix2 = getPossibleLinks(nodePosEN2, linkRadius2);
    linkMatrix3 = 1 - eye(numPlat3s); %only 0 on diagonal
    
    %Induce failures
    linkMatrix1 = zeroRandomFields(linkMatrix1, 1-linkProb1, 1);
    linkMatrix2 = zeroRandomFields(linkMatrix2, 1-linkProb2, 1);
    linkMatrix3 = zeroRandomFields(linkMatrix3, 1-linkProb3, 1);
    
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
    title(['t = ', num2str(tt)]);
    xlim(boxSize * [-1, 1])
    ylim(boxSize * [-1, 1])
    legend([legNet, legComm, legGS, legUAV, legLinks3, legLinks2, legLinks], {'Net Drones', ...
        'Comm Drones', 'Ground Stations', 'Enemy UAVs', 'Gnd Links', 'G2S Links', 'Swarm Links'});
    
    %Send all msgs for this timestamp
    for mm = 1:numMsgs
        thisMsg = nowMsgs(mm,:);
        src = thisMsg(1);
        dest = thisMsg(2);
        msgInd = tt*numMsgs + mm;
        
        %instantiate counts for message usage
        linkUsageABRmsg = zeros(numPlats, numPlats);
        linkUsageDSRmsg = zeros(numPlats, numPlats);
        
        %First, we need to check if we have this path
        dsrMemPath = pathMemArr{src, dest};
        inMemDSR(msgInd) = ~isempty(dsrMemPath);
        [hasRoute, inMemABR(msgInd), abrMemPath] = readRouteABR(src, dest, abrPathMem);
        
        %%%%%%%%%%%%%%%        First, ABR Stuff
        if inMemABR(msgInd) 
            %Now check against links
            [memSuccessABR(msgInd), usedPathABR, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
                linkMatrix, abrMemPath);
            %Update each node's BW usage and BW over each link
            loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
            linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
            
            fprintf('t=%d,m=%d. Using existing route for %d to %d. Success %d\n', ...
                tt, mm, src, dest, memSuccessABR(msgInd));
            if ~memSuccessABR(msgInd)
                %Report broken path
                [usedPathABR, totalTx, totalRx, bwMatrix, abrPathMem] = ...
                    fixPathABR(abrPathMem, linkMatrix, remainingBW, abrTickTable, ...
                    src, dest, usedPathABR(end), msgSize);
                msgSuccessABR(msgInd) = ~isempty(usedPathABR);
                %Update each node's BW usage and BW over each link
                loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
                linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
                fprintf('t=%d,m=%d. Existing route broken for %d to %d. Success %d\n', ...
                    tt, mm, src, dest, msgSuccessABR(msgInd));
                
                %And save it so all nodes have memory
                if msgSuccessABR(msgInd)                    
                    %Save the ABR way
                    [totalTx, totalRx, bwMatrix, abrPathMem] = ...
                        saveNewPathABR(abrPathMem, usedPathABR, msgSize);
                    %Update each node's BW usage and BW over each link
                    loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
                    linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
                end 
            else 
                %Write this as our success
                msgSuccessABR(msgInd) = memSuccessABR(msgInd);
            end
            %super cool plotting
            if msgSuccessABR(msgInd) && debugMode
                legendHandle = debugPlot(debugFigABR, msgInd, linkMatrix, linkUsageABRmsg, ...
                    nodePosEN, src, dest, usedPathABR, plat1s, plat2s, plat3s, ...
                    boxSize, tt, msgSuccessABR(msgInd), legendHandle, 'ABR');
            end
        end
        
        % ABR route Discovery
        if ~msgSuccessABR(msgInd)
            %If we need a new route, we find it
            [bestPath, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(src, dest, ...
                linkMatrix, remainingBW, abrTickTable, msgSize);
            msgSuccessABR(msgInd) = ~isempty(bestPath);
                
            fprintf('t=%d,m=%d. Route discovery for %d to %d. Success %d\n', ...
                tt, mm, src, dest, msgSuccessABR(msgInd));
            %Update each node's BW usage and BW over each link
            loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
            linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
            
            
            %super cool plotting - just want to see output of discovery
            if debugMode
                legendHandle = debugPlot(debugFigABR, msgInd, linkMatrix, linkUsageABRmsg, ...
                    nodePosEN, src, dest, bestPath, plat1s, plat2s, plat3s, ...
                    boxSize, tt, msgSuccessABR(msgInd), legendHandle, 'ABR');
            end
            
            %And save it so all nodes have memory
            if msgSuccessABR(msgInd)
                %Save the ABR way
                [totalTx, totalRx, bwMatrix, abrPathMem] = ...
                    saveNewPathABR(abrPathMem, bestPath, msgSize);
                %Update each node's BW usage and BW over each link
                loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
                linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
            end
            
            % Delete routes that we don't want to keep for long term
            if mm > numConvos
                %Just check it isn't also a convo first
                if ~any(ismember(convoMsgPairs, [src, dest], 'rows')) && ...
                    ~any(ismember(convoMsgPairs, [dest, src], 'rows'))
                    [totalTx, totalRx, bwMatrix, abrPathMem] = routeDeletionPhase(src, dest, ...
                        linkMatrix, abrPathMem, msgSize);
                    %Update each node's BW usage and BW over each link
                    loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
                    linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
                end
            end
        end
        linkUsageABR = linkUsageABR + linkUsageABRmsg;
        totalBWABR(msgInd) = sum(loadHistoryABR(:,1), 'all');
        %%%%%%%%%%%%%%%%%%% DSR stuff
        dsrTry = 0;
        %If we have one, attempt to use the path
        if inMemDSR(msgInd)
            [memSuccessDSR(msgInd), usedPathDSR, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
                linkMatrix, dsrMemPath);
            %Update each node's BW usage and BW over each link
            loadHistoryDSR(:,1) = loadHistoryDSR(:,1) + totalTx + totalRx;
            linkUsageDSRmsg = linkUsageDSRmsg + bwMatrix;
            if ~memSuccessDSR(msgInd)
                %Report broken path
                pathMemArr = removePath(pathMemArr, dsrMemPath, usedPathDSR); 
            else
                msgSuccessDSR(msgInd) = memSuccessDSR(msgInd);
            end
        else
            usedPathDSR = dsrMemPath;
        end
        %If we couldn't find one or it was bad find a new route
        if ~memSuccessDSR(msgInd)
            %Find new path for DSR (for now, same algorithm)
            numTriesDSR = 3;
            for dsrTry = 1:numTriesDSR
                %Get a path
                [newPath, totalTx, totalRx, bwMatrix] = routeDiscoveryDSR(src, dest, ...
                    linkMatrix, pathMemArr, msgSize);
                msgSuccessDSR(msgInd) = ~isempty(newPath);
                %Update each node's BW usage and BW over each link
                loadHistoryDSR(:,1) = loadHistoryDSR(:,1) + totalTx + totalRx;
                linkUsageDSRmsg = linkUsageDSRmsg + bwMatrix;

                if ~msgSuccessDSR(msgInd)
                    %No path found
                    usedPathDSR = [];
                    break;
                end
                
                %Else, try to use the path
                [msgSuccessDSR(msgInd), usedPathDSR, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
                    linkMatrix, newPath);
                %Update each node's BW usage and BW over each link
                loadHistoryDSR(:,1) = loadHistoryDSR(:,1) + totalTx + totalRx;
                linkUsageDSRmsg = linkUsageDSRmsg + bwMatrix;
                
                if msgSuccessDSR(msgInd)
                    msgSuccessDSR(msgInd) = dsrTry; %store the # tries
                    pathMemArr = saveNewPath(pathMemArr, newPath);
                    break; %found it, so stop
                else
                    %Path didn't work. Try another one
                    %Report broken path
                    fprintf('DSR: Try %d: Attempted broken memPath\n', dsrTry);
                    disp(newPath(:).');
                    disp(usedPathDSR(:).');
                    
                    pathMemArr = removePath(pathMemArr, newPath, usedPathDSR); 
                    %We aren't removing the path here b/c we want to see
                    %what it looked like
                    continue;
                end
            end
            fprintf('t=%d,m=%d. DSR route discovery for %d to %d. Success %d on try %d\n', ...
                tt, mm, src, dest, msgSuccessDSR(msgInd), dsrTry);
        end
        if debugMode
            %super cool plotting
            legendHandle = debugPlot(debugFigDSR, msgInd, linkMatrix, linkUsageDSRmsg, ...
                nodePosEN, src, dest, usedPathDSR, plat1s, plat2s, plat3s, ...
                boxSize, tt, msgSuccessDSR(msgInd), legendHandle, 'DSR');
        end
        %Add the total link usage for this message to the total for the
        %time period
        linkUsageDSR = linkUsageDSR + linkUsageDSRmsg;
        totalBWDSR(msgInd) = sum(loadHistoryDSR(:,1), 'all');
    end
    
    %Add ticks as well
    linkUsageABR = linkUsageABR + tickSize*theseTicks;  
    
    
    %And update
    plat1s = plat1s + vel1s;
    plat2s = plat2s + vel2s;
    plat3s = plat3s + vel3s;
    
    %Update vels
    vel1s = genRandVelsStop(numPlat1s, stopPerc1, 0, vel1);
    vel2s = genRandVelsStop(numPlat2s, stopPerc2, 0, vel2);
    vel3s = genRandVelsStop(numPlat3s, stopPerc3, 0, vel3);
    
    %Update radio usage - shift right, increment total counter
    loadHistoryABR = [zeros(numPlats, 1), loadHistoryABR(:, 1:loadMemLength - 1)];
    loadHistoryDSR = [zeros(numPlats, 1), loadHistoryDSR(:, 1:loadMemLength - 1)];
    
    %Write out linkUsageMatrix to csv - network data
    writeTimeData(tt, linkUsageABR, abrFile)
    writeTimeData(tt, linkUsageDSR, dsrFile)
end
%write out loadHistory
writematrix(loadHistoryABR, [saveDir, 'loadHistoryABR.csv']);
writematrix(loadHistoryDSR, [saveDir, 'loadHistoryDSR.csv']);
    