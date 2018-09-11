clear; clc; close all;

M = 64;
LineWidth = 4;
FontSize = 50;
MarkerSize = 11;
load(['../Fig4/mat/SNR20_QAM', num2str(M), '_C32_cnn.mat']);

% IFFT
Y1 = fft(result*ofdm.nc, [], 2);
% IDFT Spread
Y2 = Y1(:, 2:ofdm.Nf/2);
Y3 = ifft(Y2, [], 2);

refpts = qammod((0:M-1)', M);
R = reshape(real(Y3), 1, ofdm.test * ofdm.Nd);
I = reshape(imag(Y3), 1, ofdm.test * ofdm.Nd);
scatter(R, I);
hold on
plot(real(refpts), imag(refpts), '*', ...
     'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
hold off
box on
grid on

lim = log2(M) + mod(log2(M),2);
xlim([-lim, lim])
ylim([-lim, lim])
xlabel('Real', 'FontWeight', 'bold', 'FontSize', FontSize);
ylabel('Imaginary', 'FontWeight', 'bold', 'FontSize', FontSize);
set(gca, 'LineWidth', LineWidth, 'FontWeight', 'bold', 'FontSize', FontSize);
YTick = -lim:2:lim;
len = length(YTick);
set(gca, 'YTick', YTick);
YTicklabel = cell(1, len);
for i = 1 : len
    YTicklabel(i) = {num2str(YTick(i))};
end
set(gca, 'YTicklabel', YTicklabel);

