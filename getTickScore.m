function tickScore = getTickScore(path, tickMatrix, threshold)
% Tells the total number of steps in the path that have that threshold in
% ticks. If threshold is not provided, returns the sum of the ticks
% 
% Test
% path = [1 3 2];
% tickMatrix = [0 0 100; 0 0 5; 60 11 0];
% tickScore = getTickScore(path, tickMatrix, 10)
% tickScore = getTickScore(path, tickMatrix, 15)
% tickScore = getTickScore(path, tickMatrix)
% 
% History
% 3/10/2021 Created ZV to support ABR

usingThreshold = exist('threshold', 'var');
tickScore = 0;
numSteps = numel(path) - 1;
for ss = 1:numSteps
    tickVal = tickMatrix(path(ss), path(ss + 1));
    if usingThreshold
        tickScore = tickScore + double(tickVal >= threshold);
    else
        tickScore = tickScore + tickVal;
    end
end
