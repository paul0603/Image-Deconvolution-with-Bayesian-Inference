% epsilon_s=0.0001;
% beta=5;
% epsilon_k=1e-13;
function kernel_estimate=GSM_M_STEP(blur,deblur,blur_img_file,deblur_img_file,k_cons,weight,beta,lambda,epsilon,max_iter,im_size)

num_of_img=max(size(deblur));

%Size of kernel
ker_sz=size(k_cons);

% sobel filter for x direction
gx=[1,0,-1;2,0,-2;1,0,-1];
% sobel filter for y direction 
gy=[1,2,1;0,0,0;-1,-2,-1];

%Matrix where every entry is one. The dimension of it is equal to the image
I=ones(im_size);

%Count the iteration
iter=0;

%Residual of eq...
residual=1;

%The numerator of eq...
up=zeros(im_size);
%The denumerator of eq...
down=zeros(im_size);

%Constraint kernel in frequency domain
K_CONS=psf2otf(k_cons,im_size);

%Initialize kernel estimate to be contraint kernel
kernel_estimate=k_cons;

while(residual>epsilon)
    
    iter=iter+1;
    
    %Optimizing the kernel constraint part
    r=kernel_estimate-k_cons;
    r(abs(r).^2<=lambda/beta)=0;
    
    R=psf2otf(r,im_size);
    
    %Optimize the second part. We turn to frequency domain
    for i=1:num_of_img
        
        %Load the deblur image  (img_deblur)
        load(strcat(deblur_img_file,'/',deblur(i).name));
        %Load the blur image    (img_blur_noise)
        load(strcat(blur_img_file,'/',blur(i).name));
       
        %Gradient image of deblur img
        Ix=fftconv(img_deblur,gx);
        Iy=fftconv(img_deblur,gy);
        
        %Gradient image of deblur img
        Bx=fftconv(img_blur_noise,gx);
        By=fftconv(img_blur_noise,gy);
        
        
        up= up + (conj(Ix).*Bx + conj(Iy).*By)*weight(i);
        down= down + (conj(Ix).*Ix + conj(Iy).*Iy)*weight(i);
        
        
    end
    
    up = up + beta*(K_CONS + R);
    down = down + beta*I + 1e-13;
    
    %The update kernel estimate
    K_est=up./down;
    
    %Since we do the optimization in frequency domain, we need to turn back
    %to spatial doamin and remember, kernel is of sum 1 and every entry is
    %positive.
    kernel_estimate_ref=real(otf2psf(K_est,ker_sz));
    kernel_estimate_ref(kernel_estimate_ref<0.022)=0;
    kernel_estimate_ref=kernel_estimate_ref/sum(sum(kernel_estimate_ref));
    
    %Decrease the parameter so that the two step optimization conv to the
    %original one. This is similiar to ADMM
    lambda=lambda/2;
    residual=norm(kernel_estimate-kernel_estimate_ref)/norm(kernel_estimate);
    
    kernel_estimate=kernel_estimate_ref;
    
    if(iter>max_iter)
        break;
    end
end

