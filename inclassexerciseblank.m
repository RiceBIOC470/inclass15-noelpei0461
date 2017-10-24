%% step 1: write a few lines of code or use FIJI to separately save the
% nuclear channel of the image Colony1.tif for segmentation in Ilastik

%% step 2: train a classifier on the nuclei
% try to get the get nuclei completely but separe them where you can
% save as both simple segmentation and probabilities

%% step 3: use h5read to read your Ilastik simple segmentation
% and display the binary masks produced by Ilastik 

% (datasetname = '/exported_data')
% Ilastik has the image transposed relative to matlab
% values are integers corresponding to segmentation classes you defined,
% figure out which value corresponds to nuclei
segfilename=fullfile('Users','jingqipei','Downloads','inclass15-noelpei0461-master','48hColony1_DAPI_Simple Segmentation.h5');
seg=h5read(segfilename,'/exported_data');
seg=squeeze(seg);
imshow(seg,[]);
%(datasetname='/exported_data')

% Ilastik has the image transposed relative to matlab
% values are integers corresponding to segmentation classes you defined,
% figure out which value corresponds to nuclei
%% step 3.1: show segmentation as overlay on raw data
figure;
img = imread('48hColony1_DAPI.tif');
imshow(img, []);
hold on;
imshow(seg, []);
hold off;
%% step 4: visualize the connected components using label2rgb
% probably a lot of nuclei will be connected into large objects
img2 = label2rgb(img);

imshow(img2);
%% step 5: use h5read to read your Ilastik probabilities and visualize

% it will have a channel for each segmentation class you defined
seg2=h5read('Prediction.h5','/exported_data/');
seg2=squeeze(seg2);
imshow(seg2);
%% step 6: threshold probabilities to separate nuclei better
seg2th=seg2>0.99;

imshow(seg2th);
%% step 7: watershed to fill in the original segmentation (~hysteresis threshold)
BG=bwconncomp(seg2th);
reader=regionprops(BG,'Area');
area= [reader.Area];

s = round(1.2*sqrt(mean(area))/pi);
mask = imerode(seg2th,strel('disk',s));
outside = imdilate(seg2th,strel('disk',1));
basin = imcomplement(bwdist(outside));
basin = imimposemin(basin,mask|outside);
imgf = watershed(basin);
imshow(imgf, []);

%% step 8: perform hysteresis thresholding in Ilastik and compare the results
% explain the differences

%The hysteresis method in Ilastik is better than watershed method. The cell blobs are more seperated in the Ilastik image, but the Ilastik image seems to have  more noise in the outer parts.

%% step 9: clean up the results more if you have time 
% using bwmorph, imopen, imclose etc
imgf = imopen(imgf,strel('disk',5));
imgf = imclose(imgf,strel('disk',3));
imshow(imgf, [])
