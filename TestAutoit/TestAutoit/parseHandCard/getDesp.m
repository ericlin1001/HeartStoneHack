function y=getDesp(file)
    load('root','root');
    %h=myclip(file);
    h=imread(file);
    h=rgb2gray(h);
    mse=zeros(1,length(root));
    %[54,43,138,92];
    for i=1:length(root);
        s=root(i);
        mse(i)=getMinMSE(h,s.img,40:103,40:102,100);
    end
    mse
    %mse over 900 means unmatched.
    if min(mse)>20^2
        y='unknow';
        return;
    end
    y=root(mse==min(mse));
    if length(y)>1
        y=y(1);
    end
    y=y.name;
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
                min=thre;
            end
            if(t<min)
                min=t;
            end
        end
    end
end

function y=getMSE(a,b)
    e=(a-b).^2;
    y=sum(e(:))/length(e);
end