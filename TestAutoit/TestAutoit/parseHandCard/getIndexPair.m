function indexPairs=getIndexPair(f1,f2)
original=imread(f1);
distorted=imread(f2);
ptsOriginal  = detectSURFFeatures(original);
ptsDistorted = detectSURFFeatures(distorted);
[featuresOriginal,  validPtsOriginal]  = extractFeatures(original,  ptsOriginal);
[featuresDistorted, validPtsDistorted] = extractFeatures(distorted, ptsDistorted);
indexPairs = matchFeatures(featuresOriginal, featuresDistorted);

end
