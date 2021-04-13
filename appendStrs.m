function strVec = appendStrs(inputStr, numVec)
% creates strs with the string and number
% e.g. input 'Agent' and numbers [1,2,3] for {'Agent1', 'Agent2', 'Agent3'}
% 
% Test
% appendStrs('Agent', [1, 2, 3]')

strVec = cell(size(numVec));

for ii = 1:numel(numVec)
    strVec{ii} = [inputStr, num2str(numVec(ii))];
end
