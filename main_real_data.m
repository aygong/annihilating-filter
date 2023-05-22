clc, clear

% Set the data mode: 'clean' or 'noisy'
data_mode = 'noisy';
% Set the filter type: 'basic' or 'improved'
filter_type = 'improved';


%%%%%%%%%%%%%%%%%%%%% Section: Data %%%%%%%%%%%%%%%%%%%%%
switch data_mode
    case 'clean'
        % Read the clean real data
        [x, fs] = audioread('data/Clean bass.wav');
        % Set the threshold
        epsilon2 = 0;
    case 'noisy'
        % Read the noisy real data
        [x, fs] = audioread('data/Noisy bass.wav');
        % Set the threshold
        epsilon2 = 1e-10;
    otherwise
        error('Unexpected data mode.')
end

% Set the number of samples
M = 200000;
% Use the first M samples in the first channel
x = x(1:M, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%% Section: Figure %%%%%%%%%%%%%%%%%%%%%
% Compute the DFT of the data
X = fftshift(fft(x));
% Set the frequency range
freq = -fs/2:fs/M:fs/2-fs/M;

% Create a plot of the DFT
figure('Name','The DFT')

h = plot(freq, abs(X), 'b-', 'Linewidth', 1); 
xlim([0 500]);

H = legend(h, 'The DFT of the signal');
set(H,'Interpreter', 'latex', 'FontSize', 12, 'location', 'northeast');
Tx = xlabel('Frequency (Hz)', 'FontSize', 14);
set(Tx, 'Interpreter', 'latex');
Ty = ylabel('Magnitude', 'FontSize', 14);
set(Ty, 'Interpreter', 'latex');
set(gcf, 'position', [400, 400, 700, 350])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%% Section: Filter %%%%%%%%%%%%%%%%%%%%%
% Set the number of spectral lines
K = 24;
% Set the number of measurements
N = 2 * K + 200;

switch filter_type
    case 'basic'
        % Run the annihilating filter
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
frequencies = sort(angles / (2 * pi) * fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%% Section: Figure %%%%%%%%%%%%%%%%%%%%%
% Create a plot of the results
figure('Name','The results')

h1 = plot(freq, abs(X), 'b-', 'Linewidth', 1); hold on
for i = 1:length(frequencies)
    fprintf("|> f%d = %.2f Hz\n", i, frequencies(i));
    h2 = plot([frequencies(i) frequencies(i)], [0 max(abs(X))/3], 'r-', 'Linewidth', 3);
end

axis([freq(1) freq(end)+1 0 1e4])

H = legend([h1 h2], 'The DFT of the signal', 'The estimated frequencies');
set(H,'Interpreter', 'latex', 'FontSize', 10, 'location', 'northeast');
Tx = xlabel('Frequency (Hz)', 'FontSize', 14);
set(Tx, 'Interpreter', 'latex');
Ty = ylabel('Magnitude', 'FontSize', 14);
set(Ty, 'Interpreter', 'latex');
set(gcf, 'position', [400, 400, 700, 350])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

