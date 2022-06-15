%%%%%%%%%%%%%%%
%Blur the true image with given kernel and gaussian noise variance
%%%%%%%%%%%%%%%

function Sythetic_blur(path,kernel,noise_var,des)
DEBUG=0;

S = dir(fullfile(path,'*.jpg')); % clear image.
num_of_img=numel(S);%number of images in the file


for i=1:num_of_img % each column of X is a vectorize blur img from data base.
    img=imread(strcat(path,'/image_',num2str(i,'%05d'),'.jpg'));
    img=im2double(img);
%     img_blur=fftconv(img,kernel);
    img_blur=conv2(img,kernel,'same');
    
    if noise_var>0
        img_blur_noise=imnoise(img_blur,'gaussian',0,noise_var);
    else
        img_blur_noise=img_blur;
    end
    
    if DEBUG
    figure(1);
    subplot(1,3,1)
    imshow(img);
    subplot(1,3,2)
    imshow(img_blur);
    subplot(1,3,3)
    imshow(img_blur_noise);
    end
    
    imwrite(img_blur_noise,strcat(des,'/image_blur_',num2str(i,'%05d'),'.jpg'));
    save(strcat(des,'/image_blur_',num2str(i,'%05d'),'.mat'),'img_blur_noise');
    
end

end
