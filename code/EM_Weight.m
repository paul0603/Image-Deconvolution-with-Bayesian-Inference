addpath('../matlabPyrTools-master')
DI='../image/flower/';
DB='../image/flower/len_15_arg_90/blur';
SI=dir(fullfile(DI,'*.jpg'));
SB=dir(fullfile(DB,'*.jpg'));
N=max(size(SB));

errI=zeros(N,8);
errB=zeros(N,8);

for k=1:N
    FI = fullfile(DI,SI(k).name);
    I=im2double(imread(FI));
%     g_x = conv2(I,[1 -1],'valid'); 
%     g_y = conv2(I,[1 -1]','valid');

    [pyr,indices] = buildSpyr(I);
        
    g_x = spyrBand(pyr,indices,1,1);
    g_y = spyrBand(pyr,indices,1,2);
    grad = [g_x(:)' , g_y(:)' ];

    

    num=3;
    STEP_SIZE=0.001;
    x = [-0.7:STEP_SIZE:0.7];

    hista = hist(grad,x);
    hista=hista/sum(hista);

    pdf_total_x = zeros(size(x));

    for i=1:8
        for c=1:num
            pdf_x = priors(i).pi(c) * normpdf(x,0,sqrt(1/priors(i).gamma(c)));
            pdf_total_x = pdf_total_x + pdf_x;
        end
        pdf_total_x=pdf_total_x*STEP_SIZE*sum(hista);
        errI(k,i)=norm(hista-pdf_total_x);
    end

    FB = fullfile(DB,SB(k).name);
    B=im2double(imread(FB));
    
%     g_x = conv2(B,[1 -1],'valid'); 
%     g_y = conv2(B,[1 -1]','valid');
    [pyr,indices] = buildSpyr(B);
        
    g_x = spyrBand(pyr,indices,1,1);
    g_y = spyrBand(pyr,indices,1,2);
    grad = [g_x(:)' , g_y(:)' ];

    

    num=3;
    STEP_SIZE=0.001;
    x = [-0.7:STEP_SIZE:0.7];

    hista = hist(grad,x);
    hista=hista/sum(hista);

    pdf_total_x = zeros(size(x));

    for i=1:8
        for c=1:num
            pdf_x = priors(i).pi(c) * normpdf(x,0,sqrt(1/priors(i).gamma(c)));
            pdf_total_x = pdf_total_x + pdf_x;
        end
        pdf_total_x=pdf_total_x*STEP_SIZE*sum(hista);
        errB(k,i)=norm(hista-pdf_total_x);
    end
end

ERRI=mean(errI)
ERRB=mean(errB)
