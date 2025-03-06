function [ranking, Q] = VIKOR(performance_matrix, types, v)
    % VIKOR: Implementation of the VIKOR method for multi-criteria decision making
    %
    % performance_matrix: m x n matrix of performance values
    % types: vector indicating criteria types (1 for maximizing, -1 for minimizing)
    % v: weight of the strategy of "majority rule" (usually 0.5, between 0 and 1)
    %
    % Output:
    % ranking: indices of alternatives sorted in ascending order of Q
    % Q: final VIKOR score for each alternative

    [m, n] = size(performance_matrix); % m: number of alternatives, n: number of criteria

    % Step 1: Identify the ideal (best) and nadir (worst) solutions
    ideal = zeros(1, n);
    nadir = zeros(1, n);
    for j = 1:n
        if types(j) == 1 % Maximizing criterion
            ideal(j) = max(performance_matrix(:, j));
            nadir(j) = min(performance_matrix(:, j));
        else % Minimizing criterion
            ideal(j) = min(performance_matrix(:, j));
            nadir(j) = max(performance_matrix(:, j));
        end
    end

    % Step 2: Normalize the performance matrix and calculate distances
    S = zeros(m, 1); % Measure of group utility
    R = zeros(m, 1); % Measure of individual regret
    for i = 1:m
        distances = zeros(1, n);
        for j = 1:n
            % Calculate the normalized distance for each criterion
            distances(j) = abs((performance_matrix(i, j) - ideal(j)) / (ideal(j) - nadir(j)));
        end
        S(i) = sum(distances); % Aggregate distance to the ideal solution
        R(i) = max(distances); % Maximum distance for any single criterion
    end

    % Step 3: Compute the VIKOR index (Q)
    S_min = min(S); S_max = max(S);
    R_min = min(R); R_max = max(R);
    Q = zeros(m, 1);
    for i = 1:m
        Q(i) = v * (S(i) - S_min) / (S_max - S_min) + (1 - v) * (R(i) - R_min) / (R_max - R_min);
    end

    % Step 4: Rank alternatives by Q (ascending order)
    [~, ranking] = sort(Q, 'ascend');
end
