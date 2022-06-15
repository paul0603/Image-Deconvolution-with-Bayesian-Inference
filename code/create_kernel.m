function create_kernel(len,arg,noise_var_initial,arg_cons)

%Create true kernel and constraint kernel with respect to lenghth and argument
if 45<=arg && arg<=90
    h = fspecial('motion',len,arg);
    h_cons=fspecial('motion',len,arg_cons);
    
    [n,m]=size(h);
    [n_cons,m_cons]=size(h_cons);
    
    TRUE_KERNEL=zeros(n);
    K_CONS=zeros(n_cons);
    
    l=(n-m)/2;
    l_cons=(n_cons-m_cons);
    
    TRUE_KERNEL(:,l+1:l+m)=h;
    K_CONS(:,l_cons+1:l_cons+m)=h_cons;
    
    save(strcat('../kernel/','len_',num2str(len),'_arg_',num2str(arg),'.mat'),'TRUE_KERNEL')
    save(strcat('../kernel/','len_',num2str(len),'_arg_',num2str(arg),'_cons','.mat'),'K_CONS')
elseif 0<=arg && arg<45
    h = fspecial('motion',len,arg);
    h_cons=fspecial('motion',len,arg_cons);
    
    [n,m]=size(h);
    [n_cons,m_cons]=size(h_cons);
    
    TRUE_KERNEL=zeros(m);
    K_CONS=zeros(m_cons);
    
    l=(m-n)/2;
    l_cons=(m_cons-n_cons)/2;
    
    TRUE_KERNEL(l+1:l+n,:)=h;
    K_CONS(l_cons+1:l_cons+n_cons,:)=h_cons;
    
    save(strcat('../kernel/','len_',num2str(len),'_arg_',num2str(arg),'.mat'),'TRUE_KERNEL')
    save(strcat('../kernel/','len_',num2str(len),'_arg_',num2str(arg),'_cons','.mat'),'K_CONS')
else
    error('Please make sure 0<=arg<=90')
end

%Create initial kernel
K_INIT=imnoise(TRUE_KERNEL,'gaussian',0,noise_var_initial);
K_INIT=K_INIT/sum(sum(K_INIT));
save(strcat('../kernel/','len_',num2str(len),'_arg_',num2str(arg),'_initial_',num2str(noise_var_initial),'.mat'),'K_INIT')

end