%dnaWrapper.m
% Creates all data for the project

%Create the base dataset
allowMotion = 1;
numRemoveNodes = 0;
centralityType = 'none';
numEnemies = 0;
runName = 'Control';
netRadSim(allowMotion, numRemoveNodes, centralityType, numEnemies, runName);

%% Then the removing nodes type
allowMotion = 1;
numRemoveNodes = [3, 5];
centTypes = {'Degree', 'Betweenness', 'Eigenvector', 'Closeness'};
for nn = 1:numel(numRemoveNodes)
    for ii = 1:numel(centTypes)
        pack; %I think I'm having memory issues, so we'll try adding this
        centralityType = centTypes{ii};
        runName = sprintf('%s-%d', centralityType, numRemoveNodes(nn));
        netRadSim(allowMotion, numRemoveNodes(nn), centralityType, numEnemies, runName);
    end
end
    
%% Then, enemy
allowMotion = 1;
numRemoveNodes = 0;
centralityType = 'none';
numEnemies = 10;
netRadSim(allowMotion, numRemoveNodes, centralityType, numEnemies, 'Enemies')