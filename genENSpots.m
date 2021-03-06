function enSpots = genENSpots(angles, ranges)
% angles are clockwise from north, in degrees. EN spots is in unit of
% ranges
angles = angles(:);
enSpots = ranges * [sind(angles), cosd(angles)];