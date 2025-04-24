clear all;
clc;
% Load the image
img = imread('domino.jpg');

% Display the image
imshow(img);

% Get the RGB values of the clicked pixels
r1 = 188;
g1 = 189;
b1 = 181;

r2 = 141;  
g2 = 142;
b2 = 134;

% Define a tolerance range for each RGB channel
tolerance = 30;

% Create a binary mask that selects pixels with similar color to the first clicked pixel
mask1 = (img(:,:,1) >= r1-tolerance) & (img(:,:,1) <= r1+tolerance) & ...
        (img(:,:,2) >= g1-tolerance) & (img(:,:,2) <= g1+tolerance) & ...
        (img(:,:,3) >= b1-tolerance) & (img(:,:,3) <= b1+tolerance);

% Create a binary mask that selects pixels with similar color to the second clicked pixel
mask2 = (img(:,:,1) >= r2-tolerance) & (img(:,:,1) <= r2+tolerance) & ...
        (img(:,:,2) >= g2-tolerance) & (img(:,:,2) <= g2+tolerance) & ...
        (img(:,:,3) >= b2-tolerance) & (img(:,:,3) <= b2+tolerance);

% Combine the two masks using logical OR
mask = mask1 | mask2;

% Apply the mask to the image
result = bsxfun(@times, img, cast(mask, 'like', img));

gimg=rgb2gray(result);
imshow(result);
imtool(gimg);
binary_img1 = imbinarize(gimg);%img binaire
gimg1=rgb2gray(img);%img en gris

binary_img = imbinarize(gimg1);%img binaire
sel=strel('diamond',4);%le filtre
er=imerode(gimg1,sel);
[Gmag, Gdir] = imgradient(gimg1, 'Sobel');%detection de contour
Gmag(Gmag<35)=0; %pour binarisé l'image
imcomp=imcomplement(Gmag); %le complément de Gmag pour faire eliminé la grande variation de flash


imc=imbinarize(imcomp);%binarisation pour faire les operation logique

sel2=strel('rectangle',[10 5]);%element struct
erc=imerode(imc,sel2);
figure

an=bitand(binary_img,erc);%operation logique
imshow(an);
sel=strel('rectangle',[20 20]);%element struct
er=imopen(an,sel);
er=imdilate(er,sel);
er=imdilate(er,sel);
er=imdilate(er,sel);
er=imdilate(er,sel);
er=imdilate(er,sel);
er=imdilate(er,sel);
er=imclose(er,sel);
imshow(er);
resultat=bitand(er,binary_img1);
imshow(resultat);
resultat = medfilt2(resultat, [10, 10]);
imshow(resultat);
sel1=strel('disk',4);
skel=imdilate(resultat,sel1);
imshow(skel);
figure(2)
imshow(skel);
h = impoly;
wait(h);
pos = h.getPosition;
mask = h.createMask;
maskinv=imcomplement(mask);%l'inverse du masque
mask=bitor(maskinv,skel);%le OR logique entre l'inverse du masque et l'image d'origine nous donne les pts en noir /le reste en blanc  
maam=imcomplement(mask);%l'inverse nous donne les pts en blanc / le reste en noir
s1=strel('diamond',5);
maam2=imerode(maam,s1);%une erosion pour eliminer le trait qui divise la piece
figure(9);
imshow(maam2);
[l m]=bwlabel(maam2,8);% la fonction bwlabel pour compter le nbr de formes connexes(8-connexe) dans une image.
fprintf('le nombre de pts noirs dans cette piece  est :');%on obtient le nbr pts noirs dans cette piece.
m