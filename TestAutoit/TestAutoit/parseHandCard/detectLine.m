function x=detectLine(eh,theta)
    [H,~,R] = hough(eh,'RhoResolution',1,'Theta',theta);
    x=R(H==max(H));
end
