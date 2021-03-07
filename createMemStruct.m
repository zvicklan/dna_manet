function memArr = createMemStruct(numNodes)
% Creates a struct for memory of all nodes
% 
% Test:
% createMemStruct(10)
% 
% History
% Created 3/7/2021

memTemplate = getNodeMem(numNodes);
for ii = numNodes:-1:1
    memArr(ii) = memTemplate;
end