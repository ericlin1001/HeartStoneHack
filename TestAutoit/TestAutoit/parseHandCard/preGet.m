function preGet()
  files=dir('allCards\*.bmp');
    len=length(files);
    fs={};
    for i=1:len
        f1=['allCards\' files(i).name];
        fs{i}.name=files(i).name;
        fs{i}.feature1=getFeture(f1,1);
        fs{i}.feature2=getFeture(f1,2);
    end
    save('fs','fs');
end
