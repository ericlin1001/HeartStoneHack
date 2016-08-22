function y=clipMid(h)
h=h(:,1:240,:);
gh=rgb2gray(h);
eh=edge(gh,'canny',[0.15 0.5]);
r1=getRect(eh);
y=getCrop(gh,r1);
end


