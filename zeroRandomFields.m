function outputMatrix = zeroRandomFields(inputMatrix, perc, symmetric)
% Zeroes out random fields with prob perc
% 
% Inputs:
%   inputMatrix - mxn matrix. Used for making links fail, but can work
%       for any matrix for any reason you want something 0d
%   perc        - scalar 0 to 1 prob of getting removed
%   symmetric   - bool to indicate if output should be symmetric
% 
% Outputs:
%   outputMatrix - inputMatrix with random fields set to 0
% 
% Test:
% inputMatrix = ones(10,10);
% perc = .1;
% outputMatrix = zeroRandomFields(inputMatrix, perc)
% outputMatrix = zeroRandomFields(inputMatrix, perc, 1)
% perc = .5;
% outputMatrix = zeroRandomFields(inputMatrix, perc)
% outputMatrix = zeroRandomFields(inputMatrix, perc, 1)
% perc = 1;
% outputMatrix = zeroRandomFields(inputMatrix, perc)
% outputMatrix = zeroRandomFields(inputMatrix, perc, 1)
% 
% History
% Created ZV 3/6/2021

if ~exist('symmetric', 'var')
    symmetric = 0;
end

randMatrix = rand(size(inputMatrix)) > perc;
if symmetric %Just use the upper diagonal draws
    upperDiag = triu(randMatrix);
    randMatrix = upperDiag | upperDiag.';
end
outputMatrix = randMatrix .* inputMatrix;
