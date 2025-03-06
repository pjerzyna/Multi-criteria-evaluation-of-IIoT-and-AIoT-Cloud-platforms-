function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 10-Feb-2025 14:11:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function wczytaj_dane_Callback(hObject, eventdata, handles)
    % Wczytaj dane z pliku Excel
    try
        [file, path] = uigetfile({'*.xlsx;*.xls', 'Pliki Excel (*.xlsx, *.xls)'}, 'Wybierz plik z danymi');
        if isequal(file, 0)
            msgbox('Nie wybrano pliku.', 'Błąd', 'error');
            return;
        end

        fullpath = fullfile(path, file);

        % Sprawdzenie, który ekspert
        if contains(file, 'ekspert_1', 'IgnoreCase', true)
            handles.ekspert_nazwa = 'ekspert_1';
        elseif contains(file, 'ekspert_2', 'IgnoreCase', true)
            handles.ekspert_nazwa = 'ekspert_2';
        elseif contains(file, 'ekspert_3', 'IgnoreCase', true)
            handles.ekspert_nazwa = 'ekspert_3';
        else
            handles.ekspert_nazwa = 'nieznany_ekspert';
        end

        % Sprawdź, czy plik zawiera słowo 'ekspert'
        if contains(file, 'ekspert', 'IgnoreCase', true)
            if exist('stworz_fuzzy_macierz', 'file') == 2
                matrix_of_matrices = stworz_fuzzy_macierz(fullpath);
                assignin('base', 'matrix_of_matrices', matrix_of_matrices);
            else
                error('Funkcja stworz_fuzzy_macierz nie została znaleziona.');
            end
        end

        % Wczytaj dane z Arkusza1 (Alternatywy)
        try
            alternatywy = readtable(fullpath, 'Sheet', 'Sheet1', 'VariableNamingRule', 'preserve');
            set(handles.uitable1, 'Data', table2cell(alternatywy));
        catch
            error('Nie można wczytać danych z arkusza "Sheet1". Sprawdź nazwę arkusza i format danych.');
        end

        % Wczytaj dane z Arkusza2 (Punkty odniesienia)
        try
            punkty_odniesienia = readtable(fullpath, 'Sheet', 'Sheet2', 'VariableNamingRule', 'preserve');
            set(handles.uitable2, 'Data', table2cell(punkty_odniesienia));
        catch
            error('Nie można wczytać danych z arkusza "Sheet2". Sprawdź nazwę arkusza i format danych.');
        end

        % Rozpoznanie pliku i ustawienie parametrów
        if contains(file, 'ekspert', 'IgnoreCase', true)
            handles.types = [1, 1, 1, 1, -1];
            handles.lambda = 0.5;
        else
            handles.types = ones(1, size(alternatywy, 2) - 1);
            handles.lambda = 0.5;
        end

        % Zapisanie struktury handles
        guidata(hObject, handles);

        % Komunikat o sukcesie
        msgbox(['Dane zostały pomyślnie wczytane dla: ' handles.ekspert_nazwa], 'Sukces', 'help');

    catch ME
        msgbox(['Wystąpił błąd podczas wczytywania danych: ', ME.message], 'Błąd', 'error');
    end



% --- Executes on selection change in metoda.
function metoda_Callback(hObject, eventdata, handles)
% hObject    handle to metoda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metoda contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metoda


% --- Executes during object creation, after setting all properties.
function metoda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metoda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tworz_ranking_Callback(hObject, eventdata, handles)
    % Pobranie danych z tabel GUI
    alternatywy = get(handles.uitable1, 'Data');

    if isempty(alternatywy)
        msgbox('Brak danych w tabeli alternatyw! Wczytaj dane najpierw.', 'Błąd', 'error');
        return;
    end
    
    % Wybrana metoda
    selected_method = get(handles.metoda, 'Value');
    methods = get(handles.metoda, 'String');
    selected_method_name = methods{selected_method};

    if strcmp(selected_method_name, 'Topsis (GT)')
        % Ustawienia typów kryteriów
        handles.types = [1, 1, 1, 1, -1];

        % Odczyt danych decyzyjnych z workspace
        if evalin('base', 'exist(''matrix_of_matrices'', ''var'')')
            matrix_of_matrices = evalin('base', 'matrix_of_matrices');
        else
            errordlg('Nie znaleziono "matrix_of_matrices" w przestrzeni roboczej.', 'Błąd');
            return;
        end

        % Uruchomienie metody TOPSIS
        [ranking, dist_positive] = Topsis_Fuzzy(matrix_of_matrices, handles.types);

        % Pobranie posortowanych danych
        fullData = get(handles.uitable1, 'Data');
        sortedData = fullData(ranking, :);

        % Wyświetlenie w tabeli GUI
        set(handles.tabela_ranking, 'Data', sortedData);

        % Sprawdzenie, czy nazwa eksperta jest w handles (np. 'ekspert_1', 'ekspert_2' itp.)
        if isfield(handles, 'ekspert_nazwa')
            ekspert_nazwa = handles.ekspert_nazwa;
        else
            ekspert_nazwa = 'nieznany_ekspert';
        end

        % Generowanie nazw zmiennych w zależności od eksperta i metody
        ranking_var_name = [ekspert_nazwa '_ranking_topsis'];
        sorted_data_var_name = [ekspert_nazwa '_sorted_data_topsis'];

        % Zapis do workspace
        assignin('base', ranking_var_name, ranking);
        assignin('base', sorted_data_var_name, sortedData);

        % Komunikat o sukcesie
        msgbox(['Ranking został utworzony metodą Topsis (GT)! Dane zapisano jako: ' ranking_var_name ' i ' sorted_data_var_name], 'Sukces');


    elseif strcmp(selected_method_name, 'Metoda zbiorów odniesienia (RSM)')
    try
        % Sprawdzenie obecności danych w MATLAB Workspace
        if ~evalin('base', 'exist(''matrix_of_matrices'', ''var'')')
            errordlg('Zmienna "matrix_of_matrices" nie została znaleziona w przestrzeni roboczej.', 'Błąd');
            return;
        end
        matrix_of_matrices = evalin('base', 'matrix_of_matrices');

        % Pobranie wymiarów
        [m, n, p] = size(matrix_of_matrices);
        if m == 0 || n == 0 || p ~= 3
            errordlg('Niepoprawne wymiary macierzy "matrix_of_matrices". Oczekiwany format: (N x M x 3)', 'Błąd');
            return;
        end

        % Pobranie danych dla metody RSM
        performance_matrix = mean(matrix_of_matrices, 3); % Uśrednienie wartości rozmytych
        types = [1, 1, 1, 1, -1];
        lambda = handles.lambda;   % Parametr kompromisu

        % Uruchomienie metody RSM
        [ranking, Q] = fuzzy_rsm(performance_matrix, types, lambda);

        % Pobranie oryginalnych danych i ich sortowanie według rankingu
        if isfield(handles, 'uitable1')
            original_data = get(handles.uitable1, 'Data');
            if ~isempty(original_data) && size(original_data, 1) == m
                sorted_data = original_data(ranking, :);
                set(handles.tabela_ranking, 'Data', sorted_data);
            else
                errordlg('Błąd: Nieprawidłowe dane w "uitable1".', 'Błąd');
                return;
            end
        else
            errordlg('Błąd: "uitable1" nie istnieje w strukturze handles.', 'Błąd');
            return;
        end

        % Sprawdzenie, czy nazwa eksperta jest w handles (np. 'ekspert_1', 'ekspert_2' itp.)
        if isfield(handles, 'ekspert_nazwa')
            ekspert_nazwa = handles.ekspert_nazwa;
        else
            ekspert_nazwa = 'nieznany_ekspert';
        end

        % Generowanie nazw zmiennych w zależności od eksperta i metody
        ranking_var_name = [ekspert_nazwa '_ranking_rsm'];
        sorted_data_var_name = [ekspert_nazwa '_sorted_data_rsm'];

        % Zapisanie zmiennych do workspace
        assignin('base', ranking_var_name, ranking);
        assignin('base', sorted_data_var_name, sorted_data);

        % Komunikat o sukcesie
        msgbox(['Ranking RSM został pomyślnie utworzony! Dane zapisano jako: ' ranking_var_name ' i ' sorted_data_var_name], 'Sukces');

    catch ME
        errordlg(['Wystąpił błąd w RSM: ' ME.message], 'Błąd');
    end

   elseif strcmp(selected_method_name, 'Metoda wielu punktów odniesienia (MREF)')
    try
        % Sprawdzenie, czy matrix_of_matrices istnieje w przestrzeni roboczej
        if ~evalin('base', 'exist(''matrix_of_matrices'', ''var'')')
            errordlg('Zmienna "matrix_of_matrices" nie została znaleziona w przestrzeni roboczej.', 'Błąd');
            return;
        end
        matrix_of_matrices = evalin('base', 'matrix_of_matrices');

        % Pobranie wymiarów
        [m, n, p] = size(matrix_of_matrices);
        if m == 0 || n == 0 || p ~= 3
            errordlg('Niepoprawne wymiary macierzy "matrix_of_matrices". Oczekiwany format: (N x M x 3)', 'Błąd');
            return;
        end

        % Pobranie danych dla metody MREF
        types = [1, 1, 1, 1, -1];    % Typy kryteriów (1=max, -1=min)
        disp(types)

        % Uruchomienie metody MREF
        [ranking, min_distances] = MREF(matrix_of_matrices, types);

        % Pobranie oryginalnych danych i ich sortowanie według rankingu
        if isfield(handles, 'uitable1')
            original_data = get(handles.uitable1, 'Data');
            if ~isempty(original_data) && size(original_data, 1) == m
                sorted_data = original_data(ranking, :);
                set(handles.tabela_ranking, 'Data', sorted_data);

                % Sprawdzenie, czy nazwa eksperta jest w handles (np. 'ekspert_1', 'ekspert_2' itp.)
                if isfield(handles, 'ekspert_nazwa')
                    ekspert_nazwa = handles.ekspert_nazwa;
                else
                    ekspert_nazwa = 'nieznany_ekspert';
                end

                % Tworzenie nazw zmiennych na podstawie eksperta i metody
                ranking_var_name = [ekspert_nazwa '_ranking_mref'];
                sorted_data_var_name = [ekspert_nazwa '_sorted_data_mref'];

                % Zapisanie rankingu i posortowanych danych do workspace
                assignin('base', ranking_var_name, ranking);
                assignin('base', sorted_data_var_name, sorted_data);

                % Komunikat dla użytkownika
                msgbox(['Ranking MREF został pomyślnie utworzony i zapisany jako: ' ranking_var_name ' i ' sorted_data_var_name], 'Sukces');
            else
                errordlg('Błąd: Nieprawidłowe dane w "uitable1".', 'Błąd');
            end
        else
            errordlg('Błąd: "uitable1" nie istnieje w strukturze handles.', 'Błąd');
        end

    catch ME
        errordlg(['Wystąpił błąd w MREF: ' ME.message], 'Błąd');
    end


   elseif strcmp(selected_method_name, 'Metoda UTA*')
    try
        % Inicjalizacja typów kryteriów
        handles.types = [1; 1; 1; 1; -1]; 
        handles.lambda = 0.5;

        % Sprawdzenie, czy zmienna matrix_of_matrices istnieje w przestrzeni roboczej
        if ~evalin('base', 'exist(''matrix_of_matrices'', ''var'')')
            errordlg('Zmienna "matrix_of_matrices" nie została znaleziona w przestrzeni roboczej.', 'Błąd');
            return;
        end
        matrix_of_matrices = evalin('base', 'matrix_of_matrices');
        
        % Sprawdzenie wymiarów macierzy
        [m, n, p] = size(matrix_of_matrices);
        if m == 0 || n == 0 || p == 0
            errordlg('Niepoprawne wymiary macierzy "matrix_of_matrices".', 'Błąd');
            return;
        end

        % Uruchomienie metody UTA*
        [ranking, deviations] = UTA_Star(matrix_of_matrices, handles.types, 'spearman');

        % Pobranie oryginalnych danych i ich sortowanie według rankingu
        if isfield(handles, 'uitable1')
            original_data = get(handles.uitable1, 'Data');
            if ~isempty(original_data) && size(original_data, 1) == m
                sorted_data = original_data(ranking, :);
                set(handles.tabela_ranking, 'Data', sorted_data);

                % Sprawdzenie, czy nazwa eksperta jest w handles (np. 'ekspert_1', 'ekspert_2' itp.)
                if isfield(handles, 'ekspert_nazwa')
                    ekspert_nazwa = handles.ekspert_nazwa;
                else
                    ekspert_nazwa = 'nieznany_ekspert';
                end

                % Generowanie nazw zmiennych na podstawie eksperta i metody
                ranking_var_name = [ekspert_nazwa '_ranking_uta_star'];
                sorted_data_var_name = [ekspert_nazwa '_sorted_data_uta_star'];

                % Zapisanie rankingu i posortowanych danych do workspace
                assignin('base', ranking_var_name, ranking);
                assignin('base', sorted_data_var_name, sorted_data);

                % Komunikat dla użytkownika
                msgbox(['Ranking UTA* został pomyślnie utworzony i zapisany jako: ' ranking_var_name ' i ' sorted_data_var_name], 'Sukces');
            else
                errordlg('Błąd: Nieprawidłowe dane w "uitable1".', 'Błąd');
            end
        else
            errordlg('Błąd: "uitable1" nie istnieje w strukturze handles.', 'Błąd');
        end
        
    catch ME
        errordlg(['Wystąpił błąd w UTA*: ' ME.message], 'Błąd');
    end



    elseif strcmp(selected_method_name, 'Metoda VIKOR')
    try
        % Sprawdzenie, czy matrix_of_matrices istnieje w przestrzeni roboczej
        if ~evalin('base', 'exist(''matrix_of_matrices'', ''var'')')
            errordlg('Zmienna "matrix_of_matrices" nie została znaleziona w przestrzeni roboczej.', 'Błąd');
            return;
        end
        matrix_of_matrices = evalin('base', 'matrix_of_matrices');
        
        % Pobranie wymiarów
        [m, n, p] = size(matrix_of_matrices);
        if m == 0 || n == 0 || p == 0
            errordlg('Niepoprawne wymiary macierzy "matrix_of_matrices".', 'Błąd');
            return;
        end

        % Pobranie danych dla metody VIKOR
        performance_matrix = mean(matrix_of_matrices, 3); % Średnia ocen od decydentów
        types = [1, 1, 1, 1, -1];

        % Pobranie wartości v (współczynnika kompromisu)
        if isfield(handles, 'lambda')
            v = handles.lambda; % Jeśli ustawiono w GUI
        else
            v = 0.5; % Domyślna wartość v
        end

        % Uruchomienie metody VIKOR
        [ranking, Q] = VIKOR(performance_matrix, types, v);

        % Pobranie oryginalnych danych i ich sortowanie według rankingu
        if isfield(handles, 'uitable1')
            original_data = get(handles.uitable1, 'Data');
            if ~isempty(original_data) && size(original_data, 1) == m
                sorted_data = original_data(ranking, :);
                set(handles.tabela_ranking, 'Data', sorted_data);

                % Sprawdzenie, czy nazwa eksperta jest w handles (np. 'ekspert_1', 'ekspert_2' itp.)
                if isfield(handles, 'ekspert_nazwa')
                    ekspert_nazwa = handles.ekspert_nazwa;
                else
                    ekspert_nazwa = 'nieznany_ekspert';
                end

                % Generowanie nazw zmiennych na podstawie eksperta i metody
                ranking_var_name = [ekspert_nazwa '_ranking_vikor'];
                sorted_data_var_name = [ekspert_nazwa '_sorted_data_vikor'];

                % Zapisanie rankingu i posortowanych danych do workspace
                assignin('base', ranking_var_name, ranking);
                assignin('base', sorted_data_var_name, sorted_data);

                % Komunikat dla użytkownika
                msgbox(['Ranking VIKOR został pomyślnie utworzony i zapisany jako: ' ranking_var_name ' i ' sorted_data_var_name], 'Sukces');
            else
                errordlg('Błąd: Nieprawidłowe dane w "uitable1".', 'Błąd');
            end
        else
            errordlg('Błąd: "uitable1" nie istnieje w strukturze handles.', 'Błąd');
        end
        
    catch ME
        errordlg(['Wystąpił błąd w VIKOR: ' ME.message], 'Błąd');
    end
    
    end

