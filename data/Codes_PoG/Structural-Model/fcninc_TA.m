function y=fcninc(x,m,s)

b           = x;
ma          = s(1);
varying_et  = s(5);
pattern     = s(6:length(s));
pattern_et  = pattern(3:length(pattern)-1);
ind_et      = find(pattern_et);
T           = m(1,length(m(1,:)));               % Length of the restricted panel (in FD)
T_full      = length(pattern)-1;

survey_years = find(pattern(1:end-1)==1); %remove iniyear (specified in mainresults
time_multiplier = diff(survey_years);
constants = (pattern==1).*(1/3*pattern) + (pattern==0).*(pattern+1); %constants needed to calculate variance of income change.

if varying_et == 1 || varying_et == 2
    T_e = T-1;
elseif varying_et == 3
    T_e = T_full - 5;
elseif varying_et == 4
    T_e = 2*(T-1)-1;
end
T_z = T-2;

if ma == 1
    teta = b(1);
    zt  = b(2:2+T_z-1);   
    et  = b(2+T_z:2+T_z+T_e-1);
else
    teta = 0;
    zt  = b(1:1+T_z-1);   
    et  = b(1+T_z:1+T_z+T_e-1);
end
dify  =zeros(T,T);

% This is the variance of Income
if varying_et == 1
    for j=1:T
        dify(j,j)=zt(min(max(j-1,1),T_z)) + et(min(j,T_e)) + (1-teta)^2*et(min(max(j-1,1),T_e)) + teta^2*et(min(max(j-2,1),T_e));
        if j>=2
            dify(j-1,j)=-(1-teta)*et(min(j-1,T_e)) + teta*(1-teta)*et(min(max(j-2,1),T_e));
            if j>=3
                dify(j-2,j)=-teta*et(min(j-2,T_e));
            else
            end
        else
        end
    end    
elseif varying_et == 2
    for j=1:T
        if j<T
            %dify(j,j)=zt(min(max(j-1,1),T_z)) + (1+teta^2)*et(min(j,T_e)) + (1+teta^2)*et(min(max(j-1,1),T_e));
            %dify(j,j)= time_multiplier(j)* zt(min(max(j-1,1),T_z)) + (1+teta^2)*et(min(j,T_e)) + (1+teta^2)*et(min(max(j-1,1),T_e));
            
            dify(j,j)= constants(survey_years(j+1)) * zt(min(max(j-1,1),T_z)) + constants(survey_years(j))*zt(min(max(j-2,1),T_z)) +(survey_years(j+1)-survey_years(j)-1)*zt(min(max(j-1,1),T_z)) + et(min(j,T_e)) + et(min(max(j-1,1), T_e));

        else
            %dify(T,T)=1.5*zt(T_z) + (1+teta^2)*et(T_e) + (1+teta^2)*et(T_e);
            %dify(T,T)=time_multiplier(j)*zt(T_z) + (1+teta^2)*et(T_e) + (1+teta^2)*et(T_e);
            
            dify(T,T) = constants(survey_years(T+1)) * zt(T_z) +constants(survey_years(T))*zt(T_z) +(survey_years(T+1)-survey_years(T)-1)*zt(T_z)+ et(T_e) + et(T_e)
        end
        
        if j>=2
            %dify(j-1,j)=-(1+teta^2)*et(min(j-1,T_e)); %this is the covariance of y(t-1) and y t
            dify(j-1,j)=(1/6)*zt(min(max(j-2,1),T_z)) - et(min(j,T_e))
        else
        end
    end
elseif varying_et == 3
    for j=1:T
        if j<T
            dify(j,j)=zt(min(max(j-1,1),T_z))+et(min(ind_et(j),T_e))+teta^2*et(min(max(ind_et(j)-1,1),T_e))+et(min(max(ind_et(max(j-1,1)),1),T_e))+teta^2*et(min(max(ind_et(max(j-1,1))-1,1),T_e));
        else
            dify(T,T)=1.5*zt(T_z)+et(T_e)+teta^2*et(T_e)+et(T_e)+teta^2*et(T_e-1);
        end
        if j<T
            dify(j,j+1)=-et(min(ind_et(j),T_e))-teta^2*et(min(max(ind_et(j)-1,1),T_e));
        else
        end
    end
elseif varying_et == 4
    for j=1:T
        if j==1
            dify(1,1)=zt(1)+et(1)+et(1);
        elseif j<T
            dify(j,j)=zt(min(max(j-1,1),T_z))+et(min(j+1,T_e))+et(min(j-1,T_e));
        else
            dify(T,T)=1.5*zt(T_z)+et(T_e)+et(T_e);
        end
        if j<T
            dify(j,j+1)=-et(min(2*j-1,T_e));
        else
        end
    end
end

i=2;
while i<=T
    j=i;
    while j<=T
        dify(j,i-1)=dify(i-1,j);
        j=j+1;
    end
    i=i+1;
end

mat1=ones(length(dify(:,1)),length(dify(1,:)));
fm=dify(logical(triu(mat1)));
y=fm;
end
