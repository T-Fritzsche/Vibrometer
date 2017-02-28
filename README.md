# Vibrometer Surface-Scan
Matlab based measurement setup for a vibrometer surface-scan to obtain the
**velocity** and **change of displacement**.

This sofware was a by-product of my master-thesis at the TU-Darmstadt. I
had to characterize the mechanical properties of several ultrasonic transducers to verify the simulations I was running in COMSOL-Multiphysics. To increase the accuracy of my reference data I decided to obtain the velocity and displacement at the whole surface area of the transducer. To do so, I used a laser-vibrometer we had at our institute. These can measure the velocity in just one point. So to get the whole area covered, I decided to use a small x-y-stage which would move the transducer below the laser-vibrometer and control the complete setup in matlab. 

## Measurement System
<img src="doc/images/mech_setup.jpg" width="560"/> <img src="doc/images/mech_setup_detail.jpg" width="320"/>
The system contains of a Oscilloscope (DSO-X 2002A, Keysight) which is
connected via VISA-Interface. The transducer under test is excited via
waveform generator (AFG-2225, GWinstek) and the velocity is measured by a
laser vibrometer (Polytec OFV-534 head and OFV-3001 evaluation unit) which are
connected to a PC via serial port. To move the transducer two linear axis (UT-100,
Newport) are controlled via self-made motor control. A acoustic reflector is
mounted in the course of beam to prevent standing waves.

The setup features the measurement of **velocity** and **displacment**:
+ time-dependent over 1.5 period
+ in addition to the excitation voltage
+ additionally the phase-shift between excitation and mechanical parameter

The area of interest can be shaped as a:
+ square
+ cirle
+ straigt line
	- horizontal
	- vertical
	- diagonal ( / or \ )
+ single point

Additionally
+ all the settings and the whole routine is controled by matlab (so you can
  use via remote-desktop)
+ a usb-microscope shows the live progress in the matlab interface

## Setup
Setup is fairly easy. Just clone/download the git and run it in matlab.
To clone either use ``` git clone https://github.com/t-fritzsche/vibrometer ``` or download the zip-file above.
Then ``` open matlab ```, navigate to the folder and ``` run Interface.m```.
Follow the instructions in the interface to run the measurement.

### Problems at startup
In case the application repeatedly shows an error message containing **'Connection to devices failed - check and try to reconnect'** make sure the ennumeration of the COM-ports in ```/functions/connectDevices.m``` matches the setup. Windows tends to changes the numbers every now and then.

## Results
Once the measurement was successful, a click on ```Evaluate Measurements``` generates three plots of velocity and displacement in **PHASE** and **AMPLITUDE**. Additionally a time-dependent representation is shown in the interface and can be controlled by a slider. All plots and a .mat file with the time-dependent information will be saved in the specified directory.

Plot of the amplitude | Plot of the Phase | Time-dependent
:----------------------------:|:-------------------------:|:--------:
![Displacement of movement (amplitude)](doc/images/velo_amplitude.png)|![Displacement of movement (phase)](doc/images/disp_phase.png)|![Displacment (time dependent)](doc/images/displacement.gif)

## Specifications

Category          | Value
:----------------:|:------------------
Exitation voltage | 0-20 V (peak2peak)
Scan area (max)   | (120x120) mm
Stepsize	  | 1 µm
Repeatability     | 4 µm

Velocity resolution of the vibrometer

Measurement range | Full scale output | Resolution   | Maximum frequency
:----------------:|:-----------------:|:------------:|:-----------------
mm/s/V		  | mm/s (pp)         | µm/s/sqrt(Hz)| kHz
**OFV-3000**	  | **(currently used)**|	     | 
1		  | 20		      | 0.3	     | 20
5		  | 100		      | 0.6	     | 50
25		  | 500		      | 0.8	     | 50
125		  | 2500	      | 1.0	     | 50
1000		  | 20000	      | 1.2	     | 50
**OFV-2520**	  | **(available option)**|	     | 
5		  | 50		      | 0.2	     | 250
100		  | 1000	      | 0.5	     | 3000
1000		  | 10000	      | 2.5	     | 3200


Objective	     |	  |**20x**|**10x**|Standard|Standard|Standard|
--------------------:|:--:|:-----:|:-----:|:-------:|:------:|:-------:
Stand-off distance   | mm | 21.7  | 37.3  | 200     | 300    | 500
Laser depth-of-field | mm | 0.012 | 0.048 | +-1     | +-3    | +-10
**Spot diameter**    | µm | 1.5   | 3.0   |**25**   | 40     | 70

## Usage
The interface should guide you through the measurement process. Buttons are shown grayed as long as a previous step isn't completed. Evaluation of previous recordet measurement data can be conducted without connection to any measurement devices.
![Interface](doc/images/interface.jpg)
### Program Sequence
<img src="http://T-Fritzsche.github.io/Vibrometer/doc/images/measurement-routine.svg" width="600">

##Resultfile
All measurement values will both be stored in one large .mat file and in
several smaller files for every data point. This should prevent data loss in
case of power shortage, unexpected windows-updates or other uncontrollable
failures which result in loosing the matlab cell. Usually the data-specific
points can be removed if the large .mat cell is complete. 

The cell is either sqare *n x n*, a *1 x n* vector or a *1x1* point depending on the shape of the scan area. Cell-entries that should not be scanned contain NaN values for the X-Pos and Y-Pos (i.e. outer corners for a circular area).
![](http://T-Fritzsche.github.io/Vibrometer/doc/images/datatype-explanation.svg)
Note that the time is given relative to the trigger point so expect a symmetric time around the zero-point.

# Todo
As the time has run out and I had to move on the the other tasks of my thesis, some things aren't fully implemented:
+ The evaluation routine can't distinguish between area (square/circle), line or point plots. So if you did a line plot you'll end up with a 1*xn* cell which you have the check yourself. There is the function ``` manualEvaluation/evaluateMeasurementLinePlot.m``` which can do it step wise. To integrate it in the full interface some differentiation needs to be added.
+ The **Auto** function considers the range of the vibrometer only. It would be nice to adapt the scale of the oscilloscope at every measurement point. This would result in the largest repesentable wave-sine and therefore increase the overal resolution.



