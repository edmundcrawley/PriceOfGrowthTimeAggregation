clear
 display('This is the Time Aggregation version of Main Results Urban')
 
 % Select estimation routine
 %89, 91, 93, 97, 00, 04, 06, 09 are the survey years
interval = [1;0;1;0;1;0;0;0;1;0;0;1;0;0;0;1;0;1;0;0;1];     % same as in CHNS these are the years the survey was conducted
iniyear  = 1;                                               % first year in the limited data
pattern =[interval;iniyear];
ma          = 0;					    % Choose if you want MA(1) for income in estimation
taste       = 1;					    % Choose if you want taste shocks in estimation
varying_ins = 1;					    % Choose 1 if you want different pre2000 and post2000 insurance parameters
                                        % and 2 if you want different insurance parameters by year
WMD         = 1;                        % Choose 1 if you want DWMD estimator and 2 if you want EWMD estimator
varying_et  = 2;                        % Choose 1 if you want to treat the restricted data as annual data; 2 if
                                        % you want to assume et to be constant within interval; 3 if
                                        % you want to allow et to vary over time without restriction
                                        % and 4 allowing et to vary over time without restriction butma=0.
est_setup = [ma;taste;varying_ins;WMD;varying_et;pattern];

    % Loading the data
    dataset_import = importdata('dydc4matlab.csv');
    data = double(dataset_import);
    clearvars dataname dataset_import
    
    % Estimation
    moments1=datamomentinc(data);
    moments2=datamomentyc(data);
    estimates = mindist_boot(moments1,moments2,est_setup, 1); %Time aggregation set last input to 1. 
    clear data moments
    
    % WELFARE DECOMPOSITION
    % rural = 2; eta = 2; r = 0.014;
    parameters = [2;2;0.014];
    omega_1 = welfaregain(estimates,parameters)-1;
    
    % rural = 2; eta = 2; r = 0.02;
    parameters = [2;2;0.02];
    omega_2 = welfaregain(estimates,parameters)-1;
    
    % rural = 2; eta = 4; r = 0.014;
    parameters = [2;4;0.014];
    omega_3 = welfaregain(estimates,parameters)-1;
   
    % rural = 2; eta = 4; r = 0.02;
    parameters = [2;4;0.02];
    omega_4 = welfaregain(estimates,parameters)-1;
    
    estimates = [estimates;omega_1;omega_2;omega_3;omega_4];
    
%     % report the annualized permanent shocks
%     estimates(1) = estimates(1)/2;          % 1992, 1993
%     estimates(2) = estimates(2)/4;          % 1994, 1995, 1996, 1997
%     estimates(3) = estimates(3)/3;          % 1998, 1999, 2000
%     estimates(4) = estimates(4)/4;          % 2001, 2002, 2003, 2004
%     estimates(5) = estimates(5)/2;          % 2005, 2006
    
csvwrite('results_TA.csv',estimates);  %permament variance and transitory variance table 3. 

exit
% 
% %  