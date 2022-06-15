
%% Initialize the estimate kernel
KERNEL_ESTIMATE=K_INIT;
model.k=K_INIT;

%kernel size (must be odd)
model.k_sz1=size(K_INIT,1);
model.k_sz2=size(K_INIT,2);

%choose number of pyramid layers
EM_STEP=max(floor(log(5/min(model.k_sz1,model.k_sz2))/log(ret)),0);
retv=ret.^[0:EM_STEP];
%set kernel sizes in each pyramid level, but make sure they are all odd 
k1list=ceil(model.k_sz1*retv);
k1list=k1list+(mod(k1list,2)==0);
k2list=ceil(model.k_sz2*retv);
k2list=k2list+(mod(k2list,2)==0);


%% Read the blur image

%Read the blur image file
BLUR = dir(fullfile(BLUR_IMAGE_FILE,'*.mat')); 

%Number of blur images
NUM_OF_IMG=numel(BLUR);

%% EM-Algorithm

if DEBUG
   diff=zeros(1,EM_STEP+1);
   diff(1)=norm(KERNEL_ESTIMATE-TRUE_KERNEL);
end

%initial kernel
k=resizeKer(model.k,retv(end),k1list(end),k2list(end));

J=EM_STEP+1;
while J>=1
    
    if strcmp(PRIOR_MODEL,'GAUSSIAN')
        maxItr=length(noise_var_eta_v);
        
        for l=1:maxItr
            kz1=size(k,1);
            kz2=size(k,2);
            kz=kz1*kz2;
            A_bar=zeros(kz,kz);
            b_bar=zeros(kz,1);
            
            for i=1:NUM_OF_IMG
                
                load(strcat(BLUR_IMAGE_FILE,'/',BLUR(i).name));
                model.y=img_blur_noise;
                sy=downSmpImC(model.y,retv(J));
                
                tmodel=model;
                tmodel.y=sy; tmodel.k=k;
                tmodel=set_sizes(tmodel);
                tmodel.x=[];
                tmodel.sig_noise=noise_var_eta_v(l);
                tmodel.prior_ivar=model.prior_ivar*sqrt(2)^(J-1);
                
                %E-step get deblur image and covariance
                tmodel=E_Step_img_gaussian(tmodel);
                
                %M-step build the quadratic cost function
                [tA,tb,tc]=getCorAbFreqDiagCov(tmodel.x,tmodel.y,tmodel.xcov{1},tmodel.k_sz1,tmodel.k_sz2);
                A_bar=A_bar+tA;
                b_bar=b_bar+tb;
            end
            %solve the quadratic programming of k=min_k {k'A_bark- b_bar k}  
            %k=solve_for_sps_kernel(A_bar,b_bar,tmodel.k_sz1,tmodel.k_sz2,tmodel.k_prior_ivar);
            k=solve_for_sps_kernel2(A_bar,b_bar,tmodel.k_sz1,tmodel.k_sz2, model.k_prior_eps,model.k_beta);
            if tmodel.shiftCG
                G=[0,0];
                for i=1:kz1
                    for j=1:kz2
                        G=G+k(i,j)*[i,j];
                    end
                end
                G=floor(G);
                d=[(kz1+1)/2,(kz2+1)/2];
                d=d-G;
                k = circshift(k,d(1),1);
                k = circshift(k,d(2),2);
            end
        end
    elseif strcmp(PRIOR_MODEL,'GAUSSIAN MIXTURE')
        
        maxItr=length(noise_var_eta_v);
        
        for l=1:maxItr
            kz1=size(k,1);
            kz2=size(k,2);
            kz=kz1*kz2;
            A_bar=zeros(kz,kz);
            b_bar=zeros(kz,1);
            
            for i=1:NUM_OF_IMG
                
                load(strcat(BLUR_IMAGE_FILE,'/',BLUR(i).name));
                model.y=img_blur_noise;
                sy=downSmpImC(model.y,retv(J));
                
                tmodel=model;
                tmodel.y=sy; tmodel.k=k;
                tmodel=set_sizes(tmodel);
                tmodel.filtx=[];
                tmodel.x=[];
                tmodel.sig_noise=noise_var_eta_v(l);
                tmodel.prior_ivar=model.prior_ivar(1,:);
                tmodel.prior_pi=model.prior_pi(1,:);
                tmodel=filt_y(tmodel);

                %E-step
                tmodel=E_Step_filt_MOG(tmodel);
                
                %M-step build the quadratic cost function
                for ll=1:size(tmodel.filtx,3)
                    [tA,tb,tc]=getCorAbDiagCov(tmodel.filtx(:,:,ll),tmodel.filty(:,:,ll),tmodel.filtxcov{1},tmodel.k_sz1,tmodel.k_sz2);
                    A_bar=A_bar+tA;
                    b_bar=b_bar+tb;
                end
            end
            %solve the quadratic peogramming of k=min_k {k'A_bark- b_bar k}           
            k=solve_for_sps_kernel2(A_bar,b_bar,tmodel.k_sz1,tmodel.k_sz2,tmodel.k_prior_eps,tmodel.k_beta);
            if tmodel.shiftCG
                G=[0,0];
                for i=1:kz1
                    for j=1:kz2
                        G=G+k(i,j)*[i,j];
                    end
                end
                G=floor(G);
                d=[(kz1+1)/2,(kz2+1)/2];
                d=d-G;
                k = circshift(k,d(1),1);
                k = circshift(k,d(2),2);
            end
        end
    end
        
        
    
    J=J-1;
    if J>0
        k=resizeKer(k,1/ret,k1list(J),k2list(J));
    end
   
               
end
  

