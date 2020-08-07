function y=mindist_income_boot(mFD,mLV,wt)

momt1       = mFD;
momt2       = mLV;
WMD         = wt;
T = momt1(1,length(momt1(1,:)));                  % Length of the restricted panel (in FD)

% Number of the variances of transitory shocks
T_e = T-1;                                        % 89=91, 93, 97, 00, 04, 06=09
% Number of the variances of permanent shocks
T_z = T-2;                                        % 91=93, 97, 00, 04, 06=09

% Minimum distance estimation
% Starting parameters
b0                      = zeros(T_z+T_e+1,1);
b0(1:T_z)               = log(0.03)*ones(T_z,1);         % zt     
b0(1+T_z:T_z+T_e)       = log(0.06)*ones(T_e,1);         % et
b0(1+T_z+T_e)           = log(0.95);                     % rho

% Minimization
options=optimset('MaxIter',1e+10,'MaxFunEvals',1e+10,'TolX',1e-10,'TolFun',1e-30);
f = @(x)criterion_income_boot(x,momt1,momt2,WMD);
[b,fval,exitflag] = fminunc(f,b0,options);
b = exp(b);

% % Results
% display(['exitflag ',num2str(exitflag)]);
% display(['fval ',num2str(fval)]);
% display('var(zeta):');
% display(num2str(b(1:T_z)));
% display('var(epsilon): ');
% display(num2str(b(1+T_z:T_z+T_e)));
% display('rho:');
% display(num2str(b(T_z+T_e+1)));

y = b;
end