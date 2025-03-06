function tau = matrix_kendall_tau_correlation(x, y)
    % Funkcja licząca współczynnik Kendalla tau bez Statistics Toolbox
    if length(x) ~= length(y)
        error('Wektory x i y muszą mieć tę samą długość.');
    end
    
    n = length(x);
    concordant = 0;
    discordant = 0;
    
    for i = 1:n-1
        for j = i+1:n
            sign_x = sign(x(i) - x(j));
            sign_y = sign(y(i) - y(j));
            
            if sign_x * sign_y > 0
                concordant = concordant + 1;
            elseif sign_x * sign_y < 0
                discordant = discordant + 1;
            end
        end
    end
    
    tau = (concordant - discordant) / (0.5 * n * (n - 1));
end
