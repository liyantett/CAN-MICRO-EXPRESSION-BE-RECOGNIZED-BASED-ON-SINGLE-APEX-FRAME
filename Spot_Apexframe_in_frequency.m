%This is the code spotting apex frame in frequency domain whcih is
%presented in 
%'Li, Yante, Xiaohua Huang, and Guoying Zhao. 
%"Can micro-expression be recognized based on single apex frame?." 
%2018 25th IEEE International Conference on Image Processing (ICIP). IEEE, 2018..
%This code is only for reseach use
%If you have any question, please contact 'yante.li@oulu.fi'

clc
clear

%The micro-expression mat files path 
%Each micro-expression sequence is stored as a .mat file in folder 'casme2_mat'
imagepath = ['.\casme2_mat\'];

folder = dir(imagepath);
%define 'detect' to store detected apex index
detect=zeros(length(folder)-2,1);
%compute the 256 micro-sequences in folder 'casme2_mat' one by one
 for m=3:length(folder)   
    %load the original mat
    fname = folder(m).name;
    load(['casme2_mat/',fname]);
    [NR NC NZ] = size(p);  
    NR=NR-2;
    NC=NC-2; 
    %extracting lbp features for each frame of micro-experssion sequence
    features=zeros(NR,NC,NZ);
     for k=1:NZ
        features(:,:,k)= lbp(p(:,:,k));
     end
     
     %sliding window length
     window=61;
     %extending beginning and ending frame to (window-1)/2
     feature_beginning=repmat(features(:,:,1),[1,1,ceil((window-1)/2)]);
     feature_ending=repmat(features(:,:,NZ),[1,1,ceil((window-1)/2)]);
     features=cat(3,feature_beginning,features,feature_ending);
     
  
  %Deviding each frame to blocks
  block_num=6;
  for n=1:NZ-1
     ftnw=features(:,:,[n:(n+window-1)]);  
     b_w=fix((NR-1)/block_num); 
     b_h=fix((NC-1)/block_num);  
     q=window;
     m_mid=fix(b_w/2);  %
     n_mid=fix(b_h/2);   
     q_mid=fix((q+1)/2);  
       
     %threshold
     d0=((window+1)/2); 
     %define HBF filter, correspoing eqution (2) in the paper         
       for i=1:b_w  
           for j=1:b_h  
               for k=1:q    
                   d=sqrt((i-m_mid)^2+(j-n_mid)^2+(k-q_mid)^2);    
                   if d>=d0                        
                        h(i,j,k)=1;  
                    else  
                         h(i,j,k)=0;  
                     end   
                end  
           end  
        end            
            
  %The frequency value after filtering for each block
  img_hpf=zeros(b_w,b_h,q);
  
  ii=0;
  fx=cell(block_num,block_num);
  for i=1:b_w:(NR-b_w)
    ii=ii+1;
    jj=0;
    
    for j=1:b_h:(NC-b_h)
        jj=jj+1;
        %computing fft, correspoing eqution (1) in the paper  
        ftn=ftnw(i:(i+b_w-1),j:(j+b_h-1),:);
        ftn=fftn(ftn);
        ftn=fftshift(ftn);
        [x,y,z]=size(ftn);
        %filter, correspoing eqution (3) in the paper 
        img_hpf=h(1:x,1:y,1:z).*ftn;       
        ftn=abs((img_hpf));
        img_hpf=ftn;
        fsum(ii,jj)=sum(abs((img_hpf(:))));
    end
  
  end

  
   fsum_1d=reshape(fsum,1,[]);%
   %choose max 9 boxes to sort. In the paper, we just use all 36 blocks.
   [B,I]=sort(fsum_1d,'descend');
   c=find(I<=9);
   d=fsum_1d(c);
   %frequency for the sliding window
   ftnsum(n)=sum(d(:));
  
  end
      
   %spot the apex frame according to the frequency Ipeak = max(Ai);
   [B,I] = sort(ftnsum,'descend');   
   detect((m-2),1)=I(1);
  
 end
    