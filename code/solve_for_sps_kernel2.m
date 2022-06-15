function k=solve_for_sps_kernel2(A,b,k_sz1,k_sz2,scla,beta);


A0=(A+A')/2;
k=quadprog(A0,-b,[],[],[],[],zeros(k_sz1*k_sz2,1));
k_init=zeros(k_sz1*k_sz2,1);
N=0;
residue=1;
while(residue>1e-07)
    N=N+1;
    
    r=k-k_init;
    r(abs(r).^2<scla)=0;
    k_init=k;
    
    k=quadprog(A0+beta*eye(size(A0)),-(b-beta*r),[],[],[],[],zeros(k_sz1*k_sz2,1));
    
    residue=sum(abs(k-k_init));
    scla=scla/2;
    beta=2*beta;
    if N>5
        break;
    end

end


k=reshape(k,k_sz1,k_sz2);
