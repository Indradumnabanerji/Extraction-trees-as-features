clear all; close all; clc
% Read the ortho Tiff image
% Somehow MATLAB has problems reading the tiff format,
%so had to convert the layers into dicom format which 
%is a medical imaging standard
obj = Tiff('TASK_2_OTRHO.tif','r');
i = 1;
while 1
    subimage = obj.read();
    subimages(:,:,:,i) = subimage(:,:,1:3);
    if (obj.lastDirectory())
        break;
    end
    obj.nextDirectory()
    i = i+1;
end
 
dicomwrite( subimages, 'output_image.dcm');
dicomanon('output_image.dcm', 'output_anon.dcm');
I = dicomread('output_image.dcm');
imshow (I)
% Image shown below as fig.1
hold on
J = imcrop(I);
imshow (J)
% Image shown below as fig.2. Cropping the part of the image tha
% has both kinds of trees for feature based mapping on the 
%actual image. Feature based mapping of points will be used to % % extract points of interest.
hold on
imshow(I,'DisplayRange',[])
 
I = rgb2gray(I);
J = rgb2gray(J);
% grayscale conversion before detecting the surf features
% Code below detects the strongest 1000 points for main image
 
boxPoints = detectSURFFeatures(I);
figure;
imshow(I);
title('1000 Strongest Feature Points from Box Image');
hold on;
plot(selectStrongest(boxPoints, 1000));
hold on
[boxFeatures, boxPoints] = extractFeatures(I, boxPoints);
hold on
boxPoints1 = detectSURFFeatures(J);
figure;
imshow(J);
title('100 Strongest Feature Points from Box Image');
hold on;
plot(selectStrongest(boxPoints1, 100));
hold on
[boxFeatures1, boxPoints1] = extractFeatures(I, boxPoints1);
hold on
%
points1 = detectSURFFeatures(I);
points2 = detectSURFFeatures(J);
[f1,vpts1] = extractFeatures(I,points1);
[f2,vpts2] = extractFeatures(J,points2);
indexPairs = matchFeatures(f1,f2);
matchedPoints1 = vpts1(indexPairs(:,1));
matchedPoints2 = vpts2(indexPairs(:,2));
% Mapping features from the cropped image to the actual image.
figure; showMatchedFeatures(I,J,matchedPoints1,matchedPoints2);
legend('matched points 1','matched points 2');
 
% This point onwards the extracted points and the figure is 
%exported to ArcMAP for georeferencing on the DSM image.
