function [K, acc, ind, err] = koopman(observation, x_data, x0)
    %% Create structure variable for errors
    err = struct;

    %% evaluate for the observation function
    Nx = length(x0(:,1));                   % number of initial points
    Mx = round(length(x_data(:,1))/Nx);     % number of data points
    Nk = length(observation(x_data(1,:)));  % number of obs. functions

    psiX = NaN(Mx-Nx, Nk);
    psiY = NaN(Mx-Nx, Nk);

    i = 0;
    j = 0;

    for n = 1:Nx

        for m = 1:Mx-1

            i = i + 1;
            j = j + 1;

            psiX(j,:) = observation(x_data(i,:));
            psiY(j,:) = observation(x_data(i+1,:));

        end

        i = i + 1;
        j = n*(Mx-1);

    end

    if (sum(isnan(psiX), 'all') > 0 || sum(isnan(psiY), 'all') > 0)
        err.psiX = psiX;
        err.psiY = psiY;

        K   = NaN;
        acc = NaN;
        ind = NaN;

        fprintf("ERROR: psiX or psiY contain NaN value.\n\n")

        return;
    end
    
    %% perform lest-squares
    % create least-squares matrices
    eps = 1e-6;
    G = 1/Mx * (psiX')*psiX;
    A = 1/Mx * (psiX')*psiY;

    [U,S,V] = svd(G);

    ind = diag(S) > eps;

    U = U(:,ind);
    S = S(ind,ind);
    V = V(:,ind);
    
    % solve for the Koopman operator
    K = (V*(S\U')) * A;
    
    % calculate residual error
    acc = 0;
    for n = 1:Nk
    
        acc = acc + norm(psiY(n,:)' - K'*psiX(n,:)');
    
    end
    
    if isnan(acc)

        fprintf("Nk = %i\n", Nk)
        fprintf("G = (%i x %i)\n", size(G))
        disp(G)
        fprintf("A = (%i x %i)\n", size(A))
        disp(A)
        fprintf("K = (%i x %i)\n", size(K))
        disp(K)

        err.G = G;
        err.A = A;
        err.K = K;

    end
end