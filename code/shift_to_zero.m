function [Gx,Gy]=shift_to_zero(im)
%here we can use either sobel filter or any other filter that imgradient function support

im=im2double(im);
m=mean(im,'all');%mean of the grayscale image
im=im-m;%Remove the mean
[Gx,Gy] = imgradientxy(im,'sobel');

Gx=Gx(:);
Gy=Gy(:);

end