function inputData()
%check for root consistent.
%loop over  hc[0-0]*.bmp.
%if the img is in the root, show it and ask for corectness.
%else ask user to input the data of the img, and save to the root.
    files=dir('*.bmp');
    root=[];
    s1=struct();
    for i=1:length(files)
        file=files(i).name;         
        h=myclip(file);
        %imshow(h);   
       % s1.name=input('name:','s');
        s1.name=file(1:end-4);
        s1.img=getCrop(h,[54,43,138,92]);
       root=[root s1];
    end
    save('root','root');
end

function y=isFileExist(f)
    i=fopen(f,'r');
    if i==-1 
        y=0
    else
        fclose(i);
        y=1
    end
end
