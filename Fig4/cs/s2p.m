function [ p ] = s2p( s, row, col )

p = reshape(s, col, row).';

