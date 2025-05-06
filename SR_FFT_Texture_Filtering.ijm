// SR_FFT_Texture_Filtering Macro for FiJi (v1.54f)
// Removes the artifactual periodical texture that can appear in the super-resolution image reconstruction
// ---------------------------
// Sets to 0 the frequencies corresponding
// to the CCD size pixel in the super-resolution image
// Parameters are SR_Zoom = Image_Pixel_Size/SR_Imege_Pixel_Size
// The image needs to be a Power of 2. 
// If the image size is not a power of 2, it can be cropped or padded (not yet implemented) 
// to the closest Power of 2 value
// ---------------------------
// To install, copy the macro file SR_FFT_Texture_Filtering.ijm to the FiJi macros directory
// Then run the Plugings/FFT Filtering (shortcut keypress F)


var src_Id;
var src_Name;
var FFT_Id;
var FFT_Name;
var Img_Width;
var Img_Height;
var Img_xc;
var Img_yc;

var FFT_Peak_Position;
var FFT_Center_Position;

var Pow2_size;
var Crop_Mode;
var Roi_Radius = 2; // Size of the ROI for suppression
var Nb_Peaks = 12; // Number of peaks to remove
var X_Array = newArray(Nb_Peaks); // X_Coordinates of the Peaks
var Y_Array = newArray(Nb_Peaks); // Y_Coordinates of the Peaks

var SR_Zoom = 10.8;

macro "SR_FFT Filtering [F]"{

	src_Id = getImageID();
	src_Name = getTitle();
	Img_Width = getWidth();
	Img_Height = getHeight();
	
	Img_xc = Img_Width/2;
	Img_yc = Img_Height/2;

	// GUI
	GUI();
	//print(Crop_Mode);
	//print(SR_Zoom);
	
	setBatchMode(true);
	
	// Padding
	Pow2_size = Padding(Crop_Mode);
	//print(Pow2_size);

	run("FFT");

	FFT_Id = getImageID();
	FFT_Name = getTitle();

	FFT_Center_Position = Pow2_size/2;
	FFT_Peak_Position = Pow2_size/SR_Zoom;

	roiManager("reset");
	//roiManager("show all with labels");
	
	//makeEllipse(FFT_Center_Position-Roi_Radius, FFT_Center_Position-Roi_Radius, FFT_Center_Position+Roi_Radius, FFT_Center_Position+Roi_Radius, 1);
	// Peak Coordinates
	// +1,0
	i=0;
	j=0;
	X_Array[i++] = FFT_Center_Position + FFT_Peak_Position;
	Y_Array[j++] = FFT_Center_Position;
	// -1,0
	X_Array[i++] = FFT_Center_Position - FFT_Peak_Position;
	Y_Array[j++] = FFT_Center_Position;
	// 0,+1
	X_Array[i++] = FFT_Center_Position;
	Y_Array[j++] = FFT_Center_Position + FFT_Peak_Position;
	// 0,-1
	X_Array[i++] = FFT_Center_Position;
	Y_Array[j++] = FFT_Center_Position - FFT_Peak_Position;
	// +1,+1
	X_Array[i++] = FFT_Center_Position + FFT_Peak_Position;
	Y_Array[j++] = FFT_Center_Position + FFT_Peak_Position;
	// -1,-1
	X_Array[i++] = FFT_Center_Position - FFT_Peak_Position;
	Y_Array[j++] = FFT_Center_Position - FFT_Peak_Position;
	// +1,-1
	X_Array[i++] = FFT_Center_Position + FFT_Peak_Position;
	Y_Array[j++] = FFT_Center_Position - FFT_Peak_Position;
	// -1,+1
	X_Array[i++] = FFT_Center_Position - FFT_Peak_Position;
	Y_Array[j++] = FFT_Center_Position + FFT_Peak_Position;
	// +2,0
	X_Array[i++] = FFT_Center_Position + FFT_Peak_Position*2;
	Y_Array[j++] = FFT_Center_Position;
	// -2,0
	X_Array[i++] = FFT_Center_Position - FFT_Peak_Position*2;
	Y_Array[j++] = FFT_Center_Position;
	// 0,+2
	X_Array[i++] = FFT_Center_Position;
	Y_Array[j++] = FFT_Center_Position + FFT_Peak_Position*2;
	// 0,-2
	X_Array[i++] = FFT_Center_Position;
	Y_Array[j++] = FFT_Center_Position - FFT_Peak_Position*2;
	
// Peak Suppression
	N = Nb_Peaks;
	//N=4;
	for (i=0;i<N;i++) {
		//makeEllipse(X-Roi_Radius, Y-Roi_Radius, X+Roi_Radius, Y+Roi_Radius, 1);
		makeRectangle(X_Array[i]-Roi_Radius, Y_Array[i]-Roi_Radius, 2*Roi_Radius+1, 2*Roi_Radius+1);
		roiManager("add");
	}
	
	roiManager("show all without labels");

	setForegroundColor(0, 0, 0);
	roiManager("fill");

	run("Inverse FFT");
	close(FFT_Name);
	
	setBatchMode(false);
} // END Macro FFT Filtering

function Padding(mode){
	
	i=2;
	size=4;

	// Find the closest Power of 2 dimension below the Image Size
	while (size<=Img_Width && size<=Img_Height) {
		i++;
		size = Math.pow(2, i);
	}
	size = Math.pow(2, i-1);
	//print("i=" + i-1 + " : " + Img_Width + " => " + size);
	
	if (mode == "Crop"){
		if (Img_Width > size || Img_Height > size) {
			
			makeRectangle(Img_xc-size/2, Img_yc-size/2, size, size);
			run("Crop");
			print("Image Cropping: New Dimensions " + size + "x" + size);
		}
		else {
			print("Image dimensions already a power of 2");
		}
	}
	return size;
} // End Function Padding

function GUI(){
	
	Img_Crop_Tab = newArray("Crop", "Pad", "None");
	
	Dialog.create("FFT Options");
	Dialog.addRadioButtonGroup("Crop Mode", Img_Crop_Tab, 1, 3, "Crop");
	//Dialog.addCheckbox("ROI", 0);
	
	Dialog.addNumber("Zoom", SR_Zoom);
	Dialog.addNumber("ROI (Radius)", Roi_Radius);
	
	Dialog.show();

	//ROI = Dialog.getCheckbox();
	Crop_Mode = Dialog.getRadioButton();
	SR_Zoom = Dialog.getNumber();
	Roi_Radius = Dialog.getNumber();
	// Check Dimensions  
}

