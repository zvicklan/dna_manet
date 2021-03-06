function [figHandle, xVec, meanVec] = hopPlot(refData, usedData)
%Plots the distribution of usedData according to refData
% 
% Test
% refData = [0 1 2 2 1 2];
% usedData = [1 2 3 4 3 5];
% figHandle = hopPlot(refData, usedData)

refData = refData(:);
usedData = usedData(:);

figHandle = figure();
boxplot(usedData, refData);

maxLabel = max(refData);
meanVec = zeros(maxLabel + 1, 1);
xVec = 0:maxLabel;

for ii = 0:max(refData)
    inds = (refData == ii) & (usedData > 0); %skip ones that didn't work
    theseData = usedData(inds);
    
    meanVec(ii+1) = mean(theseData);
end

hold all
plot(xVec + 1, meanVec, 'ko', 'MarkerFacecolor', 'k');
xlabel('Geodesic Path Length')
ylabel('Used Path Length');
legend('Mean Path Lengths')