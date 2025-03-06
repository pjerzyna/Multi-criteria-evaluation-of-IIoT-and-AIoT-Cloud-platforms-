function spearman_matrix = matrix_spearman(results, methods)
    % Funkcja obliczająca macierz korelacji Spearmana bez Statistics Toolbox
    num_methods = numel(methods);
    spearman_matrix = zeros(num_methods);

    for i = 1:num_methods
        for j = i+1:num_methods
            if ismember(methods{i}, results.Properties.VariableNames) && ismember(methods{j}, results.Properties.VariableNames)
                spearman_matrix(i, j) = spearman_correlation(results{:, methods{i}}, results{:, methods{j}});
                spearman_matrix(j, i) = spearman_matrix(i, j);
            end
        end
    end
end

function rho = spearman_correlation(x, y)
    % Funkcja licząca współczynnik korelacji Spearmana bez Statistics Toolbox
    if length(x) ~= length(y)
        error('Wektory x i y muszą mieć tę samą długość.');
    end

    % Ranking zmiennych x i y (obsługa wiązanych rang)
    rx = tiedrank(x); 
    ry = tiedrank(y);

    % Obliczenie współczynnika korelacji Spearmana
    n = length(x);
    rho = 1 - (6 * sum((rx - ry).^2)) / (n * (n^2 - 1));
end

function r = tiedrank(x)
    % Funkcja do obliczania rang z obsługą wiązań
    [sorted_x, sorted_idx] = sort(x);
    ranks = 1:length(x);
    r = zeros(size(x));

    i = 1;
    while i <= length(x)
        j = i;
        while j < length(x) && sorted_x(j) == sorted_x(j + 1)
            j = j + 1;
        end
        avg_rank = mean(ranks(i:j));
        r(sorted_idx(i:j)) = avg_rank;
        i = j + 1;
    end
end
