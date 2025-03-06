function [ranking, Q] = fuzzy_rsm(performance_matrix, types, lambda)
% FUZZY_RSM - Reference Set Method (RSM) dla liczb rozmytych
% performance_matrix - macierz 2D (N x M) z wartościami (średnia z liczb rozmytych)
% types - wektor określający typy kryteriów (1 = max, -1 = min)
% lambda - współczynnik kompromisu

    [m, n] = size(performance_matrix);

    % Krok 1: Znalezienie idealnych i anty-idealnych rozwiązań
    ideal = zeros(1, n);
    anti_ideal = zeros(1, n);
    for j = 1:n
        if types(j) == 1  % Maksymalizacja
            ideal(j) = max(performance_matrix(:, j));
            anti_ideal(j) = min(performance_matrix(:, j));
        else  % Minimalizacja
            ideal(j) = min(performance_matrix(:, j));
            anti_ideal(j) = max(performance_matrix(:, j));
        end
    end

    % Krok 2: Obliczenie odległości do idealnego i anty-idealnego rozwiązania
    dist_to_ideal = zeros(m, 1);
    dist_to_anti_ideal = zeros(m, 1);
    for i = 1:m
        for j = 1:n
            dist_to_ideal(i) = dist_to_ideal(i) + abs(performance_matrix(i, j) - ideal(j));
            dist_to_anti_ideal(i) = dist_to_anti_ideal(i) + abs(performance_matrix(i, j) - anti_ideal(j));
        end
    end

    % Krok 3: Obliczenie skali kompromisu (Q) - analogia do VIKOR
    Q = lambda * dist_to_anti_ideal - (1 - lambda) * dist_to_ideal;

    % Krok 4: Ranking alternatyw (sortowanie malejące)
    [~, ranking] = sort(Q, 'descend');
end
