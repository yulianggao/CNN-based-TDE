function [ qamIn ] = prbs( seed, Ns )

global ofdm;

rng(seed);
bit_seq = randi([0, 1], Ns*ofdm.Nd, ofdm.bit);
dec_seq = bi2de(bit_seq, 'left-msb');
qamIn = s2p(dec_seq, Ns, ofdm.Nd);