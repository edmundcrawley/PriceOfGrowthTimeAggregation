function y = criterion_boot(x,mt,s,st, TA)       % Diagonally weighted minimum distance (DWMD)
b    = x;
m    = mt(:,1);                                 % Vector of covariances
var  = mt(:,2:length(mt(1,:))-1);              % Weighting matrix - Variance matrix for optimal mindist
ma          = s(1);
taste       = s(2);
varying_ins = s(3);
WMD         = s(4);
varying_et  = s(5);
pattern     = s(6:length(s));
step = st;
T = mt(1,length(mt(1,:)));
T_full = length(pattern)-1;

if step == 1
    T_z = T-2;
    if varying_et == 1 || varying_et == 2
        T_e = T-1;                                  % 91, 93, 97, 00, 04, 06
    elseif varying_et == 3
        T_e = T_full - 5;                           % 91 - 06, one for each year
    elseif varying_et == 4
        T_e = 2*(T-1)-1;                            % 91, 92, 93, 94-6, 97, 98-9, 00, 01-03, 04, 05, 06
    end
    b(1+ma:ma+T_z+T_e) = exp(b(1+ma:ma+T_z+T_e));
    if TA==0
        fmm = fcninc(b,mt,s);
    else
        fmm = fcninc_TA(b, mt,s);
    end
    
elseif step == 2    
    if varying_ins <2
        T_pz = 1+varying_ins;
        T_pe = 1+varying_ins;
    elseif varying_ins == 2
        T_pz = T-2;
        T_pe = T-2;
    end
    T_u = T-1;
    b(1:T_pz+T_pe+T_u+taste)= exp(b(1:T_pz+T_pe+T_u+taste));
    if TA ==0
        fmm = fcnyc(b,mt,s);
    else
        fmm = fcnyc_TA(b,mt,s);
    end
end


if WMD == 1
    invpeso = diag(diag(var).^(-1));
elseif WMD == 2
    invpeso = eye(size(var));
end 
f = (m-fmm)'*invpeso*(m-fmm);     % m is vector of actual covariances - fmm is implied covariances
y = f;   
end
