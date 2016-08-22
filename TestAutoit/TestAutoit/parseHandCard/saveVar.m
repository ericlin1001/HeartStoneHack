function i=saveVar(value)
root=getRoot();
root=[root value];
i=length(root);
save('root','root');
end
