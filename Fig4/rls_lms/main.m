clear; clc; close all; dbstop if error

% Fixed parameters of OFDM
global ofdm;
ofdm.nc = 0;
ofdm.ber = 1;
ofdm.Nd = 31;
ofdm.Nf = 64;
ofdm.Ncp = 8;
ofdm.Nt = ofdm.Ncp + ofdm.Nf;
ofdm.test  = 10;
ofdm.train = 10;
ofdm.channel = 5;
ofdm.fc = 45e6;
ofdm.fs = 200e6;
ofdm.h = fir1(ofdm.channel-1,ofdm.fc/(ofdm.fs/2),hamming(ofdm.channel))';

% Alterable parameters of OFDM
ofdm.M = 16;
ofdm.bit = log2(ofdm.M);
ofdm.snr = 0;

% Set up equalizers.
eqrls = lineareq(35, rls(1,0.5));
eqrls.ResetBeforeFiltering = 0;
eqlms = lineareq(33, lms(1e-3));
eqlms.ResetBeforeFiltering = 0;

ber_rls = ones(3,7);
ber_lms = ones(3,7);
for k = 1 : 3
    ofdm.snr = 0;
    qamIn = prbs(0,ofdm.test);	
    trainTx = mod_ofdm(prbs(0,ofdm.train));
	
    for i = 1 : 7
        % Modulation
        txSig = mod_ofdm(qamIn);
        % Channel
        trainTx_filter = filter(ofdm.h,1,trainTx);
        spow = norm(trainTx_filter,2)^2/numel(trainTx_filter);
        npow = sqrt(spow * 10^(-ofdm.snr/10));
        trainRx = trainTx_filter + npow * randn(size(trainTx_filter));
        equalize(eqrls,trainRx,trainTx);
	    equalize(eqlms,trainRx,trainTx);
        
        txSig_filter = filter(ofdm.h,1,txSig);
        spow = norm(txSig_filter,2)^2/numel(txSig_filter);
        npow = sqrt(spow * 10^(-ofdm.snr/10));
        rxSig = txSig_filter + npow * randn(size(txSig_filter));
        % Demodulation
		ber_rls(k,i) = dem_ofdm(rxSig,eqrls,true,qamIn);
		ber_lms(k,i) = dem_ofdm(rxSig,eqlms,true,qamIn);
        original_ber = dem_ofdm(rxSig,0,false,qamIn);
        fprintf('%dQAM SNR = %d RLS: %f -> %f DD-LMS: %f -> %f\n', ...
			ofdm.M, ofdm.snr, ...
			original_ber, ber_rls(k,i), ...
			original_ber, ber_lms(k,i));
        ofdm.snr = ofdm.snr + 5;
    end
    ofdm.M = ofdm.M * 2;
    ofdm.bit = log2(ofdm.M);
    fprintf('\n');
end

% save('ber_rls.mat', 'ber_rls');
% save('ber_lms.mat', 'ber_lms');
