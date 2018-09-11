function [ B ] = myinv( A )

[U,S,V] = svd(A);
T = S;
T(S~=0) = 1./S(S~=0);
B = V * T' * U';