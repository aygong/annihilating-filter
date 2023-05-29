function R = R_matrix(vector, N, K)
% Return the Toeplitz matrix R
c = [vector(end); zeros(N-K-1, 1)];
r = [vector(end:-1:1); zeros(N-K-1, 1)];
R = toeplitz(c, r);