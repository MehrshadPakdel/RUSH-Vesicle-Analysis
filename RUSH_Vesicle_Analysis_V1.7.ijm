/*
-------------------------------------------------------------------------------------------------------
					RUSH Vesicle Analysis V1.7
					
	* Optimized for RUSH reporter assays to quantify number of cytoplasmic vesicles after Biotin addition
	used in Deng et al., 2018
	* Works for confocal z-stack aquisitions with e.g. 0.35 µm step sizes to cover the whole cellular volume
	* Works also for single stack images
	* If image has z-stacks, macro generates maximum intensity z-projection	
	* Cell selections will be analyzed by particle analyzer  
	* Vesicle numbers of selections will be printed in the log file	
	* All images will be saved in a results folder the image directory

Updates:
		* V1.0
		* Introduced manual threshold to better adjust the binary image for low intensity pictures 
		* Caution for biased threshold adjustments - binary images must be compared with original images to 		
		ensure valid threshold levels
		* 
		* V1.5		
		* Macro can now also optionally analyze single stack images
		* Improved documentation
		* Bug fixes
		* 
		* V1.7
		* Improved documentation
		
Mehrshad Pakdel

pakdel@biochem.mpg.de 
mehrshad.pakdel@posteo.de
https://github.com/MehrshadPakdel

October 15, 2019
--------------------------------------------------------------------------------------------------------
*/

//This macro can only process one opened image at a time.
//Exits the macro if more than one image is opened. 

list = getList("image.titles");										
	if (list.length>=2) {
 		waitForUser("Only one image can be processed at a time. Please close all other images.");
	}
list = getList("image.titles");
	if (list.length>=2) {
 		exit("Error: Please open just one image at a time and rerun the macro.");
	}

getDimensions(width, height, channels, slices, frames);
noCh = channels;
noFrames = frames;
noSlices = slices;

	if (noCh>=4) {
		exit("Error: This macro cannot process more than three channels");
	}

	if (noFrames>=2) {
		exit("Error: This macro cannot process time-lapse images");
	}

	
//Defining variables and image directory for analysis.

originalImage = getTitle();
ScrW = screenWidth;
ScrH = screenHeight;
ScrHWindow = ScrW/20;
ScrWWindow = ScrH/6;
selectWindow(originalImage);
setLocation(ScrHWindow, ScrWWindow);
dir = getDirectory("image");
fileNameWithoutExtension = File.nameWithoutExtension;
splitDir = dir + "/Results_" + fileNameWithoutExtension + "/";
File.makeDirectory(splitDir);
selectWindow(originalImage);
saveAs("tiff", splitDir + "Orig_" + fileNameWithoutExtension);

run("Duplicate...", "title=[Bin_Image] duplicate");
selectWindow("Bin_Image");
BinImg = getTitle();
getDimensions(width, height, channels, slices, frames); //reads out no of channels
noCh = channels; //defines no of channels as noCh
DialCh = newArray("RUSH reporter", "Other"); //assign channels fluorophore 
//array to choose number of cells to analyze; d2s removes decimals from values
Dial_NoCells = newArray(d2s(1, 0), d2s(2, 0), d2s(3, 0), d2s(4, 0), d2s(5, 0), d2s(6, 0), d2s(7, 0), d2s(8, 0)); 

ScrHLog = ScrW/1.60;
ScrWLog = ScrH/3;
ScrHROI = ScrW/2.00;
ScrWROI = ScrH/3;	
getLocationAndSize(x1, y1, width, height);	

//closes Log window if opened

if (isOpen("Log")) { 
         selectWindow("Log"); 
         run("Close"); 
} 

//closes red channel and uses green channel only for analysis if hyperstack contains more than one channel
//call to function


	
	if (noCh>=2) {
		Dialog.create("Assign channels");
			setSlice(1);
			Dialog.addChoice("Choose channel for Ch1", DialCh, DialCh[0]);
		Dialog.show();
			flCh1 = Dialog.getChoice();
		Dialog.create("Assign channels");
			setSlice(2);
			Dialog.addChoice("Choose channel for Ch2", DialCh, DialCh[0]);
		Dialog.show();
			flCh2 = Dialog.getChoice();
		if (noCh>=3) {
			Dialog.create("Assign channels");
			setSlice(3);
			Dialog.addChoice("Choose channel for Ch3", DialCh, DialCh[0]);
		Dialog.show();
			flCh3 = Dialog.getChoice();
			}
	
	run("Split Channels");
	list = getList("image.titles");
	selectWindow(list[0]);
	selectWindow("C1-" + BinImg);
	rename("Ch1");
	selectWindow("C2-" + BinImg);
	rename("Ch2");
	if (noCh>=3) {
		selectWindow("C3-" + BinImg);
		rename("Ch3");
	}
	
	if (flCh1==DialCh[0]) {
		selectWindow("Ch1");
		rename(BinImg);
		selectWindow("Ch2");
		run("Close");	
		if (noCh>=3) {
			selectWindow("Ch3");
			run("Close");
		}
	}	
	if (flCh2==DialCh[0]) {
		selectWindow("Ch2");
		rename(BinImg);
		selectWindow("Ch1");
		run("Close");
		if (noCh>=3) {
			selectWindow("Ch3");
			run("Close");		
		}
	}
	if (noCh>=3) {
	if (flCh3==DialCh[0]) {
		selectWindow("Ch3");
		rename(BinImg);
		selectWindow("Ch1");
		run("Close");	
		selectWindow("Ch2");
		run("Close");
		}
	}
}

/*
 * standard image processing:
 * subtract background
 * moderately enhances contrast
 * Optional: maximum intensity z-projection to combine all z-stacks into one 2D image 
 * dupicating MAX_Image for further analysis
 * generating 8-bit image for thresholding
*/

run("Subtract Background...", "rolling=60 stack");
run("Enhance Contrast...", "saturated=0 process_all");
if (noSlices>=2) {
	run("Z Project...", "projection=[Max Intensity]");
	}

run("Duplicate...", "title=MAX_Image");
if (noSlices<=1) {
run("Duplicate...", "title=MAX_Bin_Image");
	}
		
close(BinImg);
selectWindow("MAX_Bin_Image");
run("Options...", "iterations=1 count=1 black do=Nothing");
run("8-bit");

/*
 * Dialog to select cells for subsequent vesicle counting:
 * User selects with rectangular or polygonal selection tools cells of interest in the MAX_Image
 * These ROIs will be added to the ROI manager
*/

Dialog.create("Number of cells");
	Dialog.addChoice("How many cells do you want to analyze?", Dial_NoCells, Dial_NoCells[0]);
Dialog.show();
	AnsCrop = Dialog.getChoice();
	run("ROI Manager...");
	selectWindow("ROI Manager");
	setLocation(ScrHROI, ScrWROI);
	script =
    "lw = WindowManager.getFrame('ROI Manager');\n"+
    "if (lw!=null) {\n"+
    "   lw.setSize(230, 400)\n"+
    "}\n";
  	eval("script", script); 
	roiManager("Reset");
		for (i=0; i<AnsCrop; i++) {
			waitForUser("Select Cell No: " + i+1 + " of " + d2s(AnsCrop, 0) + " to analyze");
			selectWindow("MAX_Bin_Image");		
			roiManager("Add");
			}
selectWindow("MAX_Bin_Image");		
run("Select All");
run("Median...", "radius=1.0 stack"); // median filter was used to smooth the vesicles, gives less noisy objects after thresholding

/*
 * loop to ensure user continues with an binary image:
 * opens Threshold function
 * macro only continues if user has generated an binary image by Thresholding
 */

for (z=0; z<100; z++) {
	if (!is("binary")) {
		run("Threshold...");
		selectWindow("Threshold");
		setLocation(ScrHROI, ScrWROI);
		waitForUser("Please select and apply a threshold.\nThen press OK to continue the macro.");
		}
	}
	
// closes Threshold window

if (isOpen("Threshold")) {
	selectWindow("Threshold");
	run("Close");
}

/*
 * run("Auto Threshold", "method=Yen white");
 * Auto Threshold removed in V1.0 to improve adjustment of the binary image for low intensity pictures
 * requires non-biased threshold selection
 * requires to control the binary image to original image by visual inspection
*/

run("Grays");
run("Fill Holes");

/*
 * Vesicle quantification by Particle Analyzer of previously selected cell ROIs
 * Number of cell ROIs will be quantified
 * Loop ensures that all previously selected cell ROIs will be analyzed
 * Particle Analyzer counts 4-20 pixel sized vesicles. Size was determined empirically. Change to match your structures of interest.
 * Prints numbers of vesicles for each cell ROI to the log file
 */

roiNo = roiManager("Count");
	for (j=0; j<roiNo; j++) {
		selectWindow("MAX_Bin_Image");
		roiManager("select", j);
		run("Analyze Particles...", "size=4-20 pixel show=Outlines display exclude");
			print(nResults);
			run("Clear Results"); 
			roiManager("deselect");
	}
selectWindow("Log");
	setLocation(ScrHLog, ScrWLog);						//adjusts location of Log window to middle of screen
	script =											//this script sets the size of the Log window to 150x400 px
    "lw = WindowManager.getFrame('Log');\n"+
    "if (lw!=null) {\n"+
    "   lw.setSize(150, 400)\n"+
    "}\n";
  eval("script", script); 
 
/*
 * Saving procedure
 * Adding cell ROI selections to all images
 * Saves all files to the image directory in a Results folder
 */

	selectWindow("MAX_Bin_Image");
		for (j=0; j<roiNo; j++) {
			roiManager("select", j);
			run("Add Selection...");
			}
		saveAs("tiff", splitDir + "Binary_" + fileNameWithoutExtension);
	selectWindow("MAX_Image");
		for (j=0; j<roiNo; j++) {
			roiManager("select", j);
			run("Add Selection...");
			}	
		saveAs("tiff", splitDir + "MAX_" + fileNameWithoutExtension);	
	selectWindow("Log");
	saveAs("text", splitDir + "Log_" +  fileNameWithoutExtension);
	if (isOpen("Results")) {
		selectWindow("Results");
		run("Close");
	}
	list = getList("image.titles"); 
		for (j=0; j<roiNo; j++) {
			selectWindow(list[3+j]);
			roiManager("select", j);
			//adds the ROIs of selected cells to the analyzed particles images, maximum Z-projection image and binary image								
			run("Add Selection...");			
			saveAs("tiff", splitDir + "Cell" + j+1 + "_" + fileNameWithoutExtension);	
		}
exit();	

//macro end