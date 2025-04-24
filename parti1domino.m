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

% Les valeurs RGB pour détecter le domino
r1 = 188;
g1 = 189;
b1 = 181;

r2 = 141;
g2 = 142;
b2 = 134;

% Définir une plage de tolérance pour chaque canal RGB
tolerance = 30;

% Créer un masque binaire qui sélectionne les pixels ayant des couleurs similaires à r1, g1, b1
masque1 = (img(:,:,1) >= r1-tolerance) & (img(:,:,1) <= r1+tolerance) & ...
(img(:,:,2) >= g1-tolerance) & (img(:,:,2) <= g1+tolerance) & ...
(img(:,:,3) >= b1-tolerance) & (img(:,:,3) <= b1+tolerance);

% Créer un masque binaire qui sélectionne les pixels ayant des couleurs similaires à r2, g2, b2
masque2 = (img(:,:,1) >= r2-tolerance) & (img(:,:,1) <= r2+tolerance) & ...
(img(:,:,2) >= g2-tolerance) & (img(:,:,2) <= g2+tolerance) & ...
(img(:,:,3) >= b2-tolerance) & (img(:,:,3) <= b2+tolerance);

% Combinaison des deux masques à l'aide de l'opération logique "ou"
masque = masque1 | masque2;

% Application du masque à l'image
resultat = bsxfun(@times, img, cast(masque, 'like', img));

% Conversion de l'image résultante en niveaux de gris
gimg = rgb2gray(resultat);

% Afficher l'image résultante et l'image en niveaux de gris
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

% Définition de l'élément structurant pour l'érosion et la dilatation
sel = strel('diamond',4);

% Application de l'érosion multiple
er = imerode(gimg1, sel);
for i = 1:6
    er = imerode(er, sel);
end

% Détection du contour de l'image
[Gmag, Gdir] = imgradient(gimg1, 'Sobel');

% Suppression des contours faibles
Gmag(Gmag<35) = 0;

% Complément de l'image gradient pour éliminer les variations dues au flash
imcomp = imcomplement(Gmag);

% Binarisation de l'image complémentaire
imc = imbinarize(imcomp);

% Définition de l'élément structurant pour l'érosion
sel2 = strel('rectangle',[10 5]);

% Application de l'érosion
erc = imerode(imc, sel2);
% Afficher l'image après l'érosion et la dilatation
figure(2)
subplot(1, 4, 1);
imshow(imc);
title('Image après érosion et dilatation');
subplot(1, 4, 2);
imshow(binary_img);
title('image binaire original');
% Combinaison de l'image binaire originale et de l'image résultante de l'érosion
an = bitand(binary_img, erc);

% Afficher l'image résultante après la combinaison
subplot(1, 4, 3);
imshow(an);
title('1 AND 2');

% Définition de l'élément structurant pour l'ouverture
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
% Combinaison du résultat de l'opération logique et de l'image binaire résultante
resultat = bitand(er, binary_img1);

% Filtrage médian pour réduire le bruit
resultat = medfilt2(resultat, [10, 10]);

% Afficher le résultat final
figure(3)
imshow(resultat);
title('Résultat final');



