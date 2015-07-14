function [ shift_im ] = align_edge_ssd( im_ref, im )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    im_ref = double(im_ref);
    im = double(im);
    
    im_ref_edge = edge(im_ref, 'canny');
    im_edge = edge(im, 'canny');
    s_range = 30;
    err = 1000000000;
    [h, w, c] = size(im_edge);
    im_edge_aug = zeros(h + 2 * s_range, w + 2 * s_range, c);
    im_edge_aug(s_range + 1 : end - s_range, s_range + 1: end - s_range, c) = im_edge; 

    mask = zeros(h + 2 * s_range, w + 2 * s_range, c);
    mask(s_range + 1 : end - s_range, s_range + 1: end - s_range, c) = 1;
    
    for i = 1 : 2 * s_range + 1
        for j = 1 : 2 * s_range + 1
            im_cur = im_edge_aug(i : i + h - 1, j : j + w - 1, c);
            mask_cur = mask(i : i + h - 1, j : j + w - 1, c);
            cur_err = mean(mean((im_cur.*mask_cur - im_ref_edge.*mask_cur).^2));
            if(cur_err < err)
                y = i;
                x = j;
                err = cur_err;
            end
        end
    end
    im_aug = zeros(h + 2 * s_range, w + 2 * s_range, c);
    im_aug(s_range + 1 : end - s_range, s_range + 1: end - s_range, c) = im;     
    shift_im = im_aug(y : y + h - 1, x : x + w - 1, c);
end

