% netRadSim
% ZV 2/26/2021
% Want to play with a ratio of the velocity and range and how long the
% connection lasts between two nodes

% Make the sim consistent
rng('default');
close all;

%Plot characteristics
boxSize = 100;
startSize = 50;

%Node setup
numPlat1s = 50;
numPlat2s = 5;
numPlat3s = 2;
vel1 = 5;
vel2 = 3;
vel3 = 0;
maxBW1 = 50e3;
maxBW2 = 200e3;
maxBW3 = 500e3;
totalPlats = numPlat1s + numPlat2s + numPlat3s;
maxBWVec = [maxBW1 * ones(numPlat1s, 1); 
    maxBW2 * ones(numPlat2s, 1); ...
    maxBW3 * ones(numPlat3s, 1)];

%Link setup (3 types (1-1,2; 2-2,3; 3-3)
stopPerc1 = .1;
stopPerc2 = .5;
stopPerc3 = 1;
linkRadius1 = 10;
linkRadius2 = 20;
linkRadius3 = inf;
linkFail1 = 0.6;
linkFail2 = 0.9;
linkFail3 = 1;

%Associativity Based Routing stuff
abrTickTable = zeros(totalPlats);

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

%plot everybody
figure
for ii = 0:10
    nodePosEN = [plat1s; plat2s; plat3s];
    linkMatrix1 = getPossibleLinks(nodePosEN, linkRadius1);
    
    %Then do the same for plat 2s to plat 3s. Note that we'll just
    %overwrite the link types
    nodePosEN2 = [plat2s; plat3s];
    linkMatrix2 = getPossibleLinks(nodePosEN2, linkRadius2);
    linkMatrix3 = 1 - eye(numPlat3s); %only 0 on diagonal
    
    %Induce failures
    linkMatrix1 = zeroRandomFields(linkMatrix1, 1-linkFail1);
    linkMatrix2 = zeroRandomFields(linkMatrix2, 1-linkFail2);
    linkMatrix3 = zeroRandomFields(linkMatrix3, 1-linkFail3);
    
    combinedLinkMatrix = combineLinks(linkMatrix1, 2*linkMatrix2, 3*linkMatrix3);
    
    %everyone pings
    abrTickTable = abrTickTable + double(combinedLinkMatrix > 0);
    
    %Visualize
    cla
    hold all
    legNet  = plot(plat1s(:,1), plat1s(:,2), 'ob');
    legComm = plot(plat2s(:,1), plat2s(:,2), 'og', 'markerfacecolor', 'g');
    legGS   = plot(plat3s(:,1), plat3s(:,2), 'ok', 'markerfacecolor', 'k');
    legUAV   = plot(threats(:,1), threats(:,2), 'or', 'markerfacecolor', 'r');
    legLinks3 = plotLinks(combinedLinkMatrix == 3, nodePosEN);
    legLinks = plotLinks(combinedLinkMatrix == 1, nodePosEN, 'b');
    legLinks2 = plotLinks(combinedLinkMatrix == 2, nodePosEN, 'g');
    
    xlabel('E')
    ylabel('N')
    title(['t = ', num2str(ii)]);
    xlim(startSize * [-1, 1])
    ylim(startSize * [-1, 1])
    legend([legNet, legComm, legGS, legUAV, legLinks3, legLinks2, legLinks], {'Net Drones', ...
        'Comm Drones', 'Ground Stations', 'Enemy UAVs', 'Gnd Links', 'G2S Links', 'Swarm Links'});
    pause(1)
    
    
    
    %And update
    plat1s = plat1s + vel1s;
    plat2s = plat2s + vel2s;
    plat3s = plat3s + vel3s;
    
    %Update vels
    vel1s = genRandVelsStop(numPlat1s, stopPerc1, 0, vel1);
    vel2s = genRandVelsStop(numPlat2s, stopPerc2, 0, vel2);
    vel3s = genRandVelsStop(numPlat3s, stopPerc3, 0, vel3);
end
    