function [ ber ] = error_rate( sig1, sig2 )

global ofdm;

sig1 = p2s(sig1);
sig2 = p2s(sig2);
bit1 = de2bi(sig1, ofdm.bit);
bit2 = de2bi(sig2, ofdm.bit);
% [~, ser] = symerr(sig1, sig2);
[~, ber] = biterr(bit1, bit2);