
path='../image/flower';
S=dir(fullfile(path,'*.jpg'));
num_of_img=max(size(S));



for i=1:num_of_img
   I=imread(strcat(path,'/',S(i).name));
   I=im2double(I);
   [Gx,Gy] = imgradientxy(I,'sobel');
   G(:,i)=[Gx(:);Gy(:)];
    
end
mean(G(:))