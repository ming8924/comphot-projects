clear
close all
d1 = dir('images/*.tif');
d2 = dir('images/*.jpg');
d = [d1; d2]; 
for i = 1:length(d)
    tic
    im = im2uint8(imread(d(i).name));
    [h, w, c] = size(im);
    
    %% remove white borders
    row_sum = sum(im, 2);
    row_sum_perc = row_sum/w/double(intmax(class(im)));
    delete_ind = [];
    for j = h:-1:1
        if(row_sum_perc(j)>0.95)
            delete_ind = [delete_ind, j];
        else 
            break;
        end
    end
    for j = 1:h
        if(row_sum_perc(j)>0.95)
            delete_ind = [delete_ind, j];
        else 
            break;
        end
    end
    row_sum_perc(delete_ind) = [];
    im(delete_ind, :) = [];
 
    col_sum = sum(im, 1);
    col_sum_perc = col_sum/w/double(intmax(class(im)));
    delete_ind = [];
    for j = w:-1:1
        if(col_sum_perc(j)>0.95)
            delete_ind = [delete_ind, j];
        else 
            break;
        end
    end
    for j = 1:w
        if(col_sum_perc(j)>0.95)
            delete_ind = [delete_ind, j];
        else 
            break;
        end
    end
    col_sum_perc(delete_ind) = [];
    im(:, delete_ind) = [];    
    
    [h, w, c] = size(im);
    h_new = floor(h/3);
    im_b = im(1:h_new, :);
    im_g = im(h_new+1:2*h_new, :);
    im_r = im(2*h_new+1: 3*h_new, :);

    
    %% remove 10% of the whole image in each direction
    im_b = im_b(floor(0.05*h_new):h_new - floor(0.05*h_new), floor(0.05*w):w - floor(0.05*w));
    im_g = im_g(floor(0.05*h_new):h_new - floor(0.05*h_new), floor(0.05*w):w - floor(0.05*w));
    im_r = im_r(floor(0.05*h_new):h_new - floor(0.05*h_new), floor(0.05*w):w - floor(0.05*w));   
    
    [h_new, w, c] = size(im_b);
        
    out = cast(zeros(h_new, w, 3), class(im));
    out(:, :, 1) = im_r;
    out(:, :, 2) = im_g;
    out(:, :, 3) = im_b; 
    
    %% align red and green channel with blue channel respectively
    out_aligned = out;
    out_aligned(:, :, 1) = align_ssd_pyramid(im_b, im_r);
    out_aligned(:, :, 2) = align_ssd_pyramid(im_b, im_g);
    
    out = im2uint8(out);
    out_aligned = im2uint8(out_aligned);
    figure
    subplot(121)    
    imshow(out)
    subplot(122)
    imshow(out_aligned)    
    toc
end