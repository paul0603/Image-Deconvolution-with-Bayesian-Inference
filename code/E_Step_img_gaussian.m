function model=E_Step_img_gaussian(model)

%variance of noise
sig_noise=model.sig_noise;

%Number of filter. dx and dy are default.
N3=size(model.filts,3);

%kernel and blur image
k=model.k;
y=model.y;

%This should reduce some of the cyclic deconvolution artifacts
y=edgetaper(y,k);

%size and pixel number of image 
[N1,N2,N4]=size(y);
N=N1*N2;

%size of kernel
k_sz1=model.k_sz1;
k_sz2=model.k_sz2;

%prior term in eq(18) in Levin's paper
ig=0;

%calculate the prior term for each filter see eq(19)
for j=1:N3
    tg=fft2(model.filts(:,:,j),N1,N2);
    tg(1,1)=max(tg(1,1),0.001);
    ig=ig+abs(tg).^2;
end
ig=ig*model.prior_ivar/N3;

%zero pad the kernel to the same size as image since we want to calculate convolution in frequency domain
k=zero_pad2(model.k,ceil((N1-model.k_sz1)/2),floor((N1-model.k_sz1)/2),ceil((N2-model.k_sz2)/2), floor((N2-model.k_sz2)/2) );
%perform fourier transform of the kernel. Note that we swap the kernel first since we
%want to avoid cyclic deconvolution artifacts
K=fft2(ifftshift(k));

%calculate the cov in frequency domain as in eq(19)
xfreqcov=1./(1/sig_noise^2*abs(K).^2+ig);

%for each color channel we calculate the mean and cov. Actually cov is the
%same in every channel
for j0=1:N4
    
    %obtain the deblur image from eq(21)
    y0=y(:,:,j0);
    Y=fft2(y0)/(N)^0.5;
    X=1/sig_noise^2*xfreqcov.*(K).*Y;
    x=real(ifft2(X)*(N)^0.5);
    
    model.x(:,:,j0)=x; 
    model.xcov{j0}=xfreqcov;
end

end