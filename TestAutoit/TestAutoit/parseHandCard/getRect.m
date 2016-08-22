function [x0 y0 x1 y1]=getRect(h)
[y0 y1 x0 x1]=getRect2(h);
if nargout==1
    x0=[x0 y0 x1 y1];
end

end

function [lr, rr, lc, rc]=getRect2(h)
ma=150;
oa=10;
mb=120;
ob=10;
[lr, rr, lc, rc]=detectRect(h,[4 4],[170 4 200],[120 4 170],[ma-oa 1 ma+oa],[mb-ob 1  mb+ob]);
end

function [lr, rr, lc, rc]=getRect1(h)
nr=round(size(h,1)/2);
nc=round(size(h,2)/2);
%vertical line.
lc=detectLine(h(:,1:nc),0);
rc=nc+detectLine(h(:,nc+1:end),0);

%horizontal line.
lr=round(nr/2);
lr=lr+detectLine(h(1:lr,:),-90);
rr=size(h,1)+detectLine(h(nr+lr+1:end,:),-90);
end