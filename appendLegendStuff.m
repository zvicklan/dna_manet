function [hands, names] = appendLegendStuff(hands, names, newHands, newNames)
%append to the legend
%Really just appending to an array and cellarray
% 
% Test
% [hands, names] = initLegendStuff
% [hands, names] = appendLegendStuff(hands, names, 1, {'test'})
% [hands, names] = appendLegendStuff(hands, names, [0, 2, 3, 4, 5, 6, 7], {'Net Drones', ...
%         'Comm Drones', 'Ground Stations', 'Enemy UAVs', 'Gnd Links', 'G2S Links', 'Swarm Links'})

    
hands = [hands(:); newHands(:)];

if ~iscell(newNames)
    names{numel(names) + 1} = newNames;
else
    names = [names; newNames(:)];
end