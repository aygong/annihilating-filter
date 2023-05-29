function T = T_matrix(vector, K)
% Return the Toeplitz matrix T
c = vector(K+1:end);
r = vector(K+1:-1:1);
T = toeplitz(c, r);