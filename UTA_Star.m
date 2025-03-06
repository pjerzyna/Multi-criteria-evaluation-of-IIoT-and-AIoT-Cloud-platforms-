function [ranking, deviations] = UTA_Star(matrix_of_matrices, types, distance_metric)
    % UTA_Star: Implementation of the UTA* method for fuzzy multi-criteria analysis

    % Set default distance metric if not provided
    if nargin < 3 || isempty(distance_metric)
        distance_metric = 'euclidean';
    end

    % Get dimensions
    [m, n, d] = size(matrix_of_matrices);
    disp(['Liczba kryteriów w matrix_of_matrices: ', num2str(n)]);

    % Wymuszenie 5 kryteriów w macierzy wejściowej
    if n < 5
        missing_cols = 5 - n;
        matrix_of_matrices(:, end+1:end+missing_cols, :) = 0;
        n = 5;
    end

    % Dopasowanie długości types do 5 kryteriów
    if length(types) < 5
        types = [types, -1]; % Ostatnie kryterium minimalizowane
    end

    % Step 1: Agregacja ocen rozmytych
    aggregated_data = mean(matrix_of_matrices, 3);

    % Step 2: Normalizacja wartości kryteriów
    normalized_data = zeros(m, n);
    for j = 1:n
        min_val = min(aggregated_data(:,j));
        max_val = max(aggregated_data(:,j));
        if max_val > min_val
            if types(j) == 1  % Maksymalizacja
                normalized_data(:,j) = (aggregated_data(:,j) - min_val) / (max_val - min_val);
            else  % Minimalizacja
                normalized_data(:,j) = (max_val - aggregated_data(:,j)) / (max_val - min_val);
            end
        else
            normalized_data(:,j) = ones(m, 1);
        end
    end

    % Step 3: Obliczenie funkcji użyteczności
    marginal_utility = zeros(m, n);
    num_segments = 5;

    for j = 1:n
        sorted_vals = unique(sort(normalized_data(:,j)));
        if length(sorted_vals) < num_segments
            num_segments = length(sorted_vals);
        end
        breakpoints = linspace(min(sorted_vals), max(sorted_vals), num_segments);

        for i = 1:m
            val = normalized_data(i,j);
            segment = find(breakpoints >= val, 1) - 1;
            if isempty(segment) || segment == 0
                marginal_utility(i,j) = 0;
            else
                lower = breakpoints(segment);
                upper = breakpoints(segment + 1);
                if upper > lower
                    marginal_utility(i,j) = (val - lower) / (upper - lower);
                else
                    marginal_utility(i,j) = 0;
                end
            end
        end
    end

    % Step 4: Obliczenie użyteczności globalnej
    global_utility = sum(marginal_utility, 2);
    global_utility = (global_utility - min(global_utility)) / (max(global_utility) - min(global_utility));

    % Step 5: Ranking referencyjny
    switch distance_metric
        case 'euclidean'
            reference_ranking = sum(normalized_data, 2);
        case 'spearman'
            [~, ranks] = sort(normalized_data, 1);
            reference_ranking = sum(ranks, 2);
        case 'kendall'
            reference_ranking = zeros(m,1);
            for i = 1:m
                for j = 1:m
                    if i ~= j
                        n_concordant = 0;
                        n_discordant = 0;
                        for k = 1:n
                            if (normalized_data(i,k) > normalized_data(j,k) && types(k) == 1) || (normalized_data(i,k) < normalized_data(j,k) && types(k) == -1)
                                n_concordant = n_concordant + 1;
                            elseif (normalized_data(i,k) < normalized_data(j,k) && types(k) == 1) || (normalized_data(i,k) > normalized_data(j,k) && types(k) == -1)
                                n_discordant = n_discordant + 1;
                            end
                        end
                        reference_ranking(i) = reference_ranking(i) + (n_concordant - n_discordant)/ (n*(n-1)/2);
                    end
                end
            end
            reference_ranking = reference_ranking/ (m-1);
        otherwise
            error('Nieznana metryka odległości: %s', distance_metric);
    end

    % Step 6: Obliczenie odchyleń
    deviations = abs(global_utility - reference_ranking);
    deviations = (deviations - min(deviations)) / (max(deviations) - min(deviations));

    % Step 7: Generowanie rankingu końcowego
    [~, ranking] = sort(global_utility, 'descend');
end
