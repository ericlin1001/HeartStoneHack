function min=getMinMSE(a,b,tr,tc)
    nr=size(b,1);
    nc=size(b,2);
    min=inf;
    for i=tr
        for j=tc
            t=getMSE(a(i:i+nr-1,j:j+nc-1),b);
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