function [ qamIn ] = prbs( seed )

global ofdm;

rng(seed);
bit_seq = randi([0, 1], ofdm.Ns*ofdm.Nd, ofdm.bit);
dec_seq = bi2de(bit_seq, 'left-msb');
qamIn = s2p(dec_seq, ofdm.Ns, ofdm.Nd);