function [ im12 ] = hybridImage( im1, im2, cutoff_low, cutoff_high )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    [h, w, c] = size(im1);
    
    % cut_off frequency is used such that gain is 0.5 (max gain is 1)
    sigma_low = cutoff_low / sqrt(log(4)/log(exp(1)));
    sigma_high = cutoff_high / sqrt(log(4)/log(exp(1)));
    sigma_low = 10;
    sigma_high = 10;
    
    h = 21;
    mid = (h + 1)/2;
    
    % define low pass filter
    h_low = fspecial('gaussian', h, sigma_low);
    
    % define high pass filter
    h_high = fspecial('gaussian', h, sigma_high);
    delta_filt = zeros(h, h);
    delta_filt(mid, mid) = 1;
    h_high =  delta_filt -  h_high;
    if c == 1
        im1_ycbcr = double(rgb2ycbcr(uint8(im1)));
        im2_ycbcr = double(rgb2ycbcr(uint8(im2)));
        im1_filt = im1_ycbcr;
        im2_filt = im2_ycbcr;
        % filter the images
        im1_filt(:, : ,1) = imfilter(im1_ycbcr(:, :, 1), h_low, 'same', 'conv');
        im2_filt(:, : ,1) = imfilter(im2_ycbcr(:, : ,1), h_high, 'same', 'conv');

        % blend the two images
        im12 = 0.5 * im1_filt + 0.5 * im2_filt;
        im12 = ycbcr2rgb(uint8(im12));
        imshow(uint8(im12))
    else 
        im1 = double(im1);
        im2 = double(im2);
        im1_filt = imfilter(im1, h_low, 'same', 'conv');
        im2_filt = im2 - imfilter(im2, h_low, 'same', 'conv');
        
%         imagesc(log(abs(fftshift(fft2(im1_filt)))))
%         imagesc(log(abs(fftshift(fft2(im2_filt)))))
        imshow(uint8(im1_filt));
        
        % blend the two images
        im12 = 0.5 * im1_filt + 0.5 * im2_filt;
        imshow(uint8(im12))
    end

end

