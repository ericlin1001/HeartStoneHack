function y=myclip(file)
h=imread(file);
h=h(:,1:240,:);
gh=rgb2gray(h);
eh=edge(gh,'canny',[0.15 0.5]);
r1=getRect(eh);
y=getCrop(gh,r1);
return;
r2=[54,43,138,92];
figure;
subplot(1,2,1);
subplot(1,2,2);
cch=getCrop(ch,r2);
y=cch;
end


