function [u, x, Psi] = KoopmanMPC(xg, x0, Np, K, Q, obsFun, Rs)

    Nx = 4;
    Nu = 2;
    Nw = 4;
    Nk = (Nx + Nw)*Q + Nu;
    iw = Nx*Q + 1;

    Psi0 = obsFun(x0, [0,0]);

    dKx = diag([ones(1,Nk-Nu), zeros(1,Nu)]);
    dKu = diag([zeros(1,Nk-Nu), ones(1,Nu)]);

    cvx_begin
        variable Psi(Np,Nk);
        variable u(Np-1,Nu);

        minimize( cost(u, Psi(:,1:Nx), xg, Np) );

        subject to
            % initial position constraint
            Psi(1,:) == Psi0;
            
            % dynamics constraints
            for i = 1:Np-1
                uPsi = [zeros(1,Nk-Nu), u(i,:)];
                Psi(i+1,:) == Psi(i,:)*dKx*K + uPsi*dKu*K;
            end

            % boundary constraints
            for i = Np
                for j = 1:Nw
                    Psi(i,iw+j) >= Rs;
                end
            end

            % final position constraint
%             Psi(end,1:Nx) == xg;
    cvx_end

    x = Psi(:,1:Nx);

end

%% objective function
function [C] = cost(u, x, xg, Np)
    [~, Nu] = size(u);
    U = 0.10*eye(Nu);
    
    C = 0;
    for i = 1:Np-1
        C = C + u(i,:)*U*u(i,:)' + (x(i,:) - xg)*(x(i,:) - xg)';
    end

    C = C + (x(end,:) - xg)*(x(end,:) - xg)';

end