clc
clear

%load the original mat
imagepath = ['C:\yanteli\matlab\my spoting preprocess\casme2_mat\'];

k=1;  imk=1; 
  
folder = dir(imagepath);
%store detected apex index
detect=zeros(length(folder)-2,1);
namename=cell(length(folder)-2,1);
 for m=3:length(folder)  
    fname = folder(m).name;
    load(['casme2_mat/',fname]);
    [NR NC NZ] = size(p);  
    NR=NR-2;
    NC=NC-2; 
    features=zeros(NR,NC,NZ); 
    %extract lbp features for 
     for kk=1:NZ
        features(:,:,kk)= lbp(p(:,:,kk));
     end
     
     window=61;
     feature1=repmat(features(:,:,1),[1,1,ceil((window-1)/2)]);
     feature2=repmat(features(:,:,NZ),[1,1,ceil((window-1)/2)]);
     features=cat(3,feature1,features,feature2);
     
  
  %6 by 6 windows
  for n=1:NZ-1
     ftnw=features(:,:,[n:(n+window-1)]);  
     w1=fix((NR-1)/6); 
     w2=fix((NC-1)/6);  
     q=window;
     m_mid=fix(w1/2);  %
     n_mid=fix(w2/2);   
     q_mid=fix((q+1)/2);  
       
     %threshold
     d0=((window+1)/2); 
     %define filter          
     img_hpf=zeros(w1,w2,q);  
       for i=1:w1  
           for j=1:w2  
               for k=1:q    
                   d=sqrt((i-m_mid)^2+(j-n_mid)^2+(k-q_mid)^2);   % 
                   if d>=d0                        
                        h(i,j,k)=1;  
                    else  
                         h(i,j,k)=0;  
                     end   
                   end  
               end  
       end             
            


  ii=0;
  fx=cell(6,6);
  for i=1:w1:(NR-w1)
    ii=ii+1;
    jj=0;
    
    for j=1:w2:(NC-w2)
        jj=jj+1;
        %fft
        ftn=ftnw(i:(i+w1-1),j:(j+w2-1),:);
        ftn=fftn(ftn);
        ftn=fftshift(ftn);

        [x,y,z]=size(ftn);
        %filter
        img_hpf=h(1:x,1:y,1:z).*ftn;    
      
        ftn=abs((img_hpf));
        img_hpf=ftn;
        ftnnsum(ii,jj)=sum(abs((img_hpf(:))));
    end
  
  end


   % [B,I]= sort(ftnnsum,'descend');
   %  ftnsum(n)=sum(ftnnsum(:));
   
   ftnnsum1=reshape(ftnnsum,1,[]);%
   %choose max 9 boxes to sort
   [B,I]=sort(ftnnsum1,'descend');%
   c=find(I<=9);%
   d=ftnnsum1(c);%
   ftnsum(n)=sum(d(:));
  
  end
      

    [B,I] = sort(ftnsum,'descend');   
     detect((m-2),1)=I(1);
  
 end
    