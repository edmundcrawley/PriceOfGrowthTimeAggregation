function y=fcnyc_con(x,m,s)

T           = m(1,length(m(1,:)));               % Length of the restricted panel (in FD)
ma          = s(1);
taste       = s(2);
varying_ins = s(3);
WMD         = s(4);
varying_et  = s(5);
pattern     = s(6:length(s));
T_full      = length(pattern)-1;
if varying_ins <2
    T_pz = 1+varying_ins;
    T_pe = 1+varying_ins;
elseif varying_ins == 2
    T_pz = T-2;
    T_pe = T-2;
end
T_u         = T-1;
if varying_et == 1 || varying_et == 2
    T_e = T-1;                                  % 91, 93, 97, 00, 04, 06
elseif varying_et == 3
    T_e = T_full - 5;                           % 91 - 06, one for each year
elseif varying_et == 4
    T_e = 2*(T-1)-1;                            % 91, 92, 93, 94-6, 97, 98-9, 00, 01-03, 04, 05, 06
end
T_z         = T-2;
b           = x(1:taste+T_pz+T_pe+T_u);
b_inc       = x(taste+T_pz+T_pe+T_u+1:length(x));
pattern_et  =pattern(3:length(pattern)-1);
ind_et      = find(pattern_et);
if ma == 1
    teta    = b_inc(1);
else
    teta    = 0;
end

zt          = b_inc(ma+1:ma+T-2);
et          = b_inc(ma+T-1:length(b_inc));
if taste == 1
    varcsi  = b (1);
else
    varcsi  = 0;
end
phit        = b(taste+1:taste+T_pz); 
psit        = b(taste+T_pz+1:taste+T_pz+T_pe);
varv        = b(taste+T_pz+T_pe+1:taste+T_pz+T_pe+T_u);

difcd =zeros(T,T);          % Consumption without measurement errors
difcme=zeros(T,T);          % Measurement error of consumption
difcy =zeros(T,T);

% This is the variance of Consumption
cut=3;
% cut = 4;
if varying_et == 1
    for j=1:T
        if j<=cut
        phi=phit(1);
        psi=psit(1);
        else
        phi=phit(1+varying_ins);
        psi=psit(1+varying_ins);
        end
        difcd(j,j)=phi^2*zt(min(max(j-1,1),T_z))+psi^2*et(min(j,T_e))+varcsi;
        difcme(j,j)=varv(min(j,T_u))+varv(min(max(j-1,1),T_u));
        if j>=2
            difcme(j-1,j)=-varv(min(j-1,T_u));
        else
        end
    end
elseif varying_et == 2
    for j=1:T
        if j<=cut
        phi=phit(1);
        psi=psit(1);
        else
        phi=phit(1+varying_ins);
        psi=psit(1+varying_ins);
        end
        if j==1
            difcd(1,1)=phi^2*zt(1)+2*psi^2*et(1)+2*varcsi;
        elseif j<T
            difcd(j,j)=phi^2*zt(min(max(j-1,1),T_z))+(ind_et(j)-ind_et(j-1))*psi^2*et(min(j,T_e))+(ind_et(j)-ind_et(j-1))*varcsi;
        else
            difcd(j,j)=phi^2*1.5*zt(T_z)+(ind_et(j)-ind_et(j-1))*psi^2*et(min(j,T_e))+(ind_et(j)-ind_et(j-1))*varcsi;
        end
        difcme(j,j)=varv(min(j,T_u))+varv(min(max(j-1,1),T_u));
        if j>=2
            difcme(j-1,j)=-varv(min(j-1,T_u));
        else
        end
    end
elseif varying_et ==3
    for j=1:T
        if j<=cut
        phi=phit(1);
        psi=psit(1);
        else
        phi=phit(1+varying_ins);
        psi=psit(1+varying_ins);
        end
        if j>1 && j<T
            difcd(j,j)=phi^2*zt(min(max(j-1,1),T_z))+psi^2*sum(et(ind_et(j-1)+1:ind_et(j)))+(ind_et(j)-ind_et(j-1))*varcsi;
        elseif j==1
            difcd(1,1)=phi^2*zt(1)+2*psi^2*et(1)+2*varcsi;
        elseif j==T
            difcd(T,T)=phi^2*1.5*zt(T_z)+3*psi^2*et(T_e)+3*varcsi;
        end
        difcme(j,j)=varv(min(j,T_u))+varv(min(max(j-1,1),T_u));
        if j>=2
            difcme(j-1,j)=-varv(min(j-1,T_u));
        else
        end
    end
