function prob=E_Step_filt_MOG(prob)
    
    sig_noise=prob.sig_noise;
    [N1,N2,N3]=size(prob.filty);
    N=N1*N2;
    %While filty is N1xN2, we solve for a M1xM2 x, to include all
    %variables required for expressing the convolution at the
    %boundaries 
    M1=N1+prob.k_sz1-1;
    M2=N2+prob.k_sz2-1;
    M=M1*M2;
    L=length(prob.prior_ivar);
    mask=zero_pad(ones(N1,N2),(prob.k_sz1-1)/2,(prob.k_sz2-1)/2);
    da1=1/sig_noise^2*conv2(mask,abs(prob.k).^2,'same');
   
    filty=prob.filty;    
    init_iv=sum(prob.prior_ivar.*prob.prior_pi);
    
    
    %itrN is the number of mixture component estimation iterations.
    %if L==1 we have a Gaussian prior and hence there is no need
    %for mixture component estimation, we just solve for x in a
    %single iteration
    itrN=2*(L>1)+1; 
            
    use_prev_x=(~prob.init_x_every_itr)&(~isempty(prob.filtx))&(L>1);
    for j=1:N3
              
      if use_prev_x
         x=prob.filtx(:,:,j);
         xcov=prob.filtxcov{j};
      end
      for itr=1:itrN  
        
         if (itr==1)&(~use_prev_x)
            w=init_iv*ones(M1,M2);
            cpi=ones(M,1)*(prob.prior_pi);
         else
            %compute expected derivative magnitude using mean and covariance 
            ex2=abs(x(:)).^2+xcov(:);
            %compute the distribution on hidden variables q(h_i==j)
            logpi=-0.5*ex2*prob.prior_ivar...
                  +ones(M,1)*(log(prob.prior_pi)+0.5*log(prob.prior_ivar));
            cpi=normexp(logpi);
            %compute derivative regularization weights
            w=cpi*(prob.prior_ivar)';
            w=reshape(w,M1,M2);
         end
         %Use the conjugate gradient algorithm to solve a weighted
         %deconvolution problem, that is, find x such that
         %convolved with k, we get filty up to noise, plus we minimize
         %the squared magnitude of each entry of x (remember, we
         %solve in the gradient domain, so the entries of x here
         %are the derivatives of the actual latent image). The
         %penalty on each entry is weighted by the non uniform
         %weights w computed above. 
         [x]=conjgrad_deconv_g(filty(:,:,j),prob.k,sig_noise^2,15,w);
         
         
         %We estimate a diagonal covariance which is just the inverse
         %diagonal of the weighted deconvolution system we have
         %just solved.
         da2=w;
         xcov=1./(da1+da2);
                   
      end
     
      prob.filtx(:,:,j)=x;        
      prob.filtxcov{j}=xcov;
    
      
    end
     
    
 
    
    
    