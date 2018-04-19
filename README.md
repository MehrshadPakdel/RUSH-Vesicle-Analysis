# RUSH-Vesicle-Analysis
A FIJI / ImageJ macro to measure number of cytoplasmic vesicles in Z-stack microscopy images

# Goal
The macro faciliates the quantification of cytoplasmic vesicles in Z-stack microscopy images. This macro was designed for retention using selective hooks (RUSH) constructs (Boncompain et al. 2012). Additionally, the macro will allow to quantify vesicle numbers of reporters that are retained in endoplasmic reticulum (ER) by using a ER marker as a co-stain. It will also work for any other construct or probe that label vesicular structures.

# Installation
Simply copy the macro file to your macro folder in your [Fiji](https://imagej.net/Fiji) directory and restart Fiji. You can access the macro from the Plugin section in Fiji.

# Usage
Acquire single stack or Z-stacks images to cover the full volume of cells that express your reporter or are labeled with the probe of your interest.

**1. Single channel images with reporter or labeled probe only**

Start the macro and choose how many cells you want to analyze. Select your cell(s) by e.g. polygon or rectangular selection tools. Next, select a suitable threshold and press apply to extract the vesicular objects in a binary image. The macro uses the particle analyzer of the selected cell(s) and prints the number of selected vesicles to the log file. All processed images and log files will be saved in a results folder in the image directory. 

**2. Dual channel images with ER co-stain**

Rationale: To analyze vesicle numbers of RUSH reporters that are still retained in the ER ("-Biotin") requires to substract the RUSH reporter objects with a ER co-stain marker. Starting the macro with a image that contains more than one channel, the macro will ask the user for the timepoint that should be analyzed. Choose your timepoint you want to analyze "- Biotin" (ER structures) or "+ Biotin" (vesicular structures). If "- Biotin" chosen, the user has to assign the channels to the ER marker or RUSH reporter. The user then chooses how many cells to analyze and selects the cell(s) by polygon or rectangular selection tools. After selecting a threshold for each channel, the ER marker will be subtracted from the RUSH reporter by the imageCalculator function to obtain a corrected binary image that should not contain any ER derived signal for subsequent vesicle quantification. If "+ Biotin" chosen, the reporter will be analyzed as described under section 1. above. 

# Citation
The macro will be uploaded and the citation will be updated as soon as the publication is released.
