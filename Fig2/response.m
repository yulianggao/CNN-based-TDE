clear; clc; close all;

LineWidth = 4;
FontSize = 40;
MarkerSize = 14;

K = 5;
Nf = 64;
Fs = 200e6;
Fc = 45e6;
wn = Fc ./ (Fs / 2);
h = [fir1(K-1, Fc./(Fs/2), hamming(K)),zeros(1,Nf-K)];
csi = abs(fft(h, Nf));
csi = csi / max(csi);
csi = csi(1 : Nf/2);
csi = 20 * log10(csi);
resolution = (Fs / 1e6) / Nf;
f = (1 : Nf/2) * resolution;
plot(f, csi, 'o-', 'LineWidth', LineWidth, 'MarkerSize', MarkerSize);
hold on
plot([0, 100], [-3, -3], 'r--', 'LineWidth', LineWidth);
hold off
grid on
xlabel('Frequency (MHz)', 'FontWeight', 'bold', 'FontSize', FontSize);
ylabel('Normalized Gain (dB)', 'FontWeight', 'bold', 'FontSize', FontSize);
legend('Frequency response', '-3 dB', 'Location', 'southwest');
set(gca, 'LineWidth', LineWidth, 'FontWeight', 'bold', 'FontSize', FontSize);
t = find(csi <= -3);
fprintf(1, 'signal bandwidth: %f MHz.\n', resolution*(Nf/2-1))
fprintf(1, '3-dB   bandwidth: %f MHz.\n', resolution*(t(1)-1))
fprintf(1, '%f times.\n', (Nf/2-1)/(t(1)-1))
% h(1:K)
set(gca, 'XTick', 0:10:100);
set(gca, 'XTicklabel', {'0','10','20','30','40','50','60','70','80','90','100'})
