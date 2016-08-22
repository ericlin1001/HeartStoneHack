function  gxh=pp( h,pr,pc,pa,pb,maxStep)
h=h(:,1:260,:);
gh=rgb2gray(h);
eh=edge(gh,'canny');
%figure;
%subplot(1,2,1)
%imshow(eh);
%******constrain the arguments.*******
pa=setInRange(pa,size(h,1));
pb=setInRange(pb,size(h,2));
pr=setInRange(pr,size(h,1));
pc=setInRange(pc,size(h,2));
pa=setStep(pa,maxStep);
pb=setStep(pb,maxStep);
pr=setStep(pr,maxStep);
pc=setStep(pc,maxStep);
assert(1<=pr(1));
assert(size(h,1)>=pr(3))
assert(1<=pc(1))
assert(size(h,2)>=pc(3))
%************end constrain arguments.***********
[r c a b]=detectRect(eh,pr,pc,pa,pb);
a=a+pa(2);
b=b+pb(2);
rr=rect(size(h),r,c,a,b);
size(rr)
rrr=repmat(rr,[1 1 3]);
size(h)
size(rrr)
%h(rrr==1)=0;
lr=r-a;
rr=r+a;
lc=c-b;
rc=c+b;
gxh=gh(lr:rr,lc:rc);
return;
rho1=detectLine(eh);
from=round(size(h,2)/2)
rho2=from+detectLine(eh(:,from:end,:));
imshow(eh(:,from:end,:));
oh=h;
rho1
rho2
oh(:,rho1,:)=0;
oh(:,rho2,:)=0;
imshow(oh);
end
function c=setInRange(a,b)
         if(length(a)<=2)
        a(3)=a(2);
        a(2)=1;
        end
      if a(1)<1
          a(1)=1;
      end
      if a(3)>b
          a(3)=b;
      end
      c=a;
    end
    function b=setStep(a,maxStep)       
        da=a(3)-a(1);
        if da/a(2)>=maxStep 
            a(2)=round(da/maxStep);
        end       
        a
        assert(a(3)>=a(1));
        assert(a(1)>=0);
         b=a;
    end
