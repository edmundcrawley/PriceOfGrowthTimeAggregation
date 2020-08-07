function y=fcninc_income(x,v)

b   = x;
T   = 7;                % Length of the restricted panel (in FD)
T_e = T-1;
T_z = T-2;
V   = v;                % Variance-Covariance matrix of income (in levels) from the data (8x8)

zt  = b(1:T_z);                                  % 91=93, 97, 00, 04, 06=09
et  = b(1+T_z:T_z+T_e);                          % 89=91, 93, 97, 00, 04, 06=09
rho = b(T_z+T_e+1);

dify  =zeros(T,T);

% This is the variance-covariance matrix of Income
for j=1:T
    if j==1
        dify(j,j)=(rho^2-1)^2*V(j,j)+(rho^2+1)*zt(1)+et(1)+rho^2*et(1);
    elseif j==2 || j==6
        dify(j,j)=(rho^2-1)^2*V(j,j)+(rho^2+1)*zt(j-1)+et(j)+rho^2*et(j-1);
    elseif j==3 || j==5
        dify(j,j)=(rho^4-1)^2*V(j,j)+(rho^6+rho^4+rho^2+1)*zt(j-1)+et(j)+rho^4*et(j-1);
    elseif j==4
        dify(j,j)=(rho^3-1)^2*V(j,j)+(rho^4+rho^2+1)*zt(j-1)+et(j)+rho^3*et(j-1);
    elseif j==7
        dify(j,j)=(rho^3-1)^2*V(j,j)+(rho^4+rho^2+1)*zt(5)+et(6)+rho^3*et(6);
    end
end
    dify(2,1)=(rho^2-1)*(rho^2-1)*V(2,1)+(rho^2-1)*zt(1)-et(1);
    dify(3,2)=(rho^2-1)*(rho^4-1)*V(3,2)+(rho^4-1)*zt(1)-et(2);
    dify(4,3)=(rho^4-1)*(rho^3-1)*V(4,3)+(rho^3-1)*zt(2)-et(3);
    dify(5,4)=(rho^3-1)*(rho^4-1)*V(5,4)+(rho^4-1)*zt(3)-et(4);
    dify(6,5)=(rho^4-1)*(rho^2-1)*V(6,5)+(rho^2-1)*zt(4)-et(5);
    dify(7,6)=(rho^2-1)*(rho^3-1)*V(7,6)+(rho^3-1)*zt(5)-et(6); 
    dify(1,2)=dify(2,1);
    dify(2,3)=dify(3,2);
    dify(3,4)=dify(4,3);
    dify(4,5)=dify(5,4);
    dify(5,6)=dify(6,5);
    dify(6,7)=dify(7,6);

mat1=ones(length(dify(:,1)),length(dify(1,:)));
fm=dify(logical(triu(mat1)));

y=fm;
end
