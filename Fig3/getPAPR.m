function [ papr ] = getPAPR( sig )

papr = 10 * log10(max(abs(sig.^2),[],2)./mean(abs(sig.^2),2));

