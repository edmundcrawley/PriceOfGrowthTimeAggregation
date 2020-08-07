clear

 cd('C:\Users\yuzheng\Documents\Codes_POG\Structural Model');
   
  % Loading the data
    dataset_import = importdata('boot_spec1_final4matlab.csv');
    estimates_rural = double(dataset_import);
    clearvars dataname dataset_import
    dataset_import = importdata('boot_spec2_final4matlab.csv');
    estimates_urban = double(dataset_import);
    clearvars dataname dataset_import
    
  % RECOVER THE CUMULATED PERMANENT SHOCKS OVER THE INTERVIEW WINDOW USED
  % IN THE WELFARE CODE BELOW.
  estimates_rural(:,1) = estimates_rural(:,1)*2;          % 1992, 1993
  estimates_rural(:,2) = estimates_rural(:,2)*4;          % 1994, 1995, 1996, 1997
  estimates_rural(:,3) = estimates_rural(:,3)*3;          % 1998, 1999, 2000
  estimates_rural(:,4) = estimates_rural(:,4)*4;          % 2001, 2002, 2003, 2004
  estimates_rural(:,5) = estimates_rural(:,5)*2;          % 2005, 2006
  estimates_urban(:,1) = estimates_urban(:,1)*2;          % 1992, 1993
  estimates_urban(:,2) = estimates_urban(:,2)*4;          % 1994, 1995, 1996, 1997
  estimates_urban(:,3) = estimates_urban(:,3)*3;          % 1998, 1999, 2000
  estimates_urban(:,4) = estimates_urban(:,4)*4;          % 2001, 2002, 2003, 2004
  estimates_urban(:,5) = estimates_urban(:,5)*2;          % 2005, 2006
    
  % WELFARE DECOMPOSITION
  welfaregainboot_para1 = zeros(20000,1);
  welfaregainboot_para2 = zeros(20000,1);
  welfaregainboot_para3 = zeros(20000,1);
  welfaregainboot_para4 = zeros(20000,1);
  counter=0;
  for i_rural = 1:50
      for i_urban = 1:50
          counter = counter+1;
          estimates = [estimates_rural(i_rural,:)';estimates_urban(i_urban,:)'];
  
          % eta = 2; r=0.014;
          parameters = [2;0.014];
          omega_1 = welfaregainsp(estimates, parameters)-1;

          % eta = 2; r=0.02;
          parameters = [2;0.02];
          omega_2 = welfaregainsp(estimates, parameters)-1;

          % eta = 4; r=0.014;
          parameters = [4;0.014];
          omega_3 = welfaregainsp(estimates, parameters)-1;

          % eta = 4; r=0.02;
          parameters = [4;0.02];
          omega_4 = welfaregainsp(estimates, parameters)-1;
          
          welfaregainboot_para1((counter-1)*8+1:counter*8)=omega_1;
          welfaregainboot_para2((counter-1)*8+1:counter*8)=omega_2;
          welfaregainboot_para3((counter-1)*8+1:counter*8)=omega_3;
          welfaregainboot_para4((counter-1)*8+1:counter*8)=omega_4;
      end
  end
  welfaregainboot_para1 = reshape(welfaregainboot_para1',[8,2500]);
  welfaregainboot_para2 = reshape(welfaregainboot_para2',[8,2500]);
  welfaregainboot_para3 = reshape(welfaregainboot_para3',[8,2500]);
  welfaregainboot_para4 = reshape(welfaregainboot_para4',[8,2500]);
  pe_para1 = mean(welfaregainboot_para1,2);     % eta = 2; r=0.014; POINT ESTIMATE
  ci_para1 = [prctile(welfaregainboot_para1, 5,2) prctile(welfaregainboot_para1,95,2)];
  pe_para2 = mean(welfaregainboot_para2,2);     % eta = 2; r=0.02; POINT ESTIMATE
  ci_para2 = [prctile(welfaregainboot_para2, 5,2) prctile(welfaregainboot_para2,95,2)];
  pe_para3 = mean(welfaregainboot_para3,2);     % eta = 4; r=0.014; POINT ESTIMATE
  ci_para3 = [prctile(welfaregainboot_para3, 5,2) prctile(welfaregainboot_para3,95,2)];
  pe_para4 = mean(welfaregainboot_para4,2);     % eta = 4; r=0.02; POINT ESTIMATE
  ci_para4 = [prctile(welfaregainboot_para4, 5,2) prctile(welfaregainboot_para4,95,2)];
 
  % DISPLAY THE RESULTS AS IN TABLE 6
  growtheffect_pre = [pe_para2(1)*100, pe_para4(1)*100];
  riskeffect_pre   = [pe_para2(2)*100, pe_para4(2)*100];
  inseffect_pre    = [pe_para2(3)*100, pe_para4(3)*100];
  totaleffect_pre  = [pe_para2(4)*100, pe_para4(4)*100];
  growtheffect_post= [pe_para2(5)*100, pe_para4(5)*100];
  riskeffect_post  = [pe_para2(6)*100, pe_para4(6)*100];
  inseffect_post   = [pe_para2(7)*100, pe_para4(7)*100];
  totaleffect_post = [pe_para2(8)*100, pe_para4(8)*100];
  
  riskci_pre       = [ci_para2(2,1)*100, ci_para2(2,2)*100, ci_para4(2,1)*100, ci_para4(2,2)*100];
  insci_pre        = [ci_para2(3,1)*100, ci_para2(3,2)*100, ci_para4(3,1)*100, ci_para4(3,2)*100];
  totalci_pre      = [ci_para2(4,1)*100, ci_para2(4,2)*100, ci_para4(4,1)*100, ci_para4(4,2)*100];
  riskci_post      = [ci_para2(6,1)*100, ci_para2(6,2)*100, ci_para4(6,1)*100, ci_para4(6,2)*100];
  insci_post       = [ci_para2(7,1)*100, ci_para2(7,2)*100, ci_para4(7,1)*100, ci_para4(7,2)*100];
  totalci_post     = [ci_para2(8,1)*100, ci_para2(8,2)*100, ci_para4(8,1)*100, ci_para4(8,2)*100];
  
  fprintf('                   (a) 1989 - 1997                     \n');
  fprintf('-------------------------------------------------------\n');
  fprintf('Welfare gain                 eta = 2         eta = 4   \n');
  fprintf('-------------------------------------------------------\n');
  fprintf('   Growth effect             ');
  formatSpec1 = '%4.2f %%         %4.2f %%   \n';
  fprintf(formatSpec1,growtheffect_pre);
  fprintf('   Risk effect               ');
  fprintf(formatSpec1,riskeffect_pre);
  fprintf('                           ');
  formatSpec2 = '[%4.2f %4.2f]    [%4.2f %4.2f]\n';
  fprintf(formatSpec2,riskci_pre);
  fprintf('   Insurance effect          ');
  fprintf(formatSpec1,inseffect_pre);
  fprintf('                           ');
  fprintf(formatSpec2,insci_pre);
  fprintf('Total effect                 ');
  fprintf(formatSpec1,totaleffect_pre);
  fprintf('                           ');
  fprintf(formatSpec2,totalci_pre);
  fprintf('-------------------------------------------------------\n');
  
  fprintf('                   (a) 1998 - 2009                     \n');
  fprintf('-------------------------------------------------------\n');
  fprintf('Welfare gain                 eta = 2         eta = 4   \n');
  fprintf('-------------------------------------------------------\n');
  fprintf('   Growth effect             ');
  fprintf(formatSpec1,growtheffect_post);
  fprintf('   Risk effect               ');
  fprintf(formatSpec1,riskeffect_post);
  fprintf('                           ');
  fprintf(formatSpec2,riskci_post);
  fprintf('   Insurance effect          ');
  fprintf(formatSpec1,inseffect_post);
  fprintf('                           ');
  fprintf(formatSpec2,insci_post);
  fprintf('Total effect                 ');
  fprintf(formatSpec1,totaleffect_post);
  fprintf('                           ');
  fprintf(formatSpec2,totalci_post);
  fprintf('-------------------------------------------------------\n');