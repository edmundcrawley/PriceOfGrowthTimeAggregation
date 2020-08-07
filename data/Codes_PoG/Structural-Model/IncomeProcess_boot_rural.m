clear all
clc

 %cd('C:\Users\yuzheng\Documents\Codes_POG\Structural Model');
 cd('G:\Edmund\time-aggregation\Papers\ThePriceOfGrowth\data\Codes_PoG\Structural-Model');

  
% Select estimation routine
WMD         = 1;                        % Choose 1 if you want DWMD estimator and 2 if you want EWMD estimator

display('============== ESTIMATION SETUP ================');
display([' WMD: ',num2str(WMD),'.']);

% Loading the data
% IN FD
dataname = strcat('dydc4matlab.csv');
dataset_import = importdata(num2str(dataname));
display(num2str(dataname));
dataFD = double(dataset_import);
clearvars dataname dataset_import
% IN LEVELS
dataname = strcat('Income_Process_Data\dataLV_Rural.csv');
dataset_import = importdata(num2str(dataname));
display(num2str(dataname));
dataLV = double(dataset_import);
clearvars dataname dataset_import

% Estimation
momentsFD=datamomentinc(dataFD);
momentsLV_aux=datamomentinc(dataLV);
momentsLV_aux=momentsLV_aux(:,1);
momentsLV=triu(ones(8));
momentsLV(momentsLV==1)=momentsLV_aux;
momentsLV = momentsLV+tril(momentsLV',-1);
clearvars momentsLV_aux
estimates= mindist_income_boot(momentsFD,momentsLV,WMD);
clear data moments

csvwrite('results.csv',estimates);

exit
