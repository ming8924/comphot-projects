## Align and colorizing images
This project implements several methods to align the RGB channels of the Prokudin-Gorskii photo collection. 

* align_ssd: Search in a neighborhood such that the sum of squared difference (ssd) is minimized. 
* align_ncc: Search in a neighborhood such that the normalized cross correlation (ncc) is maximized. 
* align_edge ssd: Search in a neighborhood such that ssd of edges from canny edge detector is minimized.
* align_ssd_pyramid: Same as align_ssd, except using gaussian pyramid. Start searching from the low-resolution image and use the result as the initialization for the next level. The seach neighborhood is fixed to +-4 pixels in all levels. 

## Dataset: 
Each input image is a concatenation of the Blue Green and Red channel of the image. Included in the repository are the small images. More images can be found at http://graphics.cs.cmu.edu/courses/15-463/2014_fall/hw/proj1/data/images.tar
