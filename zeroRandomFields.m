function outputMatrix = zeroRandomFields(inputMatrix, perc)
% Zeroes out random fields with prob perc
% 
% Inputs:
%   inputMatrix - mxn matrix. Used for making links fail, but can work
%       for any matrix for any reason you want something 0d
%   perd        - scalar 0 to 1 prob of getting removed
% 
% Outputs:
%   outputMatrix - inputMatrix with random fields set to 0
% 
% Test:
% inputMatrix = ones(10,10);
% perc = .1;
% outputMatrix = zeroRandomFields(inputMatrix, perc)
% 
% History
% Created ZV 3/6/2021

randMatrix = rand(size(inputMatrix)) > perc;

outputMatrix = randMatrix .* inputMatrix;
