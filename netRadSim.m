% netRadSim
% ZV 2/26/2021
% Want to play with a ratio of the velocity and range and how long the
% connection lasts between two nodes
function netRadSim(allowMotion, numRemoveNodes, centralityType, numEnemies, runName)
% Make the sim consistent
rng('default');
% close all;
% clear;
% clc
fclose('all');
%Sim setup
simTime = 100; %seconds?
debugMode = 0;
cutoutTime = 40;
enemyTime = 40;
gifDelay = 0.25; % this one really is seconds

%Save setup
if ~exist('runName', 'var')
    runName = 'test';
end
saveDir = ['..\saveData\', runName, '\'];
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end
if debugMode
    debugDir = [saveDir, 'debug\'];
    if ~exist(debugDir, 'dir')
        mkdir(debugDir);
    end
end

gifFile = [saveDir, 'simGif.gif'];
linkFile = [saveDir, 'links.csv'];
abrFile = [saveDir, 'abrlinks.csv'];
dsrFile = [saveDir, 'dsrlinks.csv'];

if exist(linkFile, 'file')
    delete(linkFile);
end
if exist(abrFile, 'file')
    delete(abrFile);
end
if exist(dsrFile, 'file')
    delete(dsrFile);
end

linkFd = fopen(linkFile, 'w');
abrFd = fopen(abrFile, 'w');
dsrFd = fopen(dsrFile, 'w');

%Plot characteristics
boxSize = 250;

%Node setup
numPlat1s = 50;     %numbers
numPlat2s = 5;
numPlat3s = 2;
numPlats = numPlat1s + numPlat2s + numPlat3s;
%Set speeds (allow turning off motion)
if allowMotion
    vel1 = 5;           %Speeds
    vel2 = 3;
    vel3 = 0;
else
    vel1 = 0;           %Speeds
    vel2 = 0;
    vel3 = 0;
end
maxBW1 = 150e3;      %Bandwidths
maxBW2 = 500e3;
maxBW3 = 1000e3;
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
plat2s = genENSpots(angles, 80);
plat3s = [ -50 0; 50 0];

%Set up enemy stuff
if numEnemies
    enemyAngles = 360/numEnemies * (0:(numEnemies-1));
    threatsEN = genENSpots(enemyAngles, 200);
end

%Update vels
vel1s = genRandVelsStop(numPlat1s, stopPerc1, 0, vel1);
vel2s = genRandVelsStop(numPlat2s, stopPerc2, 0, vel2);
vel3s = genRandVelsStop(numPlat3s, stopPerc3, 0, vel3);

%Link setup (3 types (1-1,2; 2-2,3; 3-3)
linkRadius1 = 50;
linkRadius2 = 200;
linkRadius3 = inf;
linkProb1 = 0.8;
linkProb2 = 0.95;
linkProb3 = 1;

%Set up the messages to send (same for all routing strategies)
numConvos = 5;
newMsgsPerSec = 5;
numMsgs = newMsgsPerSec + numConvos;
totalMsgs = (simTime + 1) * numMsgs; %because counting 0 and max
convoMsgPairs = getSrcDestPairs(numPlats, numConvos);
newMsgPairs = getSrcDestPairs(numPlats, totalMsgs);

%Success logging info
msgSuccessABR   = zeros(simTime + 1, numMsgs);
inMemABR        = zeros(simTime + 1, numMsgs);
memSuccessABR   = zeros(simTime + 1, numMsgs);
totalBWABR      = zeros(simTime + 1, numMsgs);

msgSuccessDSR   = zeros(simTime + 1, numMsgs);
inMemDSR        = zeros(simTime + 1, numMsgs);
memSuccessDSR   = zeros(simTime + 1, numMsgs);
totalBWDSR      = zeros(simTime + 1, numMsgs);

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
msgFig = 4;
bwFig = 5;
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
        remainingBW = maxBWVec - mean(loadHistoryABR(:, max(tt-loadMemLength, 1):tt), 2);
    end
    linkUsageABR = zeros(numPlats, numPlats);
    linkUsageDSR = zeros(numPlats, numPlats);
    
    %Then do the same for plat 2s to plat 3s. Note that we'll just
    %overwrite the link types
    nodePosEN2 = [plat2s; plat3s];
    linkMatrix2 = getPossibleLinks(nodePosEN2, linkRadius2);
    linkMatrix3 = 1 - eye(numPlat3s); %only 0 on diagonal
    
    %For centrality testing, use the full (un-failure-added) matrix
    unmodLinkMatrix = combineLinks(linkMatrix1, linkMatrix2, linkMatrix3);
    
    %Now do the centrality shenanigans
    if numRemoveNodes && tt == cutoutTime
        targetedNodes = getHighCentralityNodes(unmodLinkMatrix, numRemoveNodes, centralityType);
        disp(['Removing following nodes based on ', centralityType, ' centrality'])
        disp(targetedNodes(:).'); %so row vector
    end
    
    %If we're doing the enemy simulation, send enemy messages:
    if numEnemies && tt == enemyTime %only if this is nonZero
        %Find the nearest comm-net node pairs
        enemyMsgPairs = getCommNetPairs(nodePosEN, numPlat1s, numPlat2s, ...
            threatsEN, unmodLinkMatrix);
        nowMsgs = enemyMsgPairs;
        numMsgs = size(nowMsgs, 1);
    end
    if numEnemies && tt > enemyTime %only if this is nonZero
        %Just keep this going as a conversation
        %Alternate this every time stamp to simulate a conversation
        enemyMsgPairs = fliplr(enemyMsgPairs);
        nowMsgs = enemyMsgPairs;
        numMsgs = size(nowMsgs, 1);
    end
    
    %Induce failures
    linkMatrix1 = zeroRandomFields(linkMatrix1, 1-linkProb1, 1);
    linkMatrix2 = zeroRandomFields(linkMatrix2, 1-linkProb2, 1);
    linkMatrix3 = zeroRandomFields(linkMatrix3, 1-linkProb3, 1);
    
    linkMatrix = combineLinks(linkMatrix1, 2*linkMatrix2, 3*linkMatrix3);
    
    %Apply the centrality shenanigans
    if numRemoveNodes && tt >= cutoutTime
        linkMask = removeHighCentrality(unmodLinkMatrix, targetedNodes);
        linkMatrix = linkMatrix .* linkMask; %elementwise masking with 1s and 0s
    end
    
    %everyone pings
    theseTicks = double(linkMatrix > 0);
    abrTickTable = abrTickTable + theseTicks;
    
    %Visualize overall Sim
    figure(simFig)
    [hands, names] = initLegendStuff;
    cla
    hold all
    legNet  = plot(plat1s(:,1), plat1s(:,2), 'ob');
    legComm = plot(plat2s(:,1), plat2s(:,2), 'og', 'markerfacecolor', 'g');
    legGS   = plot(plat3s(:,1), plat3s(:,2), 'ok', 'markerfacecolor', 'k');
    legLinks3 = plotLinks(linkMatrix == 3, nodePosEN);
    legLinks = plotLinks(linkMatrix == 1, nodePosEN, 'b');
    legLinks2 = plotLinks(linkMatrix == 2, nodePosEN, 'g');
    [hands, names] = appendLegendStuff(hands, names, ...
        [legNet, legComm, legGS, legLinks3, legLinks2, legLinks], ...
        {'Net Drones', 'Comm Drones', 'Ground Stations', ...
        'Gnd Links', 'G2S Links', 'Swarm Links'});
    %And add the complications n stuff
    if numEnemies && tt >= enemyTime
        legUAV   = plot(threatsEN(:,1), threatsEN(:,2), 'or', 'markerfacecolor', 'r');
        [hands, names] = appendLegendStuff(hands, names, legUAV, 'Enemies');
    end
        
    if numRemoveNodes && tt >= cutoutTime
        removed = plot(nodePosEN(targetedNodes, 1), nodePosEN(targetedNodes, 2), 'rx');
        [hands, names] = appendLegendStuff(hands, names, removed, 'Removed Nodes');
    end
    
    xlabel('E')
    ylabel('N')
    title([runName, ': t = ', num2str(tt)]);
    xlim(boxSize * [-1, 1])
    ylim(boxSize * [-1, 1])
    legend(hands, names);
    
    % Capture the plot as an image
    frame = getframe(simFig);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write this out to a pretty gif 
    if tt == 0
        imwrite(imind, cm, gifFile, 'gif', 'Loopcount', inf, 'DelayTime', gifDelay);
    else
        imwrite(imind, cm, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', gifDelay);
    end
    
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
        inMemDSR(tt+1,mm) = ~isempty(dsrMemPath);
        [~, inMemABR(tt+1,mm), abrMemPath] = readRouteABR(src, dest, abrPathMem);
        
        %%%%%%%%%%%%%%%        First, ABR Stuff
        if inMemABR(tt+1,mm)
            %Now check against links
            [memSuccessABR(tt+1,mm), usedPathABR, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
                linkMatrix, abrMemPath);
            %Update each node's BW usage and BW over each link
            loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
            linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
            
            fprintf('t=%d,m=%d. Using existing route for %d to %d. Success %d\n', ...
                tt, mm, src, dest, memSuccessABR(tt+1,mm));
            if ~memSuccessABR(tt+1,mm)
                %Report broken path
                [usedPathABR, totalTx, totalRx, bwMatrix, abrPathMem] = ...
                    fixPathABR(abrPathMem, linkMatrix, remainingBW, abrTickTable, ...
                    src, dest, usedPathABR(end), msgSize);
                msgSuccessABR(tt+1,mm) = ~isempty(usedPathABR);
                %Update each node's BW usage and BW over each link
                loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
                linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
                fprintf('t=%d,m=%d. Existing route broken for %d to %d. Success %d\n', ...
                    tt, mm, src, dest, msgSuccessABR(tt+1,mm));
                
                %And save it so all nodes have memory
                if msgSuccessABR(tt+1,mm)
                    %Save the ABR way
                    [totalTx, totalRx, bwMatrix, abrPathMem] = ...
                        saveNewPathABR(abrPathMem, usedPathABR, msgSize);
                    %Update each node's BW usage and BW over each link
                    loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
                    linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
                end
            else
                %Write this as our success
                msgSuccessABR(tt+1,mm) = memSuccessABR(tt+1,mm);
            end
            %super cool plotting
            if msgSuccessABR(tt+1,mm) && debugMode
                legendHandle = debugPlot(debugFigABR, msgInd, linkMatrix, linkUsageABRmsg, ...
                    nodePosEN, src, dest, usedPathABR, plat1s, plat2s, plat3s, ...
                    boxSize, tt, msgSuccessABR(tt+1,mm), 0, 'ABR');
                saveas(debugFigABR, sprintf('%sabr_%03d', debugDir, msgInd), 'png');
            end
        end
        
        % ABR route Discovery
        if ~msgSuccessABR(tt+1,mm)
            %If we need a new route, we find it
            [bestPath, totalTx, totalRx, bwMatrix] = routeDiscoveryPhase(src, dest, ...
                linkMatrix, remainingBW, abrTickTable, msgSize);
            msgSuccessABR(tt+1,mm) = ~isempty(bestPath);
            
            fprintf('t=%d,m=%d. Route discovery for %d to %d. Success %d\n', ...
                tt, mm, src, dest, msgSuccessABR(tt+1,mm));
            %Update each node's BW usage and BW over each link
            loadHistoryABR(:,1) = loadHistoryABR(:,1) + totalTx + totalRx;
            linkUsageABRmsg = linkUsageABRmsg + bwMatrix;
            
            
            %super cool plotting - just want to see output of discovery
            if debugMode
                legendHandle = debugPlot(debugFigABR, msgInd, linkMatrix, linkUsageABRmsg, ...
                    nodePosEN, src, dest, bestPath, plat1s, plat2s, plat3s, ...
                    boxSize, tt, msgSuccessABR(tt+1,mm), 0, 'ABR');
                saveas(debugFigABR, sprintf('%sabr_%03d', debugDir, msgInd), 'png');
            end
            
            %And save it so all nodes have memory
            if msgSuccessABR(tt+1,mm)
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
        totalBWABR(tt+1,mm) = sum(loadHistoryABR(:,1), 'all');
        %%%%%%%%%%%%%%%%%%% DSR stuff
        dsrTry = 0;
        allowMem = 1; %allow discovery to use memory
        %If we have one, attempt to use the path
        if inMemDSR(tt+1,mm)
            [memSuccessDSR(tt+1,mm), usedPathDSR, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
                linkMatrix, dsrMemPath);
            %Update each node's BW usage and BW over each link
            loadHistoryDSR(:,1) = loadHistoryDSR(:,1) + totalTx + totalRx;
            linkUsageDSRmsg = linkUsageDSRmsg + bwMatrix;
            if ~memSuccessDSR(tt+1,mm)
                %Report broken path
                pathMemArr = removePath(pathMemArr, dsrMemPath, usedPathDSR);
            else
                msgSuccessDSR(tt+1,mm) = memSuccessDSR(tt+1,mm);
            end
        else
            usedPathDSR = dsrMemPath;
        end
        %If we couldn't find one or it was bad find a new route
        if ~memSuccessDSR(tt+1,mm)
            %Find new path for DSR (for now, same algorithm)
            numTriesDSR = 3;
            for dsrTry = 1:numTriesDSR
                %Get a path
                if dsrTry == numTriesDSR
                    %Get serious. Even if it's expensive
                    allowMem = 0;
                end
                [newPath, totalTx, totalRx, bwMatrix] = routeDiscoveryDSR(src, dest, ...
                    linkMatrix, pathMemArr,allowMem, msgSize);
                msgSuccessDSR(tt+1,mm) = ~isempty(newPath);
                %Update each node's BW usage and BW over each link
                loadHistoryDSR(:,1) = loadHistoryDSR(:,1) + totalTx + totalRx;
                linkUsageDSRmsg = linkUsageDSRmsg + bwMatrix;
                
                if ~msgSuccessDSR(tt+1,mm)
                    %No path found
                    usedPathDSR = [];
                    break;
                end
                
                %Else, try to use the path
                [msgSuccessDSR(tt+1,mm), usedPathDSR, totalTx, totalRx, bwMatrix] = useRoute(src, dest, ...
                    linkMatrix, newPath);
                %Update each node's BW usage and BW over each link
                loadHistoryDSR(:,1) = loadHistoryDSR(:,1) + totalTx + totalRx;
                linkUsageDSRmsg = linkUsageDSRmsg + bwMatrix;
                
                if msgSuccessDSR(tt+1,mm)
                    msgSuccessDSR(tt+1,mm) = dsrTry; %store the # tries
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
                tt, mm, src, dest, msgSuccessDSR(tt+1,mm), dsrTry);
        end
        if debugMode
            %super cool plotting
            legendHandle = debugPlot(debugFigDSR, msgInd, linkMatrix, linkUsageDSRmsg, ...
                nodePosEN, src, dest, usedPathDSR, plat1s, plat2s, plat3s, ...
                boxSize, tt, msgSuccessDSR(tt+1,mm), 0, 'DSR');
            saveas(debugFigDSR, sprintf('%sdsr_%03d', debugDir, msgInd), 'png');
        end
        %Add the total link usage for this message to the total for the
        %time period
        linkUsageDSR = linkUsageDSR + linkUsageDSRmsg;
        totalBWDSR(tt+1,mm) = sum(loadHistoryDSR(:,1), 'all');
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
    loadHistoryABR = [zeros(numPlats, 1), loadHistoryABR(:, 1:end - 1)];
    loadHistoryDSR = [zeros(numPlats, 1), loadHistoryDSR(:, 1:end - 1)];
    
    %Write out linkUsageMatrix to csv - network data
    writeTimeData(tt, linkMatrix > 0, linkFd) %output binarized link matrix
    writeTimeData(tt, linkUsageABR, abrFd)
    writeTimeData(tt, linkUsageDSR, dsrFd)
end
%Plot out the success rate and totalBW
figure(msgFig);
hold all
cLeg = plot([0, simTime], [1, 1], 'k:');
aLeg = plot(0:simTime, mean(msgSuccessABR, 2), 'b');
bLeg = plot(0:simTime, mean(msgSuccessDSR > 0, 2), 'g'); %b/c it also counts the try
xlabel('Time Period');
ylabel('Msg Success Rate');
title(['Msg Success Rate: ', runName])
legend([aLeg, bLeg, cLeg], {'ABR Msg Success', 'DSR Msg Success', '100%'})
saveas(msgFig, [saveDir, 'msgSuccess'], 'png');

figure(bwFig);
hold all
plot(0:simTime, sum(totalBWABR, 2)/1000, 'b')
plot(0:simTime, sum(totalBWDSR, 2)/1000, 'g')
plot([0, simTime], [1, 1], 'k')
xlabel('Time Period');
ylabel('Bandwidth Utilization (KB)');
title(['Bandwidth Utilization: ', runName])
legend('ABR Bandwidth', 'DSR Bandwidth', '100%')
saveas(bwFig, [saveDir, 'bandwidthUsage'], 'png');

%write out loadHistory
writematrix(loadHistoryABR, [saveDir, 'loadHistoryABR.csv']);
writematrix(loadHistoryDSR, [saveDir, 'loadHistoryDSR.csv']);
save([saveDir, 'allVars']);
fclose(linkFd);
fclose(abrFd);
fclose(dsrFd);

