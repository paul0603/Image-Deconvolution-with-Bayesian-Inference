%lambda=1e-4
function x_hat=Gaussian_E_step(k,y,varx,vary,lambda)
gx=[1,0,-1;2,0,-2;1,0,-1];% sobel filter for x direction
gy=[1,2,1;0,0,0;-1,-2,-1];% sobel filter for y direction 
sz=size(y);

K=psf2otf(k,sz); %When initial kernel is in spatial domain

Y=fft2(y);

Gx=psf2otf(gx,sz);
Gy=psf2otf(gy,sz);
% Gx=zeros(sz);
% Gy=zeros(sz);

% K_x=Gx.*K;
% K_y=Gy.*K;

% Y_x=Gx.*Y;
% Y_y=Gy.*Y;



X_est= (2*conj(K).*Y)./ (2*(abs(K).^2) + (lambda/varx^2)*(abs(Gx).^2) + (lambda/vary^2)*(abs(Gy).^2) +1e-13);
x_hat=real(ifft2(X_est));


end