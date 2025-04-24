clear all;
clc;
% Charger l'image
img = imread('domino.jpg');

% Les valeurs RGB pour d�tect� le domino
r1 = 188;
g1 = 189;
b1 = 181;

r2 = 141;   
g2 = 142;
b2 = 134;

% D�finir une plage de tol�rance pour chaque canal RGB
tolerance = 30;

% Cr�er un masque binaire qui s�lectionne les pixels ayant des couleurs similaires � r1, g1, b1
mask1 = (img(:,:,1) >= r1-tolerance) & (img(:,:,1) <= r1+tolerance) & ...
        (img(:,:,2) >= g1-tolerance) & (img(:,:,2) <= g1+tolerance) & ...
        (img(:,:,3) >= b1-tolerance) & (img(:,:,3) <= b1+tolerance);
    
% Cr�er un masque binaire qui s�lectionne les pixels ayant des couleurs
% similaires � r2, g2, b2
mask2 = (img(:,:,1) >= r2-tolerance) & (img(:,:,1) <= r2+tolerance) & ...
        (img(:,:,2) >= g2-tolerance) & (img(:,:,2) <= g2+tolerance) & ...
        (img(:,:,3) >= b2-tolerance) & (img(:,:,3) <= b2+tolerance);

% combinaison des deux masque a l'aide de l'op�ration logique ou
mask = mask1 | mask2;

% application du masque � l'image
result = bsxfun(@times, img, cast(mask, 'like', img));

% Conversion de l'image r�sultante en niveaux de gris
gimg=rgb2gray(result);

% Binarisation de l'image en niveaux de gris
binary_img1 = imbinarize(gimg);

% Conversion de l'image d'origine en niveaux de gris
gimg1=rgb2gray(img);
% Binarisation de l'image d'origine pour detecter le contour avec cette
% image
binary_img = imbinarize(gimg1);

% D�finition de l'�l�ment structurant pour l'�rosion et la dilatation
sel=strel('diamond',4);

% Application de l'�rosion
er=imerode(gimg1,sel);


% D�tection du contour de l'image
[Gmag, Gdir] = imgradient(gimg1, 'Sobel');%detection de contour

% Suppression des contours faibles
Gmag(Gmag<35)=0; %pour binaris� l'image

% Compl�ment de l'image gradient pour �liminer les variations dues au flash
imcomp=imcomplement(Gmag); %le compl�ment de Gmag pour faire elimin� la grande variation de flash

% Binarisation de l'image compl�mentaire
imc=imbinarize(imcomp);%binarisation pour faire les operation logique

% D�finition de l'�l�ment structurant pour l'�rosion
sel2=strel('rectangle',[10 5]);%element struct

% Application de l'�rosion
erc=imerode(imc,sel2);


% Combinaison de l'image binaire originale et de l'image r�sultante de l'�rosion
an=bitand(binary_img,erc);


%element struct
sel=strel('rectangle',[20 20]);

%Ouverture
er=imopen(an,sel);

%Multiple dilatation
for i = 1:6
    er = imdilate(er, sel);
end

%Fermeture
er=imclose(er,sel);

% Combinaison du r�sultat de l'op�ration logique et de l'image binaire r�sultante
resultat=bitand(er,binary_img1);

% Filtrage m�dian pour r�duire plus le bruit
resultat = medfilt2(resultat, [10, 10]);
%squelatisation
% Cr�er un �l�ment structurant pour la dilatation
se1 = strel('disk', 4);

% Dilater l'image r�sultante pour renforcer le squelette
skel = imdilate(resultat, se1);

% Eleminer le trous noir
skel = medfilt2(skel, [50, 50]);
skel = medfilt2(skel, [20, 20]);
skel = medfilt2(skel, [15, 15]);

% Effectuer une op�ration logique OR entre le squelette et l'image r�sultante
skel2 = bitor(skel, resultat);

% Effectuer plusieurs �rosions pour affiner le squelette
for i = 1:7
    skel2 = imerode(skel2, se1);
end

% Effectuer une squelettisation sur l'image binaire
skeleton = bwmorph(skel2, 'skel', inf);

% Effectuer un amincissement sur la ligne centrale squelettis�e
thinned = bwmorph(skeleton, 'thin', Inf);

% Dilater la ligne amincie pour am�liorer sa visibilit�
se2 = strel('disk', 4);
thinned = imdilate(thinned, se2);
thinned = imdilate(thinned, se2);

% Afficher l'image amincie
imshow(thinned);