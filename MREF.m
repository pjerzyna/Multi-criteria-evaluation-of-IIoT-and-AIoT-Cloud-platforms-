function [ranking, min_distances] = MREF(data, types)
    % MREF - metoda wielokryterialnej optymalizacji z miarą Czebyszewa dla wartości rozmytych
    % data - macierz alternatyw (wiersze: alternatywy, kolumny: kryteria, 3. wymiar: [dolna, modalna, górna])
    % types - typy kryteriów (1 = maksymalizują, -1 = minimalizują)
    % ranking - ranking alternatyw od najlepszej do najgorszej
    % min_distances - minimalne odległości dla każdej alternatywy

    % Sprawdzanie liczby kryteriów
    [num_alternatives, num_criteria, dim3] = size(data);
    disp(['Liczba kolumn w macierzy data: ', num2str(num_criteria)]);

    % Jeśli liczba kolumn jest mniejsza niż 5, dodajemy zerowe kolumny
    if num_criteria < 5
        missing_cols = 5 - num_criteria;
        data(:, end+1:end+missing_cols, :) = 0;
        num_criteria = 5;
    end

    % Dostosowanie długości types do 5 kryteriów
    if length(types) < 5
        types = [types, -1]; % Ostatnie kryterium minimalizowane
    end

    % Punkty referencyjne (domyślnie: minimum, maksimum, mediany w każdej kolumnie)
    references = compute_fuzzy_references(data);

    % Normalizacja kryteriów
    [normalized, normalized_ref] = normalize_fuzzy_criteria(data, types, references);

    % Obliczanie odległości Czebyszewa dla wartości rozmytych
    distances = Czebyszew_Fuzzy(normalized, normalized_ref);

    % Minimalna odległość względem dowolnego punktu referencyjnego
    min_distances = min(distances, [], 2);

    % Ranking alternatyw (od najlepszej do najgorszej)
    [~, ranking_indices] = sort(min_distances);

    % Zwracanie wynikowego rankingu i odległości
    ranking = ranking_indices;
end


function references = compute_fuzzy_references(data)
    % Obliczanie punktów referencyjnych dla wartości rozmytych
    num_criteria = size(data, 2);
    references = zeros(3, num_criteria, 3); % [min, max, median]

    for i = 1:num_criteria
        criterion_data = squeeze(data(:, i, :));
        references(1, i, :) = min(criterion_data, [], 1); % Minimum
        references(2, i, :) = max(criterion_data, [], 1); % Maksimum
        references(3, i, :) = median(criterion_data, 1);  % Mediana
    end
end

function [normalized, normalized_ref] = normalize_fuzzy_criteria(data, types, references)
    [num_alternatives, num_criteria, dim3] = size(data);
    if dim3 == 1
        % Klasyczna normalizacja (2D)
        normalized = zeros(size(data));
        normalized_ref = zeros(size(references));
        for i = 1:num_criteria
            if types(i) == -1  % Minimalizacja
                min_val = min(data(:, i));
                max_val = max(data(:, i));
                normalized(:, i) = (data(:, i) - min_val) / (max_val - min_val);
                normalized_ref(:, i) = (references(:, i) - min_val) / (max_val - min_val);
            elseif types(i) == 1  % Maksymalizacja
                min_val = min(data(:, i));
                max_val = max(data(:, i));
                normalized(:, i) = (max_val - data(:, i)) / (max_val - min_val);
                normalized_ref(:, i) = (max_val - references(:, i)) / (max_val - min_val);
            end
        end
    else
        % Normalizacja dla danych fuzzy (3D)
        normalized = zeros(size(data));
        normalized_ref = zeros(size(references));
        for i = 1:num_criteria
            for j = 1:3 % Dla każdej składowej [dolna, modalna, górna]
                if types(i) == -1  % Minimalizacja
                    min_val = min(data(:, i, j));
                    max_val = max(data(:, i, j));
                    normalized(:, i, j) = (data(:, i, j) - min_val) / (max_val - min_val);
                    normalized_ref(:, i, j) = (references(:, i, j) - min_val) / (max_val - min_val);
                elseif types(i) == 1  % Maksymalizacja
                    min_val = min(data(:, i, j));
                    max_val = max(data(:, i, j));
                    normalized(:, i, j) = (max_val - data(:, i, j)) / (max_val - min_val);
                    normalized_ref(:, i, j) = (max_val - references(:, i, j)) / (max_val - min_val);
                end
            end
        end
    end
end


function distances = Czebyszew_Fuzzy(normalized, normalized_ref)
    % Obliczanie odległości Czebyszewa dla wartości rozmytych
    num_alternatives = size(normalized, 1);
    num_references = size(normalized_ref, 1);
    distances = zeros(num_alternatives, num_references);

    for i = 1:num_alternatives
        for j = 1:num_references
            % Obliczanie odległości Czebyszewa dla każdej z trzech składowych
            chebyshev_distances = abs(normalized(i, :, :) - normalized_ref(j, :, :));
            chebyshev_distances = max(chebyshev_distances, [], 3); % Maksymalna odległość dla każdej składowej
            distances(i, j) = max(chebyshev_distances); % Maksymalna wartość odległości dla całej alternatywy
        end
    end
end
