function y=mindist_boot(m1,m2,s, TA)

ma          = s(1);
taste       = s(2);
varying_ins = s(3);
varying_et  = s(5);
pattern     = s(6:length(s));
setup       = s;
momt1       = m1;
momt2       = m2;

T = momt1(1,length(momt1(1,:)));                  % Length of the restricted panel (in FD)
T_full = length(pattern)-1;                       % Length of the full panel without data limitation (in level)

% Number of the insurance parameters
if varying_ins <2
    T_pz = 1+varying_ins;
    T_pe = 1+varying_ins;
elseif varying_ins == 2
    T_pz = T-2;
    T_pe = T-2;
end
% Number of the variances of transitory shocks
if varying_et == 1 || varying_et == 2
    T_e = T-1;                                  % 91, 93, 97, 00, 04, 06
elseif varying_et == 3
    T_e = T_full - 5;                           % 91 - 06, one for each year
elseif varying_et == 4
    T_e = 2*(T-1)-1;                            % 91, 92, 93, 94-6, 97, 98-9, 00, 01-03, 04, 05, 06
end
% Number of the variances of permanent shocks
T_z = T-2;
% Number of the measurement errors in consumption
T_u = T-1;

% Minimum distance estimation
%% Step 1: income process
step = 1;
% Starting parameters
if ma == 1
    b0                      = zeros(1+T_z+T_e,1);
    b0(1)                   = 0.1;                          % teta
    b0(2:2+T_z-1)           = log(0.03)*ones(T_z,1);         % zt     
    b0(2+T_z:2+T_z+T_e-1)   = log(0.06)*ones(T_e,1);         % et
else
    b0                      = zeros(T_z+T_e,1);
    b0(1:1+T_z-1)           = log(0.03)*ones(T_z,1);         % zt     
    b0(1+T_z:T_z+T_e)       = log(0.06)*ones(T_e,1);         % et  
end
% Minimization
options=optimset('MaxIter',1e+10,'MaxFunEvals',1e+10,'TolX',1e-10,'TolFun',1e-30);
f = @(x)criterion_boot(x,momt1,setup,step, TA); % lambda function f 
[b,fval,exitflag] = fminunc(f,b0,options); % f, starting point, options  %built in matlab function to min 
b(1+ma:ma+T_z+T_e) = exp(b(1+ma:ma+T_z+T_e));
% % Results
% display(['exitflag ',num2str(exitflag)]);
% display(['fval ',num2str(fval)]);
% if ma==1
%     display('teta:');
%     display(num2str(b(1)));
%     display('var(zeta):');
%     display(num2str(b(2:2+T_z-1)));
%     display('var(epsilon): ');
%     display(num2str(b(2+T_z:2+T_z+T_e-1)));
% else
%     display('var(zeta):');
%     display(num2str(b(1:1+T_z-1)));
%     display('var(epsilon): ');
%     display(num2str(b(1+T_z:T_z+T_e)));
% end
y_step1= zeros(ma+T_z+T-1,1);
if varying_et == 1 || varying_et == 2
    y_step1(1:T_z)          = b(ma+1:ma+1+T_z-1);
    y_step1(T_z+1:T_z+T_e)  = b(ma+1+T_z:ma+1+T_z+T_e-1);
    if ma==1
        y_step1(T_z+T_e+1)  = b(1);
    end
elseif varying_et == 4
    y_step1(1:T_z)          = b(ma+1:ma+1+T_z-1);
    all_et                  = b(ma+1+T_z:ma+1+T_z+T_e-1);
    y_step1(T_z+1:T_z+T-1)  = all_et(1:2:2*(T-1)-1);
    if ma==1
        y_step1(T_z+T-1+1)  = b(1);
    end
end

%% Step 2: consumption/insurance
step = 2;
b_inc = y_step1;            % parameters in the income process
% Starting parameters
b0                               = zeros(taste+T_pe+T_pz+T_u,1);
if taste == 0
elseif taste == 1
    b0(1)                        = log(0.01);                % taste
end
b0(1+taste:T_pz+taste)   		 = log(1)*ones(T_pz,1);       % coeff of partial insurance of perm shock
b0(1+T_pz+taste:T_pz+T_pe+taste) = log(0.01)*ones(T_pe,1);    % coeff of partial insurance of trans shock
b0(1+T_pz+T_pe+taste:length(b0)) = log(0.06)*ones(T_u,1);     % variance of meas. error consumption
% Minimization
options=optimset('MaxIter',1e+10,'MaxFunEvals',1e+10,'TolX',1e-10,'TolFun',1e-30);
f = @(x)criterion_boot([x;b_inc],momt2,setup,step,TA);
[b,fval,exitflag] = fminunc(f,b0,options);
b(1:T_pz+T_pe+T_u+taste)= exp(b(1:T_pz+T_pe+T_u+taste));
% % Results
% display(['exitflag ',num2str(exitflag)]);
% display(['fval ',num2str(fval)]);
% if taste==0
% else
%     display('varsci: ');
%     display(num2str(b(1)));
% end
% display('phit: ');
% display(num2str(b(taste+1:taste+T_pz)));
% display('psit: ');
% display(num2str(b(taste+T_pz+1:taste+T_pz+T_pe)));
% display('varv: ');
% display(num2str(b(taste+T_pz+T_pe+1:taste+T_pz+T_pe+T_u)));

y_step2= zeros(taste+T_pz+T_pe+T_u,1);
if taste == 1
    y_step2(1) = b(1);
else
end
y_step2(taste+1:taste+T_pz+T_pe+T_u) = b(taste+1:taste+T_pz+T_pe+T_u);
y = [y_step1;y_step2];
end