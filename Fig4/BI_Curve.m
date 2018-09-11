clear; clc; close all; dbstop if error

M = 64;
LineWidth = 4;
FontSize = 40;
MarkerSize = 9;

load(['mat/SNR20_QAM', num2str(M), '_C16_cnn.mat']);
current_snr20_c16 = current;
current_snr20_c16(current_snr20_c16 == 0) = 1e-5;
load(['mat/SNR20_QAM', num2str(M), '_C32_cnn.mat']);
len = numel(current);
current_snr20_c32 = current;
current_snr20_c32(current_snr20_c32 == 0) = 1e-5;

figure(1);
semilogy(current_snr20_c16, '*-', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize);
hold on
semilogy(current_snr20_c32, 'o-', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize);
hold on
plot([1, len], [ofdm.ber, ofdm.ber], '--', 'LineWidth', LineWidth);
hold on
plot([1, len], [3.8*1e-3, 3.8*1e-3], 'r--', 'LineWidth', LineWidth);
hold off
grid on
xlim([1, len]);
legend('C = 16', 'C = 32', ...
       ['Baseline: ', num2str(round(ofdm.ber,4))], ...
       'FEC limit: 3.8 \times 10^{-3}', ...
       'Location', 'southwest');
xlabel('Iteration', 'FontWeight', 'bold', 'FontSize', FontSize);
ylabel('BER', 'FontWeight', 'bold', 'FontSize', FontSize);
set(gca, 'LineWidth', LineWidth, 'FontWeight', 'bold', 'FontSize', FontSize);
set(gca, 'XTick', 0:10:100);
set(gca, 'XTicklabel', ...
   {'0','10','20','30','40','50','60','70','80','90','100'})
set(gca, 'YTick', [1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1]);
set(gca, 'YTicklabel', ...
   {'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','10^{0}'})
