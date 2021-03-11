function [srcHasRoute, success, abrPath] = readRouteABR(src, dest, abrPathMem)
%Function will step through the abrPath and attempt to use it. Will kick
%out as far as it made it if it fails
% 
% 
% Tests
% abrPathMem = createMemStruct(5);
% newPath = [1, 3, 2, 5, 4];
% [~,~,~,abrPathMem] = saveNewPathABR(abrPathMem, newPath)
% src = 1;
% dest = 4;
% [hasRoute, success, usedPath] = readRouteABR(src, dest, abrPathMem)
% [hasRoute, success, usedPath] = readRouteABR(src, 5, abrPathMem)
% 
% History
% 3/9/2021 ZV - Created from useRoute

%set up output
success = 0;
abrPath = src;
srcHasRoute = 0;

%We will step through the path and check that each node has what it needs
routing = 1;
currNode = src;

%Loop through and try to make a path
while routing
    [hasRoute, abrRow] = getAbrRoutingEntry(src, dest, currNode, abrPathMem);
    if ~hasRoute
        return;
    end
    if routing == 1
        srcHasRoute = hasRoute;
    end
    nextStep = abrRow(4); %next neighbor
    
    abrPath = [abrPath, nextStep];
    if nextStep == dest
        success = 1;
        routing = 0;
    else
        currNode = nextStep;
        routing = routing + 1;
    end
end