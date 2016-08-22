function rr=rect(s,r,c,a,b)
    rr=zeros(s(1),s(2));
    if length(a)*length(b)==1 
    rr(r-a,c-b:c+b)=1;
    rr(r+a,c-b:c+b)=1;
    rr(r-a+1:r+a-1,c-b)=1;
    rr(r-a+1:r+a-1,c+b)=1;
    else
        for j=b
            rr(r-a,c-j:c+j)=rr(r-a,c-j:c+j)+1;
            rr(r+a,c-j:c+j)=rr(r+a,c-j:c+j)+1;
        end
         for i=a
            rr(r-i+1:r+i-1,c-b)=rr(r-i+1:r+i-1,c-b)+1;
            rr(r-i+1:r+i-1,c+b)=rr(r-i+1:r+i-1,c+b)+1;
        end
    end
end