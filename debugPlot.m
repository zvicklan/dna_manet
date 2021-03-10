function legendHandle = debugPlot(debugFig, msgInd, allLinks, bwMatrix, ...
    nodePosEN, src, dest, path, plat1s, plat2s, plat3s, startSize, ...
    timeStamp, msgSuccess, legendHandle)
%Just a wrapper to help with plotting
% needs to keep the pointer to the legend, so it's returned

figure(debugFig)
cla
hold all;
xlabel('E')
ylabel('N')
title(sprintf('t = %d, m = %d, success = %d', ...
    timeStamp, msgInd, msgSuccess))
if legendHandle ~= 0
    set(legendHandle, 'Visible', 'Off');
end
%Plotting SRC and DEST twice so visible for debugging
legAllLinks = plotLinks(allLinks, nodePosEN, 'k', 5);
plotSrcDest(src, dest, nodePosEN);
legUsedLinks = plotLinks(bwMatrix, nodePosEN, 'y', 3);
plotSrcDest(src, dest, nodePosEN);
legNet  = plot(plat1s(:,1), plat1s(:,2), 'ob');
legComm = plot(plat2s(:,1), plat2s(:,2), 'ob', 'markerfacecolor', 'b');
legGS   = plot(plat3s(:,1), plat3s(:,2), 'ok', 'markerfacecolor', 'k');
if ~isempty(path)
    legPath = plotPath(path, allLinks, nodePosEN, 'g');
else
    legPath = plot(nodePosEN(1) * ones(2,1), nodePosEN(2) * ones(2,1), 'g');
end
[legSrc, legDest] = plotSrcDest(src, dest, nodePosEN);
legendHandle = legend([legSrc, legDest, legNet, legComm, legGS, legAllLinks, ...
    legUsedLinks, legPath], ...
    {'Src', 'Dest', 'Net Drones', 'Comm Drones', ...
    'Ground Stations', 'All Links', 'Used Links', 'Best Path'});
xlim(startSize * [-1, 1])
ylim(startSize * [-1, 1])