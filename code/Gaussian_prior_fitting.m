%We make the prior from the photo in the folder "resize_data", which
%contains 'num_of_image' photos.
%for each photo we randomly pick N patches with size m*n and calculate the
%gradient image of each patch
%here we use sobel filter, and for each patch we make the gradient mag with
%0 mean

function Gaussian_prior_fitting(N,m,isplot,nbins,epsilon)
D='../image/flower';
M=m*m; %number of pixels in a patch
S = dir(fullfile(D,'*.jpg'));
num_of_image=numel(S);% num of image in the folder


%find the size of image in this folder using the first image
F = fullfile(D,S(1).name);
I = imread(F);
sz=size(I);
X=zeros(num_of_image*N,M);
Y=X;

for k=1:num_of_image
    F = fullfile(D,S(k).name);
    I = imread(F);
    
   
    i=floor(sz(1)*rand(N,1)-m);
    i(i<=0)=1;
   
    j=floor(sz(2)*rand(N,1)-m);
    j(j<=0)=1;
    
    
    for l=1:N
        [X((k-1)*N+l,:),Y((k-1)*N+l,:)]=shift_to_zero( I( i(l):i(l)+m-1 , j(l):j(l)+m-1 ));
    end

end

X=X(:);
for i=1:num_of_image*N*M
    if (abs(X(i))<epsilon)
        X(i)=0;
    end
end

X(X==0)=[];


Y=Y(:);
for i=1:num_of_image*N*M
    if (abs(Y(i))<epsilon)
        Y(i)=0;
    end
end

Y(Y==0)=[];

X=X-mean(X);
Y=Y-mean(Y);


[px,edgesx] = histcounts(X,nbins);
px=px/max(size(X));
edgesxx=edgesx;
x=edgesx;
x(1)=[];
edgesx(51)=[];
x=(x+edgesx)/2;

[py,edgesy] = histcounts(Y,nbins);
py=py/max(size(Y));
edgesyy=edgesy;
y=edgesy;
y(1)=[];
edgesy(51)=[];
y=(y+edgesy)/2;

pdx = fitdist(X,'Normal');
pdy = fitdist(Y,'Normal');

if isplot==1
    y_values=pdf(pdx,x);
    y_values=y_values/sum(y_values);
    figure(01)
    plot(x,y_values);
    hold on
    histogram('BinEdges',edgesxx,'BinCounts',px);
    title('Gaussian Fitting of Gx')
end

% options = fitoptions('gauss1');
% gx = fit(x.',px.','gauss1',options);
% gy = fit(y.',py.','gauss1',options);
% 
% if isplot==1
%     figure(01)
%     plot(gx,x,px);
%     hold on
%     histogram('BinEdges',edgesxx,'BinCounts',px);
%     title('Gaussian Fitting of Gx')
% end

% [varx,lossx]=Gaussian_Fitting(px,edgesx,isplot);
% [vary,lossy]=Gaussian_Fitting(py,edgesy,isplot);

% if isplot==1
%     figure(10000)
%     histogram('BinEdges',edgesx,'BinCounts',px);
%     hold on
%     x=linspace(min(edgesx)-1,max(edgesx)+1,1000);
%     y=normpdf(x,0,varx);
%     plot(x,y);
%     title('Gaussian Fitting of Gx')
% end


end