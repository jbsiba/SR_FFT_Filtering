# SR_FFT_Filtering
Removes the artefactual periodical texture that can appear in the super-resolution image reconstruction
FFT_Texture_Filtering Macro for FiJi

Removes the artifactual texture by setting to 0 the frequencies corresponding to the CCD size pixel in the super-resolution image.
Parameters are :
	SR_Zoom = Image_Pixel_Size/SR_Image_Pixel_Size
	ROI_Radius = Radius (in pixel) of the ROI for pic removal

The image needs to be a Power of 2. 
If the image size is not a power of 2, it can be cropped or padded (not yet implemented) to the closest Power of 2 value.

To install, copy the macro file SR_FFT_Texture_Filtering.ijm to the FiJi macros directory
Then run the Plugings/FFT Filtering (shortcut keypress F)
