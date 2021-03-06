function vels = genRandVelsStop(numPlats, probStop, minVel, maxVel)
% vels = genRandVelsStop(numPlats, probStop, minVel, maxVel)
% Creates a velocity East-North velocity array for the desired number of
% platforms.
% Each platform gets a random direction with a velocity within min-maxVel
% Each platform then has a random probability of being "stopped" and its
% velocity is zeroed out
% 
% Test
% genRandVelsStop(10, .5, 100, 1000)
if probStop > 1
    probStop = probStop / 100;
end

angles = 360 * randn(numPlats, 1);

%doesn't really matter if these are north or east based. We'll do north
unitVecs = [sind(angles), cosd(angles)];
speeds = minVel + rand(numPlats,1)*(maxVel - minVel);
speeds = [speeds, speeds];

isStopped = randn(numPlats, 1) < probStop;
isStopped = [isStopped, isStopped];
    
vels = isStopped .* speeds .* unitVecs;
