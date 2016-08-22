
function featuresOriginal=getFeture1(original,type) %#codegen
         %original=myclip(f1);
         original=rgb2gray(original);
         if type==1
            ptsOriginal  = detectSURFFeatures(original);
         else
             ptsOriginal  = detectMSERFeatures(original);
         end
         [featuresOriginal,  ~]  = extractFeatures(original,  ptsOriginal);
  %  [featuresOriginal,  validPtsOriginal]  =    extractHOGFeatures( original);
end