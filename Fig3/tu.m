load('papr_ccdf.mat');

LineWidth = 4;
FontSize = 40;
MarkerSize = 14;

for i = 1 : 6
    semilogy(papr(:, i), 1-cdf(:, i), 'LineWidth', LineWidth);
    hold on;
end
hold off;
grid on;
legend({'OFDM', ...
        'DFT-S OFDM', ...
        ['Clipping ', num2str(clip(1)*100), '%'], ...
        ['Clipping ', num2str(clip(2)*100), '%'], ...
        ['SLM D = ', num2str(D(1))], ...
        ['SLM D = ', num2str(D(2))]}, ...
       'FontWeight', 'bold', 'FontSize', 34);
   
xlabel('PAPR (dB)', 'FontWeight', 'bold', 'FontSize', FontSize);
ylabel('CCDF', 'FontWeight', 'bold', 'FontSize', FontSize);

set(gca, 'LineWidth', LineWidth, 'FontWeight', 'bold', 'FontSize', FontSize);
