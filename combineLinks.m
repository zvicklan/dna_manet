function combined = combineLinks(mat1, mat2, mat3)
% Combines links of 3 types. Puts each subsequent matrix in the lower right
% corner of the previous
% 
% Inputs
%   mat1 - nxn link matrix
%   mat2 - mxm (m <= n) link matrix
%   mat3 - dxd (d <= m) link matrix
% 
% Outputs:
%   combined - nxn link matrix
% 
% Test
% mat1 = ones(10);
% mat2 = 2*ones(5);
% mat3 = 3*ones(3);
% combined = combineLinks(mat1, mat2, mat3)
% 
% History
% ZV 3/7/2021 Created

n = size(mat1, 1);
m = size(mat2, 1);
d = size(mat3, 1);

combined = mat1;
combined(n-m+1:end, n-m+1:end) = mat2;
%Zero out these last columns and rows (prevent 1-3 communication)
combined(n-d+1:end, 1:n-m) = 0;
combined(1:n-m, n-d+1:end) = 0;

combined(n-d+1:end, n-d+1:end) = mat3;
