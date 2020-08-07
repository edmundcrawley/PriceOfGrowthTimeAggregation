function y = criterion_income_boot(x,mFD,mLV,wt)       % Diagonally weighted minimum distance (DWMD)
b    = x;

m    = mFD(:,1);                                 % Vector of covariances
var  = mFD(:,2:length(mFD(1,:))-1);              % Weighting matrix - Variance matrix for optimal mindist
WMD         = wt;

b = exp(b);

fmm = fcninc_income(b,mLV);

if WMD == 1
    invpeso = diag(diag(var).^(-1));
elseif WMD == 2
    invpeso = eye(size(var));
end 
f = (m-fmm)'*invpeso*(m-fmm);     % m is vector of actual covariances - fmm is implied covariances
y = f;   
end
