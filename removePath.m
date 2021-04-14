function pathMemArr = removePath(pathMemArr, dsrMemPath, usedPath)
% Removes broken path info from all upstream nodes
% 
% Inputs:
%   pathMemArr  - numNodes x numNodes cell arr - if each entry is empty,
%       then there is (supposed to be) a path there
%   dsrMemPath  - Nx1 vector - the path there was supposed to be
%   usedPath    - Mx1 vector (M < N) - the path that exists
% 
% Outputs
%   pathMemArr  - the modified input struct with bad paths removed
% 
% Test
% pathMemArr = cell(4);
% newPath = [1, 4, 3, 2];
% pathMemArr = saveNewPath(pathMemArr, newPath);
% pathMemArr2 = removePath(pathMemArr, newPath, [1, 4, 3])

lenFull = numel(dsrMemPath);
lenUsed = numel(usedPath);
%Starting at the end of the used path, we will remove all downstream links
for n1 = lenUsed:-1:1
    node = usedPath(n1);
    
    %And remove downstream paths
    for n2 = lenUsed+1:lenFull
        node2 = dsrMemPath(n2);
        pathMemArr{node, node2} = [];
    end
end
