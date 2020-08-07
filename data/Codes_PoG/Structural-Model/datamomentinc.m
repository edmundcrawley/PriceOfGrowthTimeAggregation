function y=datamomentinc(d)
x=d;

col_id   =1;                      % colum where id is
col_year =2;                      % column where year (or round) is
coly_dif =4;                      % column where residuals in FD of income are
coldy_dif=5;                      % column where dummies for no-missing income residuals in FD are

data=[x(:,coly_dif) x(:,coldy_dif) x(:,col_id) x(:,col_year)];
data=sortrows(data,[3 4]);          % sort the data by id and year.
T  = length(unique(x(:,col_year))); % length of the typical FD panel
N=length(unique(x(:,col_id)));

clearvars x

dif_j   =zeros(T,T);
d_dif_j =zeros(T,T);
for j=1:N
    dif_j   = dif_j+data((j-1)*T+1:(j-1)*T+T,1)*data((j-1)*T+1:(j-1)*T+T,1)';
    d_dif_j = d_dif_j+data((j-1)*T+1:(j-1)*T+T,2)*data((j-1)*T+1:(j-1)*T+T,2)';
end
dif = dif_j./d_dif_j;               % dif contains the empirical moments
d_dif = d_dif_j;                    % d_dif contains the number of observations

mat1=ones(T,T);
c_vector = dif(logical(triu(mat1)));        % vectorize the matrix of the empirical moments, dif
d_vector = d_dif(logical(triu(mat1)));      % vectorize the matrix of the number of observations, d_dif
clearvars dif d_dif dif_j d_dif_j

dim    =length(c_vector);
omega_j  =zeros(dim,dim);
for j=1:N
    dif_j       = data((j-1)*T+1:(j-1)*T+T,1)*data((j-1)*T+1:(j-1)*T+T,1)';
    d_dif_j     = data((j-1)*T+1:(j-1)*T+T,2)*data((j-1)*T+1:(j-1)*T+T,2)';
    c_vector_j  = dif_j(logical(triu(mat1)));
    d_vector_j  = d_dif_j(logical(triu(mat1)));
    omega_j     = omega_j+((c_vector_j-c_vector)*(c_vector_j-c_vector)').*(d_vector_j*d_vector_j');
    clearvars dif_j d_dif_j c_vectr_j d_vector_j
end
omega = omega_j./(d_vector*d_vector');   % omega contains the std errors of the moments

moments = [c_vector omega T*ones(length(c_vector),1)];
y=moments;
end