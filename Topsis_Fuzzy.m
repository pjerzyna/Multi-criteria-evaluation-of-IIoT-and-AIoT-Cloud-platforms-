function [ranking, dist_positive] = Topsis_Fuzzy(matrix_of_matrices, types)
    % Topsis_Fuzzy: Modified TOPSIS for triangular fuzzy numbers
    % matrix_of_matrices: 3D matrix containing m x n x d fuzzy values
    % types: vector of criteria types (1 for maximizing, -1 for minimizing)

    [m, n, d] = size(matrix_of_matrices); % m: alternatives, n: criteria, d: decision-makers

    % Step 1: Aggregate decision-maker evaluations using fuzzy arithmetic
    aggregated_data = zeros(m, n, 3); % Three fuzzy components: [low, mid, high]
    for k = 1:d
        aggregated_data = aggregated_data + matrix_of_matrices(:, :, k) / d; % Average over decision-makers
    end

    % Step 2: Normalize fuzzy data
    normalized_data = zeros(m, n, 3);
    for j = 1:n
        min_val = min(aggregated_data(:, j, 1)); % Min of low values
        max_val = max(aggregated_data(:, j, 3)); % Max of high values

        for i = 1:m
            % Normalize each triangular component
            normalized_data(i, j, 1) = (aggregated_data(i, j, 1) - min_val) / (max_val - min_val);
            normalized_data(i, j, 2) = (aggregated_data(i, j, 2) - min_val) / (max_val - min_val);
            normalized_data(i, j, 3) = (aggregated_data(i, j, 3) - min_val) / (max_val - min_val);
        end
    end

    % Step 3: Determine fuzzy positive and negative ideal solutions
    fp = zeros(n, 3); % Fuzzy positive ideal
    fn = zeros(n, 3); % Fuzzy negative ideal

    for j = 1:n
        if types(j) == 1 % Maximizing criterion
            fp(j, :) = max(normalized_data(:, j, :), [], 1);
            fn(j, :) = min(normalized_data(:, j, :), [], 1);
        else % Minimizing criterion
            fp(j, :) = min(normalized_data(:, j, :), [], 1);
            fn(j, :) = max(normalized_data(:, j, :), [], 1);
        end
    end

    % Step 4: Calculate fuzzy distances to ideal solutions
    dist_positive = zeros(m, 1);
    dist_negative = zeros(m, 1);

    for i = 1:m
        for j = 1:n
            dist_positive(i) = dist_positive(i) + sum((squeeze(normalized_data(i, j, :))' - fp(j, :)).^2);
            dist_negative(i) = dist_negative(i) + sum((squeeze(normalized_data(i, j, :))' - fn(j, :)).^2);
        end
    end
    dist_positive = sqrt(dist_positive);
    dist_negative = sqrt(dist_negative);

    % Step 5: Calculate fuzzy closeness coefficient
    closeness = dist_negative ./ (dist_positive + dist_negative);

    % Step 6: Create ranking
    [~, ranking] = sort(closeness, 'descend');
end
