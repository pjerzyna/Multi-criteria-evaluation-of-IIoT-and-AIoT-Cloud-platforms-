function rysuj_ranking(wyniki, metoda)
    % Funkcja rysuje wykres pozycji firm na podstawie tabeli z sumą pozycji
    % wyniki - tabela z kolumnami 'Firma' i 'SumaPozycji'
    % metoda - nazwa metody, np. 'VIKOR', 'TOPSIS' (jako string)

    % Sprawdzenie, czy tabela ma odpowiednie kolumny
    if ~ismember('Firma', wyniki.Properties.VariableNames) || ~ismember('SumaPozycji', wyniki.Properties.VariableNames)
        error('Tabela musi zawierać kolumny "Firma" oraz "SumaPozycji".');
    end

    % Posortowanie tabeli po sumie pozycji rosnąco (najlepsza firma na górze)
    wyniki = sortrows(wyniki, 'SumaPozycji', 'ascend');

    % Pobranie rozmiaru ekranu
    screenSize = get(0, 'ScreenSize'); % [x y szerokosc wysokosc]

    % Ustalenie rozmiaru okna
    figWidth = 900;
    figHeight = 600;

    % Wyznaczenie pozycji okna, aby było na środku
    figPosX = (screenSize(3) - figWidth) / 2;
    figPosY = (screenSize(4) - figHeight) / 2;

    % Wykres słupkowy
    figure('Name', ['Ranking firm na podstawie sumy pozycji - ' metoda], ...
           'NumberTitle', 'off', ...
           'Position', [figPosX, figPosY, figWidth, figHeight]);

    barh(wyniki.SumaPozycji);
    set(gca, 'YTickLabel', wyniki.Firma, 'YTick', 1:height(wyniki));
    xlabel('Suma pozycji (im mniej, tym lepiej)');
    ylabel('Firmy');
    title(['Ranking firm na podstawie sumy pozycji - ' metoda]);
    grid on;
end