elseif varying_et == 4
    for j=1:T
        if j<=cut
        phi=phit(1);
        psi=psit(1);
        else
        phi=phit(1+varying_ins);
        psi=psit(1+varying_ins);
        end
        if j>1 && j<T
            difcd(j,j)=phi^2*zt(min(max(j-1,1),T_z))+psi^2*(et(2*j-1)+et(2*j-2))+(ind_et(j)-ind_et(j-1))*varcsi;
        elseif j==1
            difcd(1,1)=phi^2*zt(1)+2*psi^2*et(1)+2*varcsi;
        elseif j==T
            difcd(T,T)=phi^2*1.5*zt(T_z)+3*psi^2*et(T_e)+3*varcsi;
        end
        difcme(j,j)=varv(min(j,T_u))+varv(min(max(j-1,1),T_u));
        if j>=2
            difcme(j-1,j)=-varv(min(j-1,T_u));
        else
        end
    end
end
difc=difcme+difcd;

i=2;
while i<=T
    j=i;
    while j<=T
        difc(j,i-1)=difc(i-1,j);
        j=j+1;
    end
    i=i+1;
end

% This is the Covariance of Income and Consumption
if varying_et == 1
    for j=1:T
        if j<=cut
            phi=phit(1);
            psi=psit(1);
        else
            phi=phit(1+varying_ins);
            psi=psit(1+varying_ins);
        end
        difcy(j,j)=phi*zt(min(max(j-1,1),T_z))+psi*et(min(j,T_e));
        if j>=2
            if j<=cut+1
                psi=psit(1);
            else
                psi=psit(1+varying_ins);
            end
            difcy(j-1,j)=-(1-teta)*psi*et(min(j-1,T_e));
            if j>=3
                if j<=cut+2
                    psi=psit(1);
                else
                    psi=psit(1+varying_ins);
                end
                difcy(j-2,j)=-teta*psi*et(min(j-2,T_e));
            else
            end
        else
        end
    end
elseif varying_et == 2
    for j=1:T
        if j<=cut
            phi=phit(1);
            psi=psit(1);
        else
            phi=phit(1+varying_ins);
            psi=psit(1+varying_ins);
        end
        if j<T
            difcy(j,j)=phi*zt(min(max(j-1,1),T_z))+psi*(1+teta)*et(min(j,T_e));
        else
            difcy(T,T)=phi*1.5*zt(T_z)+psi*(1+teta)*et(T_e);
        end
        if j>=2
            if j<=cut+1
                psi=psit(1);
            else
                psi=psit(1+varying_ins);
            end
            difcy(j-1,j)=-psi*(1+teta)*et(min(j-1,T_e));
        else
        end
    end
elseif varying_et == 3
    for j=1:T
        if j<=cut
            phi=phit(1);
            psi=psit(1);
        else
            phi=phit(1+varying_ins);
            psi=psit(1+varying_ins);
        end
        if j<T
            difcy(j,j)=phi*zt(min(max(j-1,1),T_z))+psi*(et(min(ind_et(j),T_e))+teta*et(min(max(ind_et(j)-1,1),T_e)));
        else
            difcy(T,T)=phi*1.5*zt(T_z)+psi*(et(T_e)+teta*et(T_e));
        end
        if j<T
            if j<=cut
                psi=psit(1);
            else
                psi=psit(1+varying_ins);
            end
            difcy(j,j+1)=-psi*(et(min(ind_et(j),T_e))+teta*et(min(max(ind_et(j)-1,1),T_e)));
        else
        end
    end
elseif varying_et == 4
    for j=1:T
        if j<=cut
            phi=phit(1);
            psi=psit(1);
        else
            phi=phit(1+varying_ins);
            psi=psit(1+varying_ins);
        end
        if j<T
            difcy(j,j)=phi*zt(min(max(j-1,1),T_z))+psi*et(min(2*j-1,T_e));
        else
            difcy(T,T)=phi*1.5*zt(T_z)+psi*et(T_e);
        end
        if j<T
            if j<=cut
                psi=psit(1);
            else
                psi=psit(1+varying_ins);
            end
            difcy(j,j+1)=-psi*et(min(2*j-1,T_e));
        else
        end
    end   
end

mat1 = ones(T,T);
c1_vector = difc(logical(triu(mat1)));
c2_vector = difcy(logical(triu(mat1)));

y = [c1_vector;c2_vector];
end
