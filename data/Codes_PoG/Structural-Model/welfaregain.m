function y=welfaregain(x,pmtr)

% X CONTAINS THE ESTIMATES AND PMTR CONTAINS THE PARAMETERS
permshock = x(1:5);
transhock = x(6:11);
tasteshock= x(12);
psiperm_pre = x(13);
psiperm_post= x(14);
psitran_pre = x(15);
psitran_post= x(16);
rural   = pmtr(1);    % RURAL OR URBAN SAMPLE
eta     = pmtr(2);    % RISK AVERSION
r       = pmtr(3);    % INTEREST RATE

% ANNUALIZED VARIANCE OF PERM AND TRAN SHOCKS BY SUB-PERIOD
permshock_pre = (permshock(1)/2*5+permshock(2))/9;
permshock_post= (permshock(3)+permshock(4)+permshock(5)/2*5)/12;
transhock_pre = (transhock(1)*3+transhock(2)*2+transhock(3)*4)/9;
transhock_post= (transhock(4)*3+transhock(5)*4+transhock(6)*5)/12;

% EXOGENOUS PARAMETERS
savingrate = 0.225;     % Household saving rate grows from 15% to 30% from 1990 to 2010. Take the average 22.5
if rural == 1
    y0_pre  = 459.94;         % disposable income level in 1989 for rural residents
    y0_post = 741.04;         % disposable income level in 2000 for rural residents
    gy_pre  = 1+0.0443;       % annual growth of disposable income for rural residents: from 459.94 in 1989 to 741.04 in 2000
    gy_post = 1+0.0520;       % annual growth of disposable income for rural residents: from 741.04 in 2000 to 1169.59 in 2009
else
    y0_pre  = 642.46;         % disposable income level in 1989 for urban residents
    y0_post = 1094.20;        % disposable income level in 2000 for urban residents
    gy_pre  = 1+0.0496;       % annual growth of disposable income for urban residents: from 642.46 in 1989 to 1094.20 in 2000
    gy_post = 1+0.0671;       % annual growth of disposable income for urban residents: from 1094.20 in 2000 to 1963.53 in 2009
end
beta = 0.98;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE PERIOD (1989-1997): COUNTERFACTUALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T=9;
% GROWTH EFFECT
para = [eta;r;T;savingrate];
cbar0_pre    = initialc(y0_pre,gy_pre ,para);
cbar0_pre_G = initialc(y0_pre,gy_post,para);
omega_G_pre   = cbar0_pre_G/cbar0_pre;

% RISK EFFECT
gc = (beta*(1+r))^(1/eta);
c_pre = 0;
c_pre_R = 0;
for t=1:T
    c_pre = c_pre + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_pre^2*permshock_pre+psitran_pre^2*transhock_pre+tasteshock)*t);
    c_pre_R = c_pre_R + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_pre^2*permshock_post+psitran_pre^2*transhock_post+tasteshock)*t);
end
omega_R_pre = (c_pre_R/c_pre)^(1/(1-eta));

% INSURANCE EFFECT
c_pre_RI = 0;
for t=1:T
    c_pre_RI = c_pre_RI + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_post^2*permshock_post+psitran_post^2*transhock_post+tasteshock)*t);
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
cbar0_post    = initialc(y0_post, gy_post,para);
cbar0_post_G  = initialc(y0_post, gy_pre ,para);
omega_G_post   = cbar0_post_G/cbar0_post;

% RISK EFFECT
c_post = 0;
c_post_R = 0;
for t=1:T
    c_post = c_post + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_post^2*permshock_post+psitran_post^2*transhock_post+tasteshock)*t);
    c_post_R = c_post_R + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_post^2*permshock_pre+psitran_post^2*transhock_pre+tasteshock)*t);
end
omega_R_post = (c_post_R/c_post)^(1/(1-eta));

% INSURANCE EFFECT
c_post_RI = 0;
for t=1:T
    c_post_RI = c_post_RI + (gc^(1-eta)*beta)^t*exp(0.5*(1-eta)^2*(psiperm_pre^2*permshock_pre+psitran_pre^2*transhock_pre+tasteshock)*t);
end
omega_I_post = (c_post_RI/c_post_R)^(1/(1-eta));

% TOTAL EFFECT
omega_T_post = (cbar0_post_G/cbar0_post)*(c_post_RI/c_post)^(1/(1-eta));

y = [omega_G_pre;omega_R_pre;omega_I_pre;omega_T_pre;omega_G_post;omega_R_post;omega_I_post;omega_T_post];
end


