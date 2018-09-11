function h = omp(A, b, K)

r = b;
omega = zeros(1, K);
At = zeros(size(A, 1), K);
for i = 1 : K
    projection = zeros(K, 1);
    inds = setdiff(1:K, omega);
    for j = inds
        projection(j) = abs(A(:, j)' * r);
    end
    [~, index] = max(projection);
    omega(i) = index;
    At(:, i) = A(:, index);
    r = b - At * (myinv(At) * b);
    if norm(r) < 1e-6
        break;
    end
end

omega = sort(omega, 'ascend');
h = zeros(size(A, 2), 1);
h(omega) = myinv(A(:, omega)) * b;
