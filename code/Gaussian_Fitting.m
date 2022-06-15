function [var,loss]=Gaussian_Fitting(p,edges,isplot)

N=max(size(p));
X=zeros(1,N);

for i=1:N
    X(i)=(edges(i)+edges(i+1))/2;
end

    function z=F(sigma)
       z=sum(((1/(sigma*(2*pi)^(0.5)))*exp(-X.^2/(2*sigma^2))-p).^2);
    end
if isplot==1
    x=linspace(-100,100,2000);
    for i=1:2000
        yy(i)=F(x(i));
    end
    figure(1234)
    plot(x,yy)
    title('Loss function of fitting');
end


fun=@F; 
A=[];
b=[];
x0=1;
Aeq=[];
beq=[];
lb=0;
ub=[];
nonlcon=[];
options = optimoptions('fmincon','Display','iter','Algorithm','interior-point','HessianApproximation','lbfgs');
var=fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options);
loss=F(var);
end

