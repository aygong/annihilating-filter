function c = improved_annihilating_filter(G, a, N, K, epsilon2)
% Implement the improved annihilating filter
% Reference - https://ieeexplore.ieee.org/abstract/document/7736135
% H. Pan, T. Blu, and M. Vetterli, “Towards Generalized FRI Sampling 
% With an Application to Source Resolution in Radioastronomy,” 
% IEEE Trans. Signal Process., vol. 65, no. 4, pp. 821– 835, 2016.
% G       : the linear mapping
% a       : the set of measurements
% N       : the number of measurements
% K       : the number of spectral lines
% epsilon2: the threshold

% Compute G^{H}G
GhG = hermitian(G) * G;
% Compute G^{H}a
Gha = hermitian(G) * a;

% Compute β
beta = lsqr(G, a);
% Create T(β)
T_beta = T_matrix(beta, K);

% Create the right-hand side of (4)
rhs_4 = [zeros(2*N+1, 1); 1];
% Create the right-hand side of (5)
rhs_5 = [Gha; zeros(N-K, 1)];

% Set the iteration parameters
max_initialize = 10;
max_iteration = 100;
early_stop = true;
min_error = Inf;

% Create a matrix of zeros for storing approximation errors
errors = zeros(max_initialize, max_iteration);
    
for init = 1:max_initialize
    % Initialize the coefficients of the filter
    c0 = normrnd(0, 1, [K+1, 1]) + 1j * normrnd(0, 1, [K+1, 1]);
    cn = c0;
    % Initialize R(c_{n})
    R_cn = R_matrix(cn, N, K);

    % Create the first row of the left-hand side of (4)
    lhs_4_row_1 = [zeros(K+1, K+1), hermitian(T_beta), zeros(K+1, N), c0];
    % Create the fourth row of the left-hand side of (4)
    lhs_4_row_4 = [hermitian(c0), zeros(1, 2*N-K+1)];

    for iter = 1:max_iteration
        % Create the second row of the left-hand side of (4)
        lhs_4_row_2 = [T_beta, zeros(N-K, N-K), -R_cn, zeros(N-K, 1)];
        % Create the third row of the left-hand side of (4)
        lhs_4_row_3 = [zeros(N, K+1), -hermitian(R_cn), GhG, zeros(N, 1)];
        % Create the left-hand side of (4)
        lhs_4 = [lhs_4_row_1; lhs_4_row_2; lhs_4_row_3; lhs_4_row_4];
        
        % Guarantee the Hermitian symmetry
        lhs_4 = lhs_4 + hermitian(lhs_4);
        lhs_4 = lhs_4 * 0.5;
        
        % Solve the linear system of (4)
        solution = linsolve(lhs_4, rhs_4);
        % Update c_{n}
        cn = solution(1:K+1);
        
        % Update R(c_{n})
        R_cn = R_matrix(cn, N, K);
        
        % Create the first row of the left-hand side of (5)
        lhs_5_row_1 = [GhG, hermitian(R_cn)];
        % Create the second row of the left-hand side of (5)
        lhs_5_row_2 = [R_cn, zeros(N-K, N-K)];
        % Create the left-hand side of (5)
        lhs_5 = [lhs_5_row_1; lhs_5_row_2];
        
        % Guarantee the Hermitian symmetry
        lhs_5 = lhs_5 + hermitian(lhs_5);
        lhs_5 = lhs_5 * 0.5;
        
        % Solve the linear system of (5)
        solution = linsolve(lhs_5, rhs_5);
        % Update b_{n}
        bn = solution(1:N);
        
        % Compute the approximation error
        errors(init, iter) = norm(a - G * bn);
        
        % Update b and c
        if errors(init, iter) < min_error
            min_error = errors(init, iter);
            c = cn;
        end
        
        % Check whether to stop the iteration
        if min_error < epsilon2 && early_stop
            fprintf("|> Stop the iteration early.\n")
            fprintf("|> The minimum approx. error: %.4f\n", min_error)
            return
        end
    end
end

fprintf("|> Reach the maximum number of initializations.\n")
fprintf("|> The minimum approx. error: %.4f\n", min(errors, [], "all"))