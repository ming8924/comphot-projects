function [ shift_im ] = align_ssd( im_ref, im )
%align_ssd Align two images using sum of squared difference
%   Detailed explanation goes here
    im_ref = double(im_ref);
    im = double(im);
    range = 10;
    err = 1000000;
    [h, w, c] = size(im);
    im_aug = zeros(h + 2 * range, w + 2 * range, c);
    im_aug(range + 1 : end - range, range + 1: end - range, c) = im; 

    mask = zeros(h + 2 * range, w + 2 * range, c);
    mask(range + 1 : end - range, range + 1: end - range, c) = 1;
    for i = 1 : 2 * range + 1
        for j = 1 : 2 * range + 1
            im_cur = im_aug(i : i + h - 1, j : j + w - 1, c);
            im_mask = mask(i : i + h - 1, j : j + w - 1, c);
            
            im_cur_reshape = im_cur(:);
            im_ref_reshape = im_ref(:);
            im_mask_reshape = im_mask(:);
            ind = (im_mask_reshape == 1);
            
            im_cur_mask = im_cur_reshape(ind);
            im_ref_mask = im_ref_reshape(ind);
            mean_cur = mean(im_cur_mask);
            mean_ref = mean(im_ref_mask);
            
            cur_err = mean((im_cur_mask - im_ref_mask).^2);
            if(cur_err < err)
                y = i;
                x = j;
                err = cur_err;
            end
        end
    end
    shift_im = im_aug(y : y + h - 1, x : x + w - 1, c);
end


