function y=welfaregainsp(x,pmtr)

% X CONTAINS THE ESTIMATES AND PMTR CONTAINS THE PARAMETERS
permshock_rural = x(1:5);
transhock_rural = x(6:11);
tasteshock_rural= x(12);
psiperm_rural_pre = x(13);
psiperm_rural_post= x(14);
psitran_rural_pre = x(15);
psitran_rural_post= x(16);
permshock_urban = x(17:21);
transhock_urban = x(22:27);
psiperm_urban_pre = x(29);
psiperm_urban_post= x(30);
psitran_urban_pre = x(31);
psitran_urban_post= x(32);
eta     = pmtr(1);    % RISK AVERSION
r       = pmtr(2);    % INTEREST RATE

% ANNUALIZED VARIANCE OF PERM AND TRAN SHOCKS BY SUB-PERIOD
permshock_rural_pre = (permshock_rural(1)/2*5+permshock_rural(2))/9;
permshock_rural_post= (permshock_rural(3)+permshock_rural(4)+permshock_rural(5)/2*5)/12;
transhock_rural_pre = (transhock_rural(1)*3+transhock_rural(2)*2+transhock_rural(3)*4)/9;
transhock_rural_post= (transhock_rural(4)*3+transhock_rural(5)*4+transhock_rural(6)*5)/12;
permshock_urban_pre = (permshock_urban(1)/2*5+permshock_urban(2))/9;
permshock_urban_post= (permshock_urban(3)+permshock_urban(4)+permshock_urban(5)/2*5)/12;
transhock_urban_pre = (transhock_urban(1)*3+transhock_urban(2)*2+transhock_urban(3)*4)/9;
transhock_urban_post= (transhock_urban(4)*3+transhock_urban(5)*4+transhock_urban(6)*5)/12;

% EXOGENOUS PARAMETERS
savingrate = 0.225;     % Household saving rate grows from 15% to 30% from 1990 to 2010. Take the average 22.5
y0_rural_pre  = 459.94;         % disposable income level in 1989 for rural residents
y0_rural_post = 741.04;         % disposable income level in 2000 for rural residents
gy_rural_pre  = 1+0.0443;       % annual growth of disposable income for rural residents: from 459.94 in 1989 to 741.04 in 2000
gy_rural_post = 1+0.0520;       % annual growth of disposable income for rural residents: from 741.04 in 2000 to 1169.59 in 2009
gy_urban_pre  = 1+0.0496;       % annual growth of disposable income for urban residents: from 642.46 in 1989 to 1094.20 in 2000
gy_urban_post = 1+0.0671;       % annual growth of disposable income for urban residents: from 1094.20 in 2000 to 1963.53 in 2009
beta = 0.98;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE PERIOD (1989-1997): COUNTERFACTUALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T=9;
% GROWTH EFFECT
para = [eta;r;T;savingrate];
cbar0_pre    = initialc(y0_rural_pre,gy_rural_pre ,para);
cbar0_pre_G  = initialc(y0_rural_pre,gy_urban_pre ,para);
omega_G_pre   = cbar0_pre_G/cbar0_pre;

% RISK EFFECT
gc = (beta*(1+r))^(1/eta);
c_pre = 0;
c_pre_R = 0;
for t=1:T
    c_pre = c_pre + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_rural_pre^2*permshock_rural_pre+psitran_rural_pre^2*transhock_rural_pre+tasteshock_rural)*t);
    c_pre_R = c_pre_R + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_rural_pre^2*permshock_urban_pre+psitran_rural_pre^2*transhock_urban_pre+tasteshock_rural)*t);
end
omega_R_pre = (c_pre_R/c_pre)^(1/(1-eta));

% INSURANCE EFFECT
c_pre_RI = 0;
for t=1:T
    c_pre_RI = c_pre_RI + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_urban_pre^2*permshock_urban_pre+psitran_urban_pre^2*transhock_urban_pre+tasteshock_rural)*t);
end
omega_I_pre = (c_pre_RI/c_pre_R)^(1/(1-eta));

% TOTAL EFFECT
omega_T_pre = (cbar0_pre_G/cbar0_pre)*(c_pre_RI/c_pre)^(1/(1-eta));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POST PERIOD (1998-2009): COUNTERFACTUALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T = 12;
% GROWTH EFFECT
para = [eta;r;T;savingrate];
cbar0_post    = initialc(y0_rural_post, gy_rural_post,para);
cbar0_post_G  = initialc(y0_rural_post, gy_urban_post,para);
omega_G_post   = cbar0_post_G/cbar0_post;

% RISK EFFECT
c_post = 0;
c_post_R = 0;
for t=1:T
    c_post = c_post + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_rural_post^2*permshock_rural_post+psitran_rural_post^2*transhock_rural_post+tasteshock_rural)*t);
    c_post_R = c_post_R + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_rural_post^2*permshock_urban_post+psitran_rural_post^2*transhock_urban_post+tasteshock_rural)*t);
end
omega_R_post = (c_post_R/c_post)^(1/(1-eta));

% INSURANCE EFFECT
c_post_RI = 0;
for t=1:T
    c_post_RI = c_post_RI + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_urban_post^2*permshock_urban_post+psitran_urban_post^2*transhock_urban_post+tasteshock_rural)*t);
end
omega_I_post = (c_post_RI/c_post_R)^(1/(1-eta));

% TOTAL EFFECT
omega_T_post = (cbar0_post_G/cbar0_post)*(c_post_RI/c_post)^(1/(1-eta));

y = [omega_G_pre;omega_R_pre;omega_I_pre;omega_T_pre;omega_G_post;omega_R_post;omega_I_post;omega_T_post];
end


