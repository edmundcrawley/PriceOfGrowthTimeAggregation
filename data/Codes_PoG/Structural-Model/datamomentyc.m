function y=datamomentyc(d)
x=d;

col_id   =1;                      % colum where id is
col_year =2;                      % column where year (or round) is
col_coh  =3;                      % columns where cohort is
coly_dif =4;                      % column where residuals in FD of income are
coldy_dif=5;                      % column where dummies for no-missing income residuals in FD are
colc_dif =6;                      % column where residuals in FD of consumption are
coldc_dif =7;                     % column where dummies for no-missing consumption residuals in FD are

datac = [x(:,colc_dif) x(:,coldc_dif) x(:,col_id) x(:,col_year)];
datay = [x(:,coly_dif) x(:,coldy_dif) x(:,col_id) x(:,col_year)];
datac = sortrows(datac,[3 4]);
datay = sortrows(datay,[3 4]);
T  = length(unique(x(:,col_year))); % length of the typical FD panel
N=length(unique(x(:,col_id)));
clearvars x

dif1_j   = zeros(T,T);
d_dif1_j = zeros(T,T);
for j=1:N
    dif1_j   = dif1_j+datac((j-1)*T+1:(j-1)*T+T,1)*datac((j-1)*T+1:(j-1)*T+T,1)';
    d_dif1_j = d_dif1_j+datac((j-1)*T+1:(j-1)*T+T,2)*datac((j-1)*T+1:(j-1)*T+T,2)';
end
dif1    = dif1_j./d_dif1_j;                 % dif contains the empirical moments
d_dif1  = d_dif1_j;                         % d_dif contains the number of observations

dif2_j   = zeros(T,T);
d_dif2_j = zeros(T,T);
for j=1:N
    dif2_j   = dif2_j+datac((j-1)*T+1:(j-1)*T+T,1)*datay((j-1)*T+1:(j-1)*T+T,1)';
    d_dif2_j = d_dif2_j+datac((j-1)*T+1:(j-1)*T+T,2)*datay((j-1)*T+1:(j-1)*T+T,2)';
end
dif2    = dif2_j./d_dif2_j;                 % dif contains the empirical moments
d_dif2  = d_dif2_j;                         % d_dif contains the number of observations

mat1 = ones(T,T);
c1_vector = dif1(logical(triu(mat1)));      % vectorize the matrix of the empirical moments, dif1
d1_vector = d_dif1(logical(triu(mat1)));    % vectorize the matrix of the number of observations, d_dif1
c2_vector = dif2(logical(triu(mat1)));      % vectorize the matrix of the empirical moments, dif2
d2_vector = d_dif2(logical(triu(mat1)));    % vectorize the matrix of the number of observations, d_dif2
c_vector  = [c1_vector;c2_vector];
d_vector  = [d1_vector;d2_vector];

clearvars dif1 d_dif1 dif1_j d_dif1_j dif2 d_dif2 dif2_j d_dif2_j

dim     = length(c_vector);
omega_j = zeros(dim,dim);
for j=1:N
    dif1_j      = datac((j-1)*T+1:(j-1)*T+T,1)*datac((j-1)*T+1:(j-1)*T+T,1)';
    d_dif1_j    = datac((j-1)*T+1:(j-1)*T+T,2)*datac((j-1)*T+1:(j-1)*T+T,2)';
    dif2_j      = datac((j-1)*T+1:(j-1)*T+T,1)*datay((j-1)*T+1:(j-1)*T+T,1)';
    d_dif2_j    = datac((j-1)*T+1:(j-1)*T+T,2)*datay((j-1)*T+1:(j-1)*T+T,2)';
    c1_vector_j = dif1_j(logical(triu(mat1)));
    d1_vector_j = d_dif1_j(logical(triu(mat1)));
    c2_vector_j = dif2_j(logical(triu(mat1)));
    d2_vector_j = d_dif2_j(logical(triu(mat1)));
    c_vector_j  = [c1_vector_j;c2_vector_j];
    d_vector_j  = [d1_vector_j;d2_vector_j];
    omega_j     =omega_j+((c_vector_j-c_vector)*(c_vector_j-c_vector)').*(d_vector_j*d_vector_j');
    clearvars dif_j d_dif_j c_vectr_j d_vector_j
end
omega = omega_j./(d_vector*d_vector');   % omega contains the std errors of the moments

% CASE 1: IF AN ELEMENT J OF C_VECTOR IS NAN, THIS MEANS THERE IS NO DATA IN COMPUTING THAT PARTICULAR MOMENT, I.E. THE J-TH ELEMENT OF D_VECTOR IS ZERO.  CONSEQUENTLY, 
% THE J-TH ROW AND J-TH COLUMN OF OMEGA ARE ZEROS. HERE, TO THE EXTENT THAT THE THEORETICAL COUNTERPART OF THAT MOMENT DOES NOT VARY IN PARAMETERS, WE REPLACE 
% NAN BY 1 (ANY FINITE NUMBER WOULD DO).
mat2=diag(ones(T,1),0)+diag(ones(T-1,1),1)+diag(ones(T-2,1),2);     % MOMENTS MATTER ONLY UP TO THE SECOND-ORDER AUTOCOVARIANCES.
c1_vip_vector = mat2(logical(triu(mat1)));
c2_vip_vector = mat2(logical(triu(mat1)));
c_vip_vector  = [c1_vip_vector;c2_vip_vector];
if max(isnan(c1_vector))==1 && min(c_vip_vector(isnan(c1_vector))==0)==1        % NOT AN IMPORTANT MOMENT
    c_vector (isnan(c1_vector)) = 1;
    omega(isnan(c1_vector),:) = 1;
    omega(:,isnan(c1_vector)) = 1;
elseif max(isnan(c1_vector))==1
    display('WARNING: NO DATA TO COMPUTE AN IMPORTANT MOMENT');
    exit
end

% CASE 2: IF J-TH SAMPLE MOMENT IS COMPUTED FROM ONLY ONE DATA POINT, OR IN THE CASE OF BOOTSTRAP, THE VARIATION OF THAT MOMENT IS ZERO, THEN THE J-TH ROW AND J-TH 
% COLUMN OF OMEGA ARE ZEROS (OR NAN FOR AN ELEMENT WHERE CASE 1 APPLIES). IMPORTANTLY, THE J-TH DIAGONAL OF OMEGA WILL BE ZERO, WHICH WILL BE PROBLEMATIC WHEN WE 
% INVERT THAT NUMBER TO GENERATE THE WEIGHT OF THE MOMENT UNDER DWMD.
if max(diag(omega)==0)==1 && min(c_vip_vector(diag(omega)==0) ==0)==1    % NOT AN IMPORTANT MOMENT
    ind0 = find(diag(omega)==0);
    omega(ind0,ind0)=1;
elseif max(diag(omega)==0)==1
    display('WARNING: SINGLE DATAPOINT TO COMPUTE AN IMPORTANT MOMENT: USE EWMD');
end


moments = [c_vector omega T*ones(length(c_vector),1)];
y=moments;
end