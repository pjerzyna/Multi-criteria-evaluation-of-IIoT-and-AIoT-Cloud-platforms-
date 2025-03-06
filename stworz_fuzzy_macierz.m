function matrix_of_matrices = stworz_fuzzy_macierz(filepath)
% STWORZ_FUZZY_MACIERZ Wczytuje plik Excel (podany w argumencie filepath)
% i na podstawie zawartości tworzy liczbowe dane + macierz rozmytą 3D.
% Dodatkowo zapisuje tekstowe wartości rozmyte do pliku Excel z nazwą
% opartą na nazwie pliku wejściowego (np. dane_rozmyte_ekspert_1.xlsx).
% Zwraca matrix_of_matrices o wymiarach [wiersze x (kolumny-1) x 3].

    % --- 1. Wczytanie danych z pliku Excel ---
    dataSheet = 'Sheet1';
    data = readcell(filepath, 'Sheet', dataSheet);

    % --- 2. Mapowanie tekstu na liczby ---
    mapowanie = containers.Map({'H','AA','A','BL','L','M'}, [5,4,3,2,1,3]);
    filteredData = data(2:end, :); % Usunięcie wiersza nagłówkowego
    [rows, cols] = size(filteredData);
    mappedData = zeros(rows, cols);

    columnsToKeep = true(1, cols);
    for j = 1:cols
        columnValid = true;
        for i = 1:rows
            value = filteredData{i, j};
            if ischar(value) && isKey(mapowanie, value)
                mappedData(i, j) = mapowanie(value);
            elseif isnumeric(value) && ~isnan(value)
                mappedData(i, j) = value;
            else
                columnValid = false;
                break;
            end
        end
        columnsToKeep(j) = columnValid;
    end

    % Usunięcie niepoprawnych kolumn
    mappedData   = mappedData(:, columnsToKeep);
    filteredData = filteredData(:, columnsToKeep);

    % --- 3. Generowanie liczb rozmytych [left, middle, right] ---
    fuzzyData = cell(size(mappedData));
    [wiersze, kolumny] = size(mappedData);

    for i = 1:wiersze
        wartoscOstatniaKolumna = mappedData(i, end);
        if any(wartoscOstatniaKolumna == [1,2,3,4,5])
            for j = 1:kolumny-1
                x = mappedData(i, j);
                % Poniżej logika "rozszerzania" w zależności od x i kolumny "wartoscOstatniaKolumna"
                if x == 1
                    if     wartoscOstatniaKolumna == 1, nowaWartosc = [x+1, x,   x+3];
                    elseif wartoscOstatniaKolumna == 2, nowaWartosc = [x+0.5, x, x+1.5];
                    elseif wartoscOstatniaKolumna == 3, nowaWartosc = [x+0.25, x, x+0.75];
                    elseif wartoscOstatniaKolumna == 4, nowaWartosc = [x+0.125,x, x+0.375];
                    else                                 nowaWartosc = [x,   x,   x];
                    end
                elseif x == 5
                    if     wartoscOstatniaKolumna == 1, nowaWartosc = [x-1, x, x-3];
                    elseif wartoscOstatniaKolumna == 2, nowaWartosc = [x-0.5, x, x-1.5];
                    elseif wartoscOstatniaKolumna == 3, nowaWartosc = [x-0.25, x,x-0.75];
                    elseif wartoscOstatniaKolumna == 4, nowaWartosc = [x-0.125,x,x-0.375];
                    else                                 nowaWartosc = [x, x, x];
                    end
                else
                    if     wartoscOstatniaKolumna == 1, nowaWartosc = [x-1, x,   x+1];
                    elseif wartoscOstatniaKolumna == 2, nowaWartosc = [x-0.75, x,x+0.75];
                    elseif wartoscOstatniaKolumna == 3, nowaWartosc = [x-0.5, x, x+0.5];
                    elseif wartoscOstatniaKolumna == 4, nowaWartosc = [x-0.25,x, x+0.25];
                    else                                 nowaWartosc = [x,    x, x];
                    end
                end
                fuzzyData{i, j} = nowaWartosc;
            end
        end
    end

    % --- 4. Tworzenie macierzy 3D [wiersze x (kolumny-1) x 3] ---
    matrix_of_matrices = NaN(wiersze, kolumny-1, 3);
    for i = 1:wiersze
        for j = 1:kolumny-1
            if ~isempty(fuzzyData{i, j})
                matrix_of_matrices(i, j, :) = fuzzyData{i, j};
            end
        end
    end

    % --- 5. Konwersja do postaci tekstowej i zapis do pliku Excel ---
    fuzzyTextData = filteredData; 
    for i = 1:wiersze
        for j = 1:kolumny-1
            if ~isempty(fuzzyData{i, j})
                fuzzyTextData{i, j} = sprintf('(%0.2f, %0.2f, %0.2f)', fuzzyData{i, j});
            end
        end
    end

    % --- 6. Generowanie dynamicznej nazwy pliku ---
    [path, name, ~] = fileparts(filepath);
    outputFileName = fullfile(path, ['dane_rozmyte_' name '.xlsx']);

    % Zapis danych do Excela
    writecell(fuzzyTextData, outputFileName);

    % --- 7. Zapisanie pliku .mat z matrix_of_matrices ---
    save('matrix_of_matrices.mat', 'matrix_of_matrices');

    % --- 8. Informacje w konsoli ---
    fprintf('[stworz_fuzzy_macierz] Utworzono matrix_of_matrices z pliku: %s\n', filepath);
    fprintf('Zapisano także plik Excel "%s" z tekstowymi wartościami rozmytymi.\n', outputFileName);
    disp('Rozmiar matrix_of_matrices:');
    disp(size(matrix_of_matrices));
end
