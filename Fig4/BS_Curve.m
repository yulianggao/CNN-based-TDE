clear; clc; close all; dbstop if error

M = 6;
LineWidth = 4;
FontSize = 40;
MarkerSize = 14;

snr = 0 : 5 : 30;
switch M
    case 4
        col = 1;
    case 5
        col = 2;
    case 6
        col = 3;
    otherwise
        col = 1;
end

figure(1)
% set(1,'Position',get(0,'ScreenSize'))

load('rls_lms/ber_rls.mat');
semilogy(snr,ber_rls(col,:),'*-','LineWidth',LineWidth,'MarkerSize',MarkerSize);
hold on
load('cs/ber_omp.mat');
semilogy(snr,ber_omp(col,:),'*-','LineWidth',LineWidth,'MarkerSize',MarkerSize);
hold on
load('mat/ber_cnn.mat');
semilogy(snr,ber_cnn(col,:),'o-','LineWidth',LineWidth,'MarkerSize',MarkerSize);
hold on
plot([0,max(snr)],[3.8*1e-3, 3.8*1e-3],'r--','LineWidth',LineWidth);
hold off

grid on
xlim([0,max(snr)]);
legend('RLS', 'OMP', 'Ours', ...
    'FEC limit: 3.8 \times 10^{-3}', 'Location', 'southwest');

xlabel('SNR (dB)', 'FontWeight', 'bold', 'FontSize', FontSize);
ylabel('BER', 'FontWeight', 'bold', 'FontSize', FontSize);
set(gca, 'YTick', [1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1]);
set(gca, 'YTicklabel', ...
   {'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','10^{0}'})
set(gca,'LineWidth',LineWidth,'FontWeight','bold','FontSize',FontSize);

