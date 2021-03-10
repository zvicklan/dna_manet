function [hasRoute, success, usedPath] = readRouteABR(src, ...
    dest, abrPathMem)
%Function will step through the abrPath and attempt to use it. Will kick
%out as far as it made it if it fails
% 
% 
% Tests
% abrPathMem = createMemStruct(5);
% newPath = [1, 3, 2, 5, 4];
% abrPathMem = saveNewPathABR(abrPathMem, newPath)
% links = [0 1 1 0 0;
%     1 0 1 1 1; 
%     1 1 0 0 1;
%     0 1 0 0 1;
%     0 1 1 1 0]; 
% src = 1;
% dest = 4;
% [hasRoute, success, usedPath] = useRouteABR(src, dest, links, abrPathMem)
% 
% History
% 3/9/2021 ZV - Created from useRoute

%set up output
success = 0;
usedPath = [src];

%We will step through the path and check that each node has what it needs
routing = 1;
%get an initial one b/c we want to keep this hasRoute
[hasRoute, abrRow] = getAbrRoutingEntry(src, dest, abrPathMem);
while routing
    nextStep = abrRow(4); %next neighbor
    
    usedPath = [usedPath, nextStep];
    if nextStep == dest
        success = 1;
        routing = 0;
    else
        currNode = nextStep;
        [~, abrRow] = getAbrRoutingEntry(currNode, dest, abrPathMem);
    end
end