%dnaWrapper.m
% Creates all data for the project

%Create the base dataset
allowMotion = 1;
testNodeLoss = 0;
centralityType = 'none';
numEnemies = 0;
runName = 'Control';
netRadSim(allowMotion, testNodeLoss, centralityType, numEnemies, runName);

%Then the removing nodes type
allowMotion = 0;
testNodeLoss = 1;
centTypes = {'Degree', 'Betweenness', 'Eigenvector', 'Closeness'};
for ii = 1:numel(centTypes)
    pack; %I think I'm having memory issues, so we'll try adding this
    centralityType = centTypes{ii};
    runName = centralityType;
    netRadSim(allowMotion, testNodeLoss, centralityType, numEnemies, runName);
end
    
%Then, enemy
numEnemies = 5;
testNodeLoss = 0;
centralityType = 'none';
allowMotion = 0;
netRadSim(allowMotion, testNodeLoss, centralityType, numEnemies, 'Enemies')