function [ papr ] = slm_ofdm( qammod_in, D )

global M;
global Ns;
global Nd;
global Nf;
global Ncp;

phase = [1, -1, 1i, -1i];

% SLM
papr = zeros(Ns, 1);
hwait = waitbar(0, '0%', 'Name', ['SLM: ', num2str(D), '-groups']);
for i = 1 : Ns
    qammod_out = qammod(qammod_in(i, :), M);
    Rd = phase(randi(length(phase), D-1, Nd));
    txSig_slm = repmat(qammod_out, D-1, 1) .* Rd;
    subcarriers = [zeros(D, 1), [qammod_out; txSig_slm], ...
                   zeros(D, 1), conj([qammod_out(end:-1:1); txSig_slm(:, end:-1:1)])];
    txSig_ifft = ifft(subcarriers, Nf, 2);
    txSig_cp = [txSig_ifft(:, Nf-Ncp+1:Nf), txSig_ifft];
    nc = max(abs(txSig_cp));
    txSig_cp = txSig_cp ./ nc;
    papr(i) = min(getPAPR(txSig_cp));
    waitbar(i/Ns, hwait, ['Symbols: ', num2str(i), '/', num2str(Ns)]);
end
