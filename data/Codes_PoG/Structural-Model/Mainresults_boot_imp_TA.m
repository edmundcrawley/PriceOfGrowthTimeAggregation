clear


 % Select estimation routine
interval = [1;0;1;0;1;0;0;0;1;0;0;1;0;0;0;1;0;1;0;0;1];     % same as in CHNS
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
    estimates= mindist_boot(moments1,moments2,est_setup,1); %Set last parameter equal to 1 for time agg.
    clear data moments
    
    %This bit takes the estiamtes originally estimated to cover the years between survey.
% For example, estiamtes(1) is the perm variance from 92 and 93. But this
% is done within the code now. see fcinc_TA.

    % report the annualized permanent shocks
%     estimates(1) = estimates(1)/2;          % 1992, 1993
%     estimates(2) = estimates(2)/4;          % 1994, 1995, 1996, 1997
%     estimates(3) = estimates(3)/3;          % 1998, 1999, 2000
%     estimates(4) = estimates(4)/4;          % 2001, 2002, 2003, 2004
%     estimates(5) = estimates(5)/2;          % 2005, 2006
    
csvwrite('results_TA.csv',estimates);

 exit

 