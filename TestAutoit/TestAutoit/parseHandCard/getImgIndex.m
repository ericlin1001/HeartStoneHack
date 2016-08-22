function y=getImgIndex(h,numImgs,imgs)
    h=clipMid(h);%centerial.
    mse=zeros(1,numImgs);
    %[54,43,138,92];
    off=10;
    r=[54,43,138,92];
    tr=[54-off,43-off,138+off,92+off];
    h=getCrop(h,tr);
    for i=1:numImgs
        mse(i)=getMinMSE(h,imgs(i),1:2*off,1:2*off,10);
    end
    mse
    %mse over 900 means unmatched.
    if min(mse)>20
        y=0;
        return;
    end
    y=find(mse==min(mse));
    if length(y)>1
        y=y(1);
    end
end

function min=getMinMSE(a,b,tr,tc,thre)
    nr=size(b,1);
    nc=size(b,2);
    min=inf;
    for i=tr
        for j=tc
            t=getMSE(a(i:i+nr-1,j:j+nc-1),b);
            if t==0
            disp(['****' num2str(i) ',' num2str(j) '***']);
            end
            if t<thre
                min=t;
                return;
            end
            if(t<min)
                min=t;
            end
        end
    end
end

function y=getMSE(a,b)
assert(size(a,1)==size(b,1));
assert(size(a,2 )==size(b,2));
size(a)
size(b)
    e=abs((a-b));
    y=sum(e(:))/length(e);
end