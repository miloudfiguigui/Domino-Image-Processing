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
impixelinfo;%pour choisir les coordonnees d'une piece moyenne.
masque=zeros(2322,4128); % un masque noir
figure()
imshow(masque);
for i=1728:1870
    for j=2057:2322
        masque(i,j)=1;
    end
end %la boucle pour selectionner la place de la piece , j'ai choisi 4/2 puisque c'est une piece moyenne (contient 6 points noir).
imshow(masque);
ress=bitand(masque,skel);%l'intersection pour selectionner la piece 4/2.
imshow(ress);
ss=0;
for i= 1:2322
    for j=1:4128
        if ress(i,j)==1;
            ss=ss+1;
        end
    end
end %la boucle pour compter le nbr de pixel blancs dans la piece moyenne 4/2
ss
rs=0;
for i= 1:2322
    for j=1:4128
        if skel(i,j)==1;
            rs=rs+1;
        end
    end
end %la boucle pour compter le nbr de pixel blancs dans toutes le pieces.
rs
ans= int32(rs/ss);%on divise: nbr px blancs dans toutes le pieces / nbr px blancs dans la piece moyenne 4/2
fprintf('le nombre de pieces de domino est :');%on obtient le nbr de pieces de domino.
ans
