function [ shift_im ] = align_ssd_pyramid( im_ref, im )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    % Pad image to be power of 2
    
    im_ref = double(im_ref);
    im = double(im);
    [h, w, c] = size(im);
    side = max(h, w);
    cur_side = 1;
    for i = 1 : 20
        cur_side = cur_side * 2;
        if cur_side >= side
            side = cur_side;
            break;
        end
    end
    
    pad_im = zeros(side);
    pad_im(1 : h, 1 : w) = im;
    pad_im_ref = zeros(side);
    pad_im_ref(1 : h, 1 : w) = im_ref;
    pad_mask = zeros(side);
    pad_mask(1 : h, 1 : w) = 1;
    
    % Generate image in different scales
    cur_side = side;
    i = 1;
    im_pyr{i} = pad_im;
    im_ref_pyr{i} = pad_im_ref;
    mask_pyr{i} = pad_mask;
    i = i + 1;
    cur_side = cur_side / 2;
    while cur_side >= 256
        im_pyr{i} = impyramid(im_pyr{i - 1  }, 'reduce');
        im_ref_pyr{i} = impyramid(im_ref_pyr{i - 1}, 'reduce');
        mask_pyr{i} = impyramid(mask_pyr{i - 1}, 'reduce');
        mask_pyr{i} = floor(mask_pyr{i});
        cur_side = cur_side / 2;
        i = i + 1;
    end
    % Start from the lowest pyramid and search for best match
    for k = length(im_ref_pyr) : -1 : 1
        s_range = 4;
        if size(im_ref_pyr{k}, 1) > 8000
            s_range = 0;
        end
        err = 1000000000;
        
        [h, w, c] = size(im_pyr{k});
        im_aug = zeros(h + 2 * s_range, w + 2 * s_range, c);
        im_aug(s_range + 1 : end - s_range, s_range + 1: end - s_range, c) = im_pyr{k}; 

        mask = zeros(h + 2 * s_range, w + 2 * s_range, c);
        if  h > 2048
            bound_length = size(im_aug, 1) * 0.2;
        else
            bound_length = s_range;
        end
        mask(bound_length + 1 : end - bound_length, bound_length + 1: end - bound_length, c) = 1;
%         mask(s_range + 1 : end - s_range, s_range + 1: end - s_range, c) = 1;
        mask(s_range + 1 : end - s_range, s_range + 1: end - s_range, c) = ...
            (mask(s_range + 1 : end - s_range, s_range + 1: end - s_range, c) & mask_pyr{k});
                                
        for i = 1 : 2 * s_range + 1
            for j = 1 : 2 * s_range + 1
                im_cur = im_aug(i : i + h - 1, j : j + w - 1, c);
                im_ref_cur = im_ref_pyr{k};                            
                mask_cur = mask(i : i + h - 1, j : j + w - 1, c);                
                mask_ind = (mask_cur(:) == 1);
                
                figure(1)
                aaa = zeros(h, w, 3);
                aaa(:,:,3) = im_ref_cur.*mask_cur;
                aaa(:,:,2) = im_cur;
                aaa = aaa.*repmat(mask_cur, [1 1 3]);
%                 imshow(uint8(aaa));  
                imagesc(mask_cur);
                
                im_cur_re = im_cur(:);                
                im_ref_cur_re = im_ref_cur(:);
                im_cur_re = im_cur_re(mask_ind);
                im_ref_cur_re = im_ref_cur_re(mask_ind);
                cur_err = mean((im_cur_re - im_ref_cur_re).^2);
                if(cur_err < err)
                    y(k) = i;
                    x(k) = j;
                    err = cur_err;
                    opt_cur = im_cur;
                end
            end
        end
        
        shift_x(k) = x(k) - s_range - 1;
        shift_y(k) = y(k) - s_range - 1;
        if(k ~= 1)
            [h_next, w_next, c_next] = size(im_ref_pyr{k-1});
            next_shift_x = 0;
            next_shift_y = 0;
            for i = length(im_pyr):-1:k
                next_shift_x = 2 * next_shift_x + 2 * shift_x(i);
                next_shift_y = 2 * next_shift_y + 2 * shift_y(i);   
            end
            
%                 figure(3)
%                 aaa = zeros(h, w, 3);
%                 aaa(:,:,3) = im_ref_cur.*mask_cur;
%                 aaa(:,:,2) = opt_cur.*mask_cur;
%                 imshow(uint8(aaa));   
%                 title('Optimal result in this round')
                
            tmp_im = zeros(h_next + 2 * abs(next_shift_y), w_next + 2 * abs(next_shift_x));
            tmp_im(1 + abs(next_shift_y): h_next + abs(next_shift_y), ...
                1 + abs(next_shift_x): w_next + abs(next_shift_x)) = im_pyr{k-1};
            tmp_mask = zeros(h_next + 2 * abs(next_shift_y), w_next + 2 * abs(next_shift_x));
            tmp_mask(1 + abs(next_shift_y): h_next + abs(next_shift_y), ...
                1 + abs(next_shift_x): w_next + abs(next_shift_x)) = mask_pyr{k-1};
            im_pyr{k-1} = tmp_im(next_shift_y + 1 + abs(next_shift_y): next_shift_y + h_next + abs(next_shift_y), ...
                next_shift_x + 1 + abs(next_shift_x): next_shift_x + w_next + abs(next_shift_x));
            mask_pyr{k-1} = tmp_mask(next_shift_y + 1 + abs(next_shift_y): next_shift_y + h_next + abs(next_shift_y), ...
                next_shift_x + 1 + abs(next_shift_x): next_shift_x + w_next + abs(next_shift_x));
                
%                 figure(4)
%                 aaa = zeros(h*2, w*2, 3);
%                 aaa(:,:,3) = im_ref_pyr{k-1}.*mask_pyr{k-1};
%                 aaa(:,:,2) = im_pyr{k-1}.*mask_pyr{k-1};
%                 imshow(uint8(aaa));   
%                 title('Optimal result in next round')
        end       
    end
    shift_im = im_aug(y(1) : y(1) + h - 1, x(1) : x(1) + w - 1, c);
    shift_im = shift_im(1 : size(im, 1), 1 : size(im, 2));
end

% BUG fixed
% 1. next_shift_x didn't account for shift from previous 