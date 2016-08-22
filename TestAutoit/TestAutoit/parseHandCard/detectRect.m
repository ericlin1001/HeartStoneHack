function [lr, rr, lc, rc]=detectRect(h,ph,pr,pc,pa,pb)

hrs=ph(1);
hcs=ph(2);
r0=pr(1);
rs=pr(2);
r1=pr(3);
c0=pc(1);
cs=pc(2);
c1=pc(3);
a0=pa(1);
as=pa(2);
a1=pa(3);
b0=pb(1);
bs=pb(2);
b1=pb(3);

%r=r0+(ir-1)*rs
%ir=round((r-r0)/rs)+1
nr=ceil((r1-r0+1)/rs);
nc=ceil((c1-c0+1)/cs);
na=ceil((a1-a0+1)/as);
nb=ceil((b1-b0+1)/bs);
a1=a0+(na-1)*as;
b1=b0+(nb-1)*bs;
hs=zeros(nr,nc,na,nb);%hough space accumulator.

nhr=floor(size(h,1)/hrs);
nhc=floor(size(h,2)/hcs);


ih=zeros(nhr,nhc);
ss=round(hrs*hcs/4);
for i=1:nhr
    for j=1:nhc
        r=1+(i-1)*hrs;
        c=1+(j-1)*hcs;
        th=h(r:(r+hrs-1),c:(c+hcs-1));
        if sum(th(:))>=ss
            ih(i,j)=1;
        else 
            ih(i,j)=0;
        end
    end
end
for i=1:nhr
    hr=1+(i-1)*hrs;
    for j=1:nhc   
        if ih(i,j)>0             
            hc=1+(j-1)*hcs;
           for ir=1:nr
                r=r0+(ir-1)*rs;
               for ic=1:nc  
                   c=c0+(ic-1)*cs;
                   %
                   a=abs(r-hr);
                   b=abs(c-hc);
                   if a0<=a && a<=a1 && b0<=b && b<=b1 
                        ia=round((a-a0)/as)+1;                     
                        ib=round((b-b0)/bs)+1;
                        hs(ir,ic,ia:na,ib)=hs(ir,ic,ia:na,ib)+1;
                        hs(ir,ic,ia,ib:nb)=hs(ir,ic,ia,ib:nb)+1;
                   end
               end
           end
        end
    end
end
m=max(hs(:));
maxI=find(hs==m);
[ir ,ic, ia, ib]=ind2sub(size(hs),maxI(1));
r=r0+(ir-1)*rs;
c=c0+(ic-1)*cs;
a=a0+(ia-1)*as;
b=b0+(ib-1)*bs;
lr=r-a;
rr=r+a;
lc=c-b;
rc=c+b;
if lr<1 
    lr=1;
end
if  lc<1
    lc=1;
end
if rr>size(h,1)
    rr=size(h,1);
end
if rc>size(h,2)
    rc=size(h,2);
end

end


