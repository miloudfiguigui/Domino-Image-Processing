clear all ;
clc;
im = imread('img.jpg');
im = rgb2gray(im);
im_fft = fftshift(fft2(im));
copy=im_fft;
[l, c] = size(im_fft);
t = ones(l, c);
c1=l/2;
c2=c/2;
mask1 = false(l, c);
mask1(c1-2:c1+2,c2-2:c2+2) = true;
se = strel('rectangle', [8 8]);

while true
    %faire une dilatation du masque jusqu'a le terminer 
    mask1 = imdilate(mask1, se); 
    res = t - mask1;
    if isequal(res(:), zeros(numel(res), 1))
        break;
    end
copy=im_fft;
%slectionner une bande de frequences par le masque 
copy=copy.*mask1;
im_reconstructed = ifft2(ifftshift(copy));
%onstructe; Afficher l'image reconstruite
subplot(1,2,1);
imshow(copy);
subplot(1,2,2);
imshow(uint8(im_reconstructed),[]);
pause(1);
end


