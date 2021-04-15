%dnaWrapper.m
% Creates all data for the project

%Create the base dataset
testNodeLoss = 0;
centralityType = 'none';
runName = 'Control';
netRadSim(testNodeLoss, centralityType, runName);

%Then the removing nodes type
testNodeLoss = 1;
centTypes = {'Degree', 'Betweenness', 'Eigenvector', 'Closeness'};
for ii = 1:numel(centTypes)
    centralityType = centTypes{ii};
    runName = centralityType;
    netRadSim(testNodeLoss, centralityType, runName);
end
    