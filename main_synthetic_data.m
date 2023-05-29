clc, clear
close all

% Set the data mode: 'clean' or 'noisy'
data_mode = 'noisy';
% Set the signal-to-noise ratio (dB)
SNR = 20;
% Set the filter type: 'basic' or 'improved'
filter_type = 'improved';


%%%%%%%%%%%%%%%%%%%%% Section: Data %%%%%%%%%%%%%%%%%%%%%
% Set the number of samples
M = 5000;
% Set the sample frequency
fs = 5000;
% Compute the time increment per sample
dt = 1 / fs;
% Set the time range
time = (0:M-1)' * dt;

% Create the synthetic data
synthetic_Fs = [375, 750, 1500];
synthetic_As = [10, 7, 5];
x = zeros(length(time), 1);
for i = 1:length(synthetic_Fs)
    x = x + synthetic_As(i) * sin(2 * pi * synthetic_Fs(i) * time);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%% Section: Filter %%%%%%%%%%%%%%%%%%%%%
% Set the number of spectral lines
K = length(synthetic_Fs) * 2;
% Set the number of measurements
N = 2 * K + 1;

switch data_mode
    case 'clean'
        if SNR ~= Inf
            disp("<strong>Warning: SNR is not Inf.</strong>")
        end
        % Set the threshold
        epsilon2 = 0;
    case 'noisy'
        if SNR == Inf
            disp("<strong>Warning: SNR is Inf.</strong>")
        end
        % Add the noise
        w = normrnd(0, 1, [length(x), 1]);
        w = w / norm(w) * norm(x) * 10^(-SNR / 20); 
        x = x + w;
        % Set the threshold
        epsilon2 = max(1e-10, norm(w(1:N)));
    otherwise
        error('<strong>Error: unexpected data mode.</strong>')
end

switch filter_type
    case 'basic'
        % Run the basic annihilating filter
        coefficients = basic_annihilating_filter(x(1:N), K);
    case 'improved'
        % Set the linear mapping
        G = eye(N);
        % Run the improved annihilating filter
        coefficients = improved_annihilating_filter(G, x(1:N), N, K, epsilon2);
    otherwise
        error('<strong>Error: unexpected filter type.</strong>')
end

% Find the zeros of the Z-transform
zeroes = roots(coefficients);
% Compute the frequencies
angles = angle(zeroes);
Fs = sort(angles / (2 * pi) * fs);

% Compute the amplitudes
lhs = zeros(N, length(Fs));
for i = 1:length(Fs)
    lhs(:, i) = sin(2 * pi * Fs(i) * (0:N-1) * (1 / fs));
end
As = lsqr(lhs, x(1:N));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%% Section: Figure %%%%%%%%%%%%%%%%%%%%%
% Compute the DFT of the data
X = fftshift(fft(x));
% Set the frequency range
freq = -fs/2:fs/M:fs/2-fs/M;

% Create a plot of the results
h1 = plot(freq, abs(X), 'b-', 'Linewidth', 1); hold on
for i = 1:length(Fs)
    fprintf("|> f%d = %.2f Hz\n", i, Fs(i));
    h2 = plot([Fs(i) Fs(i)], [0 max(abs(X))/3], 'r-', 'Linewidth', 3);
end

axis([freq(1) freq(end)+1 0 3e4])

H = legend([h1 h2], 'The DFT of the signal', 'The estimated frequencies');
set(H,'Interpreter', 'latex', 'FontSize', 10, 'location', 'northeast');
Tx = xlabel('Frequency (Hz)', 'FontSize', 14);
set(Tx, 'Interpreter', 'latex');
Ty = ylabel('Magnitude', 'FontSize', 14);
set(Ty, 'Interpreter', 'latex');
set(gcf, 'position', [400, 400, 700, 350])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