% --- Executes on button press in porownaj_metody.
function porownaj_metody_Callback(hObject, eventdata, handles)
    % Pobranie danych z tabeli GUI
    alternatywy = get(handles.uitable1, 'Data'); 
    if isempty(alternatywy)
        msgbox('Brak danych w tabeli alternatyw! Wczytaj dane najpierw.', 'Błąd','error');
        return;
    end

    % Pobranie matrix_of_matrices
    if evalin('base','exist(''matrix_of_matrices'',''var'')')
        matrix_of_matrices = evalin('base','matrix_of_matrices');
    else
        errordlg('Nie znaleziono "matrix_of_matrices" w przestrzeni roboczej.','Błąd');
        return;
    end

    % Pobranie wymiarów macierzy decyzji
    [m, n, p] = size(matrix_of_matrices);

    % Średnia ocen od decydentów (spłaszczenie 3D do 2D)
    performance_matrix = mean(matrix_of_matrices, 3);

    % Automatyczne dopasowanie typów kryteriów
    types = [1, 1, 1, 1, -1];
    lambda = handles.lambda;  % Parametr kompromisu

    % Lista metod do porównania
    methods = {'UTA*', 'VIKOR', 'MREF', 'TOPSIS', 'RSM'};
    results = table((1:m)', 'VariableNames', {'Alternatywy'});
    distances_best = zeros(1, numel(methods));

    for i = 1:numel(methods)
        try
            switch methods{i}
                case 'UTA*'
                    [ranking, deviations] = UTA_Star(matrix_of_matrices, types, 'spearman');
                    distances_best(i) = deviations(ranking(1));

                case 'VIKOR'
                    [ranking, Q] = VIKOR(performance_matrix, types, lambda);
                    distances_best(i) = Q(ranking(1));

                case 'MREF'
                    [ranking, min_distances] = MREF(performance_matrix, types);
                    distances_best(i) = min_distances(ranking(1));

                case 'TOPSIS'
                    [ranking, C] = Topsis_Fuzzy(performance_matrix, types);
                    distances_best(i) = C(ranking(1));

                case 'RSM'
                    [ranking, Q] = fuzzy_rsm(performance_matrix, types, lambda);
                    distances_best(i) = Q(ranking(1));
            end

            % Tworzenie wektora pozycji rankingu
            posMethod = zeros(m, 1);
            for idx = 1:m
                posMethod(ranking(idx)) = idx; 
            end
            results.(methods{i}) = posMethod;
        
        catch ME
            msgbox(['Błąd w metodzie ', methods{i}, ': ', ME.message], 'Błąd','error');
        end
    end

    % Obliczenie macierzy korelacji Spearmana
    spearman_matrix = matrix_spearman(results, methods);

    % Wizualizacja rankingów metod
    figure('Name','Porównanie rankingów metod','NumberTitle','off');
    hold on;
    for i = 1:numel(methods)
        if ismember(methods{i}, results.Properties.VariableNames)
            plot(results{:, methods{i}}, 'o-', 'DisplayName', methods{i});
        end
    end
    legend('Location','best');
    xlabel('Alternatywy');
    ylabel('Ranking (miejsce)');
    title('Porównanie rankingów metod');
    hold off;

    % Wizualizacja odległości najlepszych alternatyw - niepotrzebne
    %figure('Name','Odległości od ideału','NumberTitle','off');
    %bar(distances_best);
    %xticklabels(methods);
    %xlabel('Metody');
    %ylabel('Odległość od ideału');
    %title('Odległości od ideału dla najlepszych alternatyw');
    %grid on;

    % Wizualizacja macierzy korelacji Spearmana
    figure('Name','Macierz korelacji Spearmana','NumberTitle','off');
    heatmap(methods, methods, spearman_matrix, 'Colormap', jet, 'ColorbarVisible', 'on');
    title('Macierz korelacji Spearmana między metodami');

    % Wyświetlenie wyników w GUI
    try
        % Pobranie nazw alternatyw
        nazwy_alternatyw = get(handles.uitable1, 'Data'); 
        nazwy_alternatyw = nazwy_alternatyw(:, 1);
        
        if any(strcmp(results.Properties.VariableNames, 'Alternatywy'))
            results.Alternatywy = []; 
        end
        
        results = addvars(results, nazwy_alternatyw, 'Before', 1, 'NewVariableNames', "Alternatywy");
        
        set(handles.tabela_ranking, 'Data', table2cell(results));
    catch ME
        msgbox(['Błąd podczas wyświetlania wyników: ', ME.message],'Błąd','error');
    end

% --- Executes on button press in porownaj_metody_2.
function porownaj_metody_2_Callback(hObject, eventdata, handles)
    % Pobranie danych z tabeli GUI
    alternatywy = get(handles.uitable1, 'Data'); 
    if isempty(alternatywy)
        msgbox('Brak danych w tabeli alternatyw! Wczytaj dane najpierw.', 'Błąd','error');
        return;
    end

    % Przygotowanie tabeli i danych wejściowych
    try
        num_cols = size(alternatywy, 2);
        col_names = [{'Alternatywy'}, strcat('Kryterium_', string(1:(num_cols - 1)))];
        data_table = cell2table(alternatywy, 'VariableNames', col_names);

        data = data_table{:, 2:end};          
        nazwy_alternatyw = data_table{:, 1};  
    catch ME
        msgbox(['Błąd podczas przetwarzania danych: ', ME.message],'Błąd','error');
        return;
    end

    % Przygotowanie listy metod do porównania
    methods = {'UTA*', 'VIKOR', 'TOPSIS', 'RSM', 'MREF'};
    results = table(nazwy_alternatyw, 'VariableNames', {'Alternatywy'});
    distances_best = zeros(1, numel(methods));

    % Pobranie matrix_of_matrices
    if evalin('base','exist(''matrix_of_matrices'',''var'')')
        matrix_of_matrices = evalin('base','matrix_of_matrices');
    else
        errordlg('Nie znaleziono "matrix_of_matrices" w przestrzeni roboczej.','Błąd');
        return;
    end

    % Pobranie wymiarów macierzy decyzji
    [m, n, p] = size(matrix_of_matrices);

    % Średnia ocen od decydentów (spłaszczenie 3D do 2D)
    performance_matrix = mean(matrix_of_matrices, 3);

    % Typy kryteriów
    types = [1, 1, 1, 1, -1];
    
    % Pobranie wartości lambda (współczynnika kompromisu)
    if isfield(handles, 'lambda')
        lambda = handles.lambda; 
    else
        lambda = 0.5; % Domyślna wartość
    end

    % Dla każdej z metod
    for i = 1:numel(methods)
        try
            switch methods{i}
                case 'UTA*'
                    [ranking, deviations] = UTA_Star(matrix_of_matrices, types, 'kendall');
                    results.(methods{i}) = ranking;
                    distances_best(i) = deviations(ranking(1));
                case 'VIKOR'
                    [ranking, Q] = VIKOR(performance_matrix, types, lambda);
                    results.(methods{i}) = ranking;
                    distances_best(i) = Q(ranking(1));
                case 'TOPSIS'
                    [ranking, dist_positive] = Topsis_Fuzzy(matrix_of_matrices, types);
                    results.(methods{i}) = ranking;
                    distances_best(i) = dist_positive(ranking(1));
                case 'RSM'
                    [ranking, Q] = fuzzy_rsm(performance_matrix, types, lambda);
                    results.(methods{i}) = ranking;
                    distances_best(i) = Q(ranking(1));
                case 'MREF'
                    [ranking, min_distances] = MREF(matrix_of_matrices, types);
                    results.(methods{i}) = ranking;
                    distances_best(i) = min_distances(ranking(1));
            end
        catch ME
            msgbox(['Błąd w metodzie ', methods{i}, ': ', ME.message], 'Błąd','error');
        end
    end

    % Obliczenie współczynnika tau Kendalla między metodami
    num_methods = numel(methods);
    kendall_matrix = zeros(num_methods);
    for i = 1:num_methods
        for j = i+1:num_methods
            if ismember(methods{i}, results.Properties.VariableNames) && ismember(methods{j}, results.Properties.VariableNames)
                kendall_matrix(i, j) = matrix_kendall_tau_correlation(results{:, methods{i}}, results{:, methods{j}});
                kendall_matrix(j, i) = kendall_matrix(i, j);
            end
        end
    end
    
    % Wizualizacja rankingów metod
    figure('Name','Porównanie rankingów metod','NumberTitle','off');
    hold on;
    for i = 1:numel(methods)
        if ismember(methods{i}, results.Properties.VariableNames)
            plot(results{:, methods{i}}, 'o-', 'DisplayName', methods{i});
        end
    end
    legend('Location','best');
    xlabel('Alternatywy');
    ylabel('Ranking (miejsce)');
    title('Porównanie rankingów metod');
    hold off;

    % Wizualizacja macierzy korelacji Kendalla
    figure('Name','Macierz korelacji Kendalla','NumberTitle','off');
    heatmap(methods, methods, kendall_matrix);
    xlabel('Metody');
    ylabel('Metody');
    title('Macierz współczynnika tau Kendalla');
    grid on;
    
    % Wizualizacja odległości od ideału - niepotrzeben
    %figure('Name','Odległości od ideału','NumberTitle','off');
    %bar(distances_best);
    %xticklabels(methods);
    %xlabel('Metody');
    %ylabel('Odległość od ideału');
    %title('Odległości od ideału dla najlepszych alternatyw');
    %grid on;

    % Wyświetlenie wyników w GUI
    try
        set(handles.tabela_ranking, 'Data', table2cell(results));
    catch ME
        msgbox(['Błąd podczas wyświetlania wyników: ', ME.message],'Błąd','error');
    end