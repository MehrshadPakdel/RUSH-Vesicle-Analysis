/*
---------------------------------------------------------------------------------------------------
					Live-Cell_Vesicle_Analysis_V2

	* facilitates the measurement of vesicle numbers in a multi-frame image
	* Optimized for RUSH cargo transport from ER to Golgi to secretory vesicles
	* Thresholding optimized for the first 25 frames for ER signal 
	* Thesholding optimized after first 25 frames for Golgi and vesicular signal
	* Analyze particles quantifies vesicular objects ranging from 4-40 pixels
	* 
	* Future work will improve hard coded variables and documentation

Mehrshad Pakdel

mehrshad.pakdel@posteo.de
https://github.com/MehrshadPakdel

November 29, 2019
----------------------------------------------------------------------------------------------------
*/

originalImage = getTitle();
dir = getDirectory("image");
run("Duplicate...", "title=[dupImage] duplicate");
selectWindow("dupImage");
dupImg = getTitle();
close(originalImage);
run("Options...", "iterations=1 count=1 black do=Nothing");
run("8-bit");
run("Subtract Background...", "rolling=80 stack");
run("Enhance Contrast...", "saturated=0 process_all");
run("Median...", "radius=0.5 stack");
setOption("Stack position", true);
       for (n=1; n<=25; n++) {
        	setSlice(n);
			run("Auto Threshold", "method=Minimum white");
		}
		for (n=26; n<=nSlices; n++) {
        	setSlice(n);
			run("Auto Threshold", "method=Moments white");
		}
	for (n=1; n<=nSlices; n++) {
        	setSlice(n);	
			run("Analyze Particles...", "size=4-40 pixel show=Outlines display exclude");
			print(nResults);
			run("Clear Results"); 
			selectWindow("Drawing of dupImage");	
			run("Close");
		}	
selectWindow("dupImage");
run("Analyze Particles...", "size=4-40 pixel show=Outlines display exclude stack");	

splitDir= dir + "/Results_" + originalImage + "/";
File.makeDirectory(splitDir);
list = getList("image.titles"); 
	selectWindow(list[0]);
	saveAs("tiff", splitDir + "Binary_" + originalImage);	
	selectWindow(list[1]);
	saveAs("tiff", splitDir + "Particles_" + originalImage);
	selectWindow("Log");
	saveAs("text", splitDir + "Log_" +  originalImage);
	selectWindow("Results");
	run("Close");