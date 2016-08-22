function d=mytest()
    files=dir('*.bmp');
    len=length(files);
    d=zeros(len,len);
    fs={};
    for i=1:len
        f1=files(i).name;  
         original=imread(f1);
         %original=myclip(f1);
         original=rgb2gray(original);
         ptsOriginal  = detectSURFFeatures(original);
       % ptsOriginal  = detectMSERFeatures(original);
         [featuresOriginal,  validPtsOriginal]  = extractFeatures(original,  ptsOriginal);
  %  [featuresOriginal,  validPtsOriginal]  =    extractHOGFeatures( original);
        fs{i}=featuresOriginal;
    end

    for i=1:len
        for j=1:len
            d(i,j)=length(matchFeatures( fs{i}, fs{j}));
            %disp(['*' num2str(i) ',' num2str(j) '=' num2str(d(i,j))]);
        end
    end
     for i=1:len
         di{i}=find(d(i,:)==max(d(i,:)));
     end
     di
    selfMin=min(diag(d));
    od=d;
    for i=1:len
        od(i,i)=0;
    end
    otherMax=max(od(:));
    selfMin
    otherMax
end
            
             