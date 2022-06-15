%Weight in M-step with GSM priors 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% num=3; %Component in GSM model
% STEP_SIZE=0.001; % The size of bin
% priors=load('../prior/flower3.mat'); %the parameter for prior distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function w=GSM_prior_weight(step_size,im,priors,rho)

addpath('../matlabPyrTools-master') %We need the steer image pyramid library

num=max(size(priors.pi));
x = [-0.7:step_size:0.7];

%%gradient of the image
[pyr,indices] = buildSpyr(im);
g_x = spyrBand(pyr,indices,1,1);
g_y = spyrBand(pyr,indices,1,2);
grad = [g_x(:)' , g_y(:)' ];

%%build the histagram of gradient image with respect to x
hista = hist(grad,x);
hista=hista/sum(hista);

%%build the prior histogram with same x 
pdf_total_x = zeros(size(x));

for c=1:num
    pdf_x = priors.pi(c) * normpdf(x,0,sqrt(1/priors.gamma(c)));
    pdf_total_x = pdf_total_x + pdf_x;
end
pdf_total_x=pdf_total_x*step_size*sum(hista);


w=exp(-norm(pdf_total_x-hista)^2*rho);

end
