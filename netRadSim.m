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
stopPerc1 = .1;
stopPerc2 = .5;
stopPerc3 = 1;
linkRadius1 = 10;
linkRadius2 = 20;
linkRadius3 = inf;

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
    cla
    hold all
    nodePosEN = [plat1s; plat2s];
    linkMatrix = getPossibleLinks(nodePosEN, linkRadius1);
    
    %Then do the same for plat 2s to plat 3s. Note that we'll just
    %overwrite the link types
    nodePosEN2 = [plat2s; plat3s];
    linkMatrix2 = getPossibleLinks(nodePosEN2, linkRadius2);
    
    linkMatrix3 = 1 - eye(numPlat3s); %only 0 on diagonal
    
    legNet  = plot(plat1s(:,1), plat1s(:,2), 'ob');
    legComm = plot(plat2s(:,1), plat2s(:,2), 'og', 'markerfacecolor', 'g');
    legGS   = plot(plat3s(:,1), plat3s(:,2), 'ok', 'markerfacecolor', 'k');
    legUAV   = plot(threats(:,1), threats(:,2), 'or', 'markerfacecolor', 'r');
    legLinks3 = plotLinks(linkMatrix3, plat3s);
    legLinks = plotLinks(linkMatrix, nodePosEN, 'b');
    legLinks2 = plotLinks(linkMatrix2, nodePosEN2, 'g');
    
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
    