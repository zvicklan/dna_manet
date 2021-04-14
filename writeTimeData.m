function writeTimeData(timeVal, data, filename)
% Writes the data into filename (csv)
% Applies a timestamp to all the data
% 
% Expects a matrix of data
% adds in columns for the row and column indices
% 
% 
% Test:
% timeVal = 1;
% data = magic(4);
% filename = 'test.csv';
% writeTimeData(timeVal, data, filename)
% timeVal = 2;
% data = data';
% writeTimeData(timeVal, data, filename)
% 
% History
% 4/11/2021 ZV created

useLinkTypes = 0; %set to 1 if you want
if useLinkTypes
    useLinkTypes = 1;
end
[numRows, numCols] = size(data);
% First, manipulate the data
vecSame = ones(numRows, 1);
vecDiff = (1:numCols).';
rows = kron(vecDiff, vecSame);
cols = kron(vecSame, vecDiff);
dataTransp = data';
dataVec = dataTransp(:); %b/c MATLAB does this by going down columns and we want rows
timeVec = repmat(timeVal, numRows * numCols, 1);

%useLinkTypes toggles using Link types (otherwise all same)
agentLinkStrs = getAgentLinkInfo(useLinkTypes * rows, useLinkTypes * cols); 
allData = [agentLinkStrs(:,1), num2cell(rows), agentLinkStrs(:,2), num2cell(cols), ...
    num2cell(dataVec), agentLinkStrs(:,3), num2cell(timeVec)];
%Write out. We don't need to do anything special to create the file
writecell(allData, filename, 'WriteMode', 'append');