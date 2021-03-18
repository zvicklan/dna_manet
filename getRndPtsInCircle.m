function enPts = getRndPtsInCircle(numPts, radius)
% Creates points within radius with a constant pdf
% 
% Inputs:
%   numPts - scalar - number of points to make
%   radius - scalar - radius of allowed circle
% 
% Outputs
%   enPts - numPtsx2 matrix - east north points
% 
% Test
% enPts = getRndPtsInCircle(10000, 10);
% plot(enPts(:,1), enPts(:,2), '.');
% axis square
% 
% History
% 3/11/2021 ZV Created

angles = 2*pi*rand(numPts,1);
%Want linearly increasing probability over radius. Do this by adding two
%rands (0, 2). abs(this) = linearly decreasing prob from 0 to 1. Switch it
%by doing 1 - this
lengths = 1 - abs(rand(numPts,1) + rand(numPts, 1) - 1);
lengths = radius * lengths;

%Using angles as clockwise from north
enPts = lengths.* [sin(angles), cos(angles)];