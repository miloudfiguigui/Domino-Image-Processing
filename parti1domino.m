clear all;
clc;

% Charger l'image
img = imread('domino.jpg');

% Figure 1
figure(1);

% Subplot 1
subplot(1, 3, 1);
imshow(img);
title('Image originale');

% Les valeurs RGB pour d�tecter le domino
r1 = 188;
g1 = 189;
b1 = 181;

r2 = 141;
g2 = 142;
b2 = 134;

% D�finir une plage de tol�rance pour chaque canal RGB
tolerance = 30;

% Cr�er un masque binaire qui s�lectionne les pixels ayant des couleurs similaires � r1, g1, b1
masque1 = (img(:,:,1) >= r1-tolerance) & (img(:,:,1) <= r1+tolerance) & ...
(img(:,:,2) >= g1-tolerance) & (img(:,:,2) <= g1+tolerance) & ...
(img(:,:,3) >= b1-tolerance) & (img(:,:,3) <= b1+tolerance);

% Cr�er un masque binaire qui s�lectionne les pixels ayant des couleurs similaires � r2, g2, b2
masque2 = (img(:,:,1) >= r2-tolerance) & (img(:,:,1) <= r2+tolerance) & ...
(img(:,:,2) >= g2-tolerance) & (img(:,:,2) <= g2+tolerance) & ...
(img(:,:,3) >= b2-tolerance) & (img(:,:,3) <= b2+tolerance);

% Combinaison des deux masques � l'aide de l'op�ration logique "ou"
masque = masque1 | masque2;

% Application du masque � l'image
resultat = bsxfun(@times, img, cast(masque, 'like', img));

% Conversion de l'image r�sultante en niveaux de gris
gimg = rgb2gray(resultat);

% Afficher l'image r�sultante et l'image en niveaux de gris
subplot(1, 3, 2);
imshow(resultat);
title('Image avec masque');
subplot(1, 3, 3);
imshow(gimg);
title('Image en niveaux de gris');

% Binarisation de l'image en niveaux de gris
binary_img1 = imbinarize(gimg);

% Conversion de l'image d'origine en niveaux de gris
gimg1 = rgb2gray(img);

% Binarisation de l'image d'origine
binary_img = imbinarize(gimg1);

% D�finition de l'�l�ment structurant pour l'�rosion et la dilatation
sel = strel('diamond',4);

% Application de l'�rosion multiple
er = imerode(gimg1, sel);
for i = 1:6
    er = imerode(er, sel);
end

% D�tection du contour de l'image
[Gmag, Gdir] = imgradient(gimg1, 'Sobel');

% Suppression des contours faibles
Gmag(Gmag<35) = 0;

% Compl�ment de l'image gradient pour �liminer les variations dues au flash
imcomp = imcomplement(Gmag);

% Binarisation de l'image compl�mentaire
imc = imbinarize(imcomp);

% D�finition de l'�l�ment structurant pour l'�rosion
sel2 = strel('rectangle',[10 5]);

% Application de l'�rosion
erc = imerode(imc, sel2);
% Afficher l'image apr�s l'�rosion et la dilatation
figure(2)
subplot(1, 4, 1);
imshow(imc);
title('Image apr�s �rosion et dilatation');
subplot(1, 4, 2);
imshow(binary_img);
title('image binaire original');
% Combinaison de l'image binaire originale et de l'image r�sultante de l'�rosion
an = bitand(binary_img, erc);

% Afficher l'image r�sultante apr�s la combinaison
subplot(1, 4, 3);
imshow(an);
title('1 AND 2');

% D�finition de l'�l�ment structurant pour l'ouverture
sel = strel('rectangle',[20 20]);

% Application de la dilatation multiple
er = imopen(an, sel);
for i = 1:6
    er = imdilate(er, sel);
end

% Application de la fermeture
er = imclose(er, sel);
subplot(1, 4, 4);
imshow(er);
title('plus plusieure dilatation');
% Combinaison du r�sultat de l'op�ration logique et de l'image binaire r�sultante
resultat = bitand(er, binary_img1);

% Filtrage m�dian pour r�duire le bruit
resultat = medfilt2(resultat, [10, 10]);

% Afficher le r�sultat final
figure(3)
imshow(resultat);
title('R�sultat final');



