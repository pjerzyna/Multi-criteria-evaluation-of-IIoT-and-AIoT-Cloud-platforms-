function tabela_sum_poziomow = sumuj_poziomy_rankingow(varargin)
    % varargin to lista struktur np. sorted_data_topsis_2025_02_13_01_14_55, sorted_data_topsis_2025_02_13_01_16_32
    % Funkcja sumuje pozycje firm z kilku rankingów
    % Zakładam, że pierwszy argument jest tablicą komórkową z danymi np. sorted_data_topsis_...
    % Funkcja zwraca tabelę z nazwą firmy i sumą jej pozycji we wszystkich rankingach

    % Tworzymy mapę do sumowania pozycji firm
    suma_poziomow = containers.Map('KeyType', 'char', 'ValueType', 'double');

    for k = 1:nargin
        ranking = varargin{k}; % Każdy ranking (np. sorted_data_topsis_...)
        for i = 1:size(ranking, 1)
            firma = ranking{i, 1}; % Nazwa firmy
            if isKey(suma_poziomow, firma)
                suma_poziomow(firma) = suma_poziomow(firma) + i; % Dodajemy pozycję w rankingu
            else
                suma_poziomow(firma) = i; % Inicjalizujemy pozycję w rankingu
            end
        end
    end

    % Konwersja mapy na tabelę
    firmy = keys(suma_poziomow);
    suma_pozycji = values(suma_poziomow);
    tabela_sum_poziomow = table(firmy', cell2mat(suma_pozycji'), 'VariableNames', {'Firma', 'SumaPozycji'});
end
