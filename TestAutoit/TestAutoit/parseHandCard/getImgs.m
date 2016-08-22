function y=getImgs()
  files=dir('allCards\*.bmp');
    len=length(files);
    len=len-10;
    r=[54,43,138,92];
    y=zeros(len,50,85);
    for i=1:len
        f1=['allCards\' files(i).name];
        y(i,:,:)=getCrop(clipMid(imread(f1)),r);
    end
        
end