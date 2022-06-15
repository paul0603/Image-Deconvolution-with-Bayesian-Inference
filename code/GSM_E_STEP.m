% lambda=1e-5;
function x_hat=GSM_E_STEP(k,y,prior,m,lambda)

num=max(size(prior.pi));
gx=[1,0,-1;2,0,-2;1,0,-1];% sobel filter for x direction
gy=[1,2,1;0,0,0;-1,-2,-1];% sobel filter for y direction 
sz=size(y);

K=psf2otf(k,sz); %When initial kernel is in spatial domain

Y=fft2(y);

Gx=psf2otf(gx,sz);
Gy=psf2otf(gy,sz);

if strcmp(class(m),'char')
    [YGx,YGy] = imgradientxy(y,'sobel');
    m=ones(sz)*mean([YGx(:);YGy(:)]);
    M=fft2(m);
elseif strcmp(class(m),'double')
    m=ones(sz)*m;
    M=fft2(m);
else
    error('Mean either be a double number or self')
end

% Gx=zeros(sz);
% Gy=zeros(sz);

% K_x=Gx.*K;
% K_y=Gy.*K;

% Y_x=Gx.*Y;
% Y_y=Gy.*Y;

down=2*(abs(K).^2);
for i=1:num
   down=down + lambda*((prior.gamma(i))*(abs(Gx).^2) + (prior.gamma(i))*(abs(Gy).^2));
end
X_est= (2*conj(K).*Y+Gx.*M  + Gy.*M)./ (down );
x_hat=real(ifft2(X_est));


end