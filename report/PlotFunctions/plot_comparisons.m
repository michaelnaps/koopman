function [fig] = plot_comparisons(x1_list, x2_list, x0, tspan, x0_2)

    [N0, N1] = size(x0);

    if nargin < 5
        N2 = N1;
    else
        [~, N2] = size(x0_2);
    end

    k1 = 0;
    k2 = 0;

    fig = figure;
    for i = 1:N0

        for j = 1:N1

            subplot(N0,N1,k1+j)
            hold on
            plot(tspan, x1_list(:,k1+j), 'linewidth', 2)
            plot(tspan, x2_list(:,k2+j), '--', 'linewidth', 1.5)
            title("x(" + i + "," + j + ")")
            
            if i == 1 && j == N1
                legend('Model Func.', 'Koopman op.')
            end
            
            hold off
            

        end

        k1 = k1 + N1;
        k2 = k2 + N2;

    end

end