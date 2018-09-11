function [ v ] = p2s( m )

v = reshape(m.', size(m, 1) * size(m, 2), 1);

