%% sharpen an image 
%% alpha control how much sharpening is performed

im = double(imread('nutmeg.jpg'));
h = 7;
sigma = 1;
mid = (h + 1)/2;

filt = fspecial('gaussian', h, sigma);
delta_filt = zeros(h);
delta_filt(mid, mid) = 1;
alpha = 30;
beta = alpha - 1;


unsharp_mask = alpha * delta_filt - beta * filt;

sharp_im = imfilter(im, unsharp_mask, 'same', 'conv');

imshow(uint8(sharp_im));

