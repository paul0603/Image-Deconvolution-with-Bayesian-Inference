clear

%Whether want to create blur image or not
SYTHETIC=0;

%TRUE KERNEL NAME
TEST_NAME='len_15_arg_0';
%TEST_NAME='len_15_arg_45';
%TEST_NAME='len_15_arg_90';
%TEST_NAME='len_31_curve';
%TEST_NAME='len_31_ring';

%DATA NAME
DATA_NAME='flower';
%DATA_NAME='disney';
%DATA_NAME='lena';

%Path of clear image
CPATH=strcat('../image/',DATA_NAME);


%Choose the prior model type
PRIOR_MODEL='GAUSSIAN';
%PRIOR_MODEL='GAUSSIAN MIXTURE'; %Not complete

%% Create a kernel, blur the image and generate respective constraint kernel and initial kernel for EM-algorithm
if SYTHETIC
    
    %Length of kernel wants to create
    LEN=15;
    
    %Argument of kernel wants to create
    ARG=0;
    
    %The file that restore blur image
    %mkdir ../image/flower/len_15_arg_0/blur
    %mkdir ../image/flower/len_15_arg_45/blur
    %mkdir ../image/flower/len_15_arg_90/blur
    %mkdir ../image/flower/len_31_curve/blur
    %mkdir ../image/flower/len_31_ring/blur
    
    %Load the true kernel 
    load(strcat('../kernel/',TEST_NAME,'.mat'));
    
    %Output file name of blur img
    BLUR_IMAGE_FILE=strcat('../image/',DATA_NAME,'/',TEST_NAME,'/blur');
    
    %Blur the image with given noise var and kernel. Store the number of blur images
    Sythetic_blur(CPATH,TRUE_KERNEL,0.001,BLUR_IMAGE_FILE);
    
    %Load initial kernel which is a delta kernel
    load(strcat('../kernel/','len_15_gerneral.mat'))
    %load(strcat('../kernel/','len_31_gerneral.mat'))
 
else
    
    %%Please place your true kernel, constraint kernel and initial kernel in file kernel with names len_x_arg_y_ + cons/initial_z .mat
    BLUR_IMAGE_FILE=strcat('../image/',DATA_NAME,'/',TEST_NAME,'/blur');
  
    
    %Load initial kernel which is a delta kernel
    load(strcat('../kernel/','len_15_gerneral.mat'))
    %load(strcat('../kernel/','len_31_gerneral.mat'))
end

%% The file that store deblur image
DEBLUR_IMAGE_FILE=strcat('../image/',DATA_NAME,'/',TEST_NAME,'/deblur');

%% Load the required parameter for EM algorithm according to prior type

if strcmp(PRIOR_MODEL,'GAUSSIAN')
  
    %we modify the noise variance in each iteration we start
    %from a higher noise variance because EM algorithms usually
    %converge faster at high noise. The high noise iterations
    %mostly resolve the low frequencies of the kernel, and then
    %we reduce the noise parameter and high freqs get in.
    noise_var_eta=0.03;
    noise_var_eta_v=noise_var_eta*ones(11,1)*(1.05.^[10:-1:0]); 
    noise_var_eta_v=noise_var_eta_v(:);
    
    %set the parameters of our deconvolution problem
    model.prior_ivar(1)=1/0.03;
    model.filts(:,:,1)=[-1 1; 0 0];
    model.filts(:,:,2)=[-1 0; 1 0];
 
    
    model.k_prior_eps=1e-04;
    model.k_beta=1e-04;
    
    
    %determine the ratio of image pyramid
    ret=0.5^0.5;
    
    %Whether to shift the CG of kernel to the center
    model.shiftCG=1;
    
    

elseif strcmp(PRIOR_MODEL,'GAUSSIAN MIXTURE') 
    
    %Load the prior model
    load('../prior/flower3.mat');
    %load('../prior/MOGparams.mat');
    
    %Load the noise variance
    noise_var_eta=0.05;
    noise_var_eta_v=noise_var_eta*ones(11,1)*(1.15.^[10:-1:0]); 
    noise_var_eta_v=noise_var_eta_v(:);
    
    %set the priors
    %for flower3
     for ii=1:size(priors,2)
         model.prior_ivar(ii,:)=priors(ii).gamma;
         model.prior_pi(ii,:)=priors(ii).pi;
     end
    
    %for MOGparams
    %model.prior_ivar(1,:)=ivars;
    %model.prior_pi(1,:)=pis;
  
    
    %set parameters of our deconvolution problem
    model.filts(:,:,1)=[-1 1; 0 0];
    model.filts(:,:,2)=[-1 0; 1 0];
    model.k_prior_ivar=1/400;
    model.k_prior_eps=1e-03;
    model.k_beta=1e-02;
    
    %whether intial x at every itr in conj grad deconv (finding \mu)
    model.init_x_every_itr=0;
    
    %determine the ratio of image pyramid
    ret=0.5^0.5;
    
    %Whether to shift the CG of kernel to the center
    model.shiftCG=1;
    
else
    error('Please choose between GAUSSIAN and GAUSSIAN MIXTURE')
end

%% Counts of EM_steps
J=0;
DEBUG=0;

%% Debug and Result
%keyboard
deblur
figure(1)
imagesc(k)
colormap(gray)
axis off
axis equal

figure(2)
imagesc(TRUE_KERNEL)
colormap(gray)
axis off
axis equal

% J = imrotate(k,-180)




