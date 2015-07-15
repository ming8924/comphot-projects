clear
close all; % closes all figures

% read images and convert to single format
im1 = (imread('./DerekPicture.jpg'));
im2 = (imread('./nutmeg.jpg'));
% im1 = uint8(255 * rgb2gray(im1/255)); % convert to grayscale
% im2 = uint8(255 * rgb2gray(im2/255));

% use this if you want to align the two images (e.g., by the eyes) and crop
% them to be of same size
[im2, im1] = align_images(im2, im1);

% uncomment this when debugging hybridImage so that you don't have to keep aligning
% keyboard; 

%% Choose the cutoff frequencies and compute the hybrid image (you supply
%% this code)
arbitrary_value = 100;
cutoff_low = 16;
cutoff_high = 24; 
im12 = hybridImage(im1, im2, cutoff_low/7, cutoff_high/7);

%% Crop resulting image (optional)
figure(1), hold off, imshow(im12), axis image, colormap gray
disp('input crop points');
[x, y] = ginput(2);  x = round(x); y = round(y);
im12 = im12(min(y):max(y), min(x):max(x), :);
figure(1), hold off, imshow(im12), axis image, colormap gray

%% Compute and display Gaussian and Laplacian Pyramids (you need to supply this function)
N = 5; % number of pyramid levels (you may use more or fewer, as needed)
pyramids(im12, N);
