# WhiskerTracker_Enhanced
Dev version of the Hires Lab Whisker Tracker
Created and maintained by @jonathansy
The latest iteration of code that began in 2014.
### Summary
This package is designed to process a batch of files using the Janelia Farm Whisker Tracker. It can start from raw SEQ files (of the type created by Norpix software) or MPEG-4 files. Simple modifications can allow tracking of AVI files or TIFF stacks. The enhanced package has been modified to speed up and automate as much workflow as possible and works better across multiple CPU cores.  

## Dependencies
* [Janelia Farm Whisker Tracker Package](https://github.com/nclack/whisk)
  (Windows Binaries can also be found [here](https://openwiki.janelia.org/wiki/display/MyersLab/Whisker+Tracking+Downloads))
* [MParallel](https://github.com/lordmulder/MParallel) (the code will automatically attempt to copy it from the Hires Lab NAS if your computer is connected)
* MATLAB (Code was tested on R2017b, R2016b and R2013a although backwards compatibility issues seem unlikely) 

## Setup
The Janelia Farm Whisker Tracker should be installed and placed on the system path (either by manually editing the environment folder or by selecting that option when installing using the Windows Installer). The tracker can run without being on the system path, but this will require editing the system commands in whikser_tracker_true_parallel.m to point to the new path

The entire WhiskerTracker_Enhanced package, Piotr's Toolbox, and MParallel should be on the MATLAB path. The whikser_tracker_true_parallel script will attempt to manually retrieve MParallel from the Hires Lab NAS if it is not already present. 

You can run the code either by providing inputs to the start_whisker_tracking.m function or by editing and calling MAIN_QUEUE.m MAIN_QUEUE was designed for the greatest ease of use and allows you to queue up multiple directories of files to process. start_whisker_tracking.m is limited to a single directory. MAIN_QUEUE also allows editing of the whisker tracking parameters used by the Janelia Farm tracker. Please carefully read [their notes](https://openwiki.janelia.org/wiki/display/MyersLab/Whisker+Tracking+Tutorial) on the tracker to understand what parameters are needed by your own setup. Note that that defaults listed in the scripts in this package are due to the equipment used by the Hires Lab and are not indicative of any sort of universal setup. 

## Troubleshooting
> Section under construction

## Benchmarks
> Section under construction
