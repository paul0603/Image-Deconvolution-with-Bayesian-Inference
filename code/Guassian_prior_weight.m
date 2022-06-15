%Weight in M-step with Gaussian priors 


function w=Guassian_prior_weight(nbins,im)

[Gx,Gy] = imgradientxy(im);
Gx=Gx(:);
Gy=Gy(:);

[px,edgesx]=histcounts(Gx,nbins);
[py,edgesy]=histcounts(Gy,nbins);

px=px/max(size(Gx));
py=py/max(size(Gy));

Edgesx=zeros(1,nbins);
Edgesy=zeros(1,nbins);

for l=1:nbins
    Edgesx(l)=(edgesx(l)+edgesx(l+1))/2;
    Edgesy(l)=(edgesy(l)+edgesy(l+1))/2;
end

nx=normpdf(Edgesx,0,varx);
ny=normpdf(Edgesy,0,vary);

err_x=px-nx;
err_y=py-ny;

err=sum(err_x.^2+err_y.^2);
w=exp(-err);


end