function c = basic_annihilating_filter(a, K)
% Implement the annihilating filter
% Reference - https://user.it.uu.se/~ps/SAS-new.pdf
% P. Stoica and R. L. Moses, Spectral analysis of signals. 
% Pearson Prentice Hall, Upper Saddle River, NJ, 2005.
% a: the set of measurements
% K: the number of spectral lines

% Create the right-hand side
lhs = zeros(K, K);
for i = 0:K-1
    lhs(:, i+1) = a(K-i:2*K-i-1);
end

% Create the left-hand side
rhs = -a(K+1:2*K);

% Solve the linear system
solution = linsolve(lhs, rhs);

% Obtain the coefficients of the filter
c = [1; solution];