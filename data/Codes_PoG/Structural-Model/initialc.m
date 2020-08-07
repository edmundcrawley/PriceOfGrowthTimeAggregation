function y = initialc(y0,gy,pmtr)
eta         = pmtr(1);
r           = pmtr(2);
T           = pmtr(3);
savingrate  = pmtr(4);
beta        = 0.98;
gc          = (beta*(1+r))^(1/eta);

factory = 1;
factorc = 1;
for t=1:T  
    factory = factory + (gy/(1+r))^t;
    factorc = factorc + (gc/(1+r))^t;
end

y = (1-savingrate)*y0*factory/factorc; 
end