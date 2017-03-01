function [CH1Res,CH2Res] = adjustOsziScale(visaObj)
% reads the current voltage levels and adjusts the scale
% Returns the obtained scale for CH1,CH2 or NaN if no valid
% scale could be determined.
% steps:
% 1. digitze
% 2. get the voltage from every channel
% 3. Check if signal is representable
% 4. calculate the voltage/div
% 5. check if NaN and set the best voltage/div
% 6. read the applied settings from the oszilloscope
% done
    ErrorValue=9.9E+37; % value the oscilloscope returns in case of an error

    %1. Sample the current waveform
	fprintf(visaObj,':DIGitize');
	pause(0.2);
	operationComplete = str2double(query(visaObj,'*OPC?'));
	while ~operationComplete
		operationComplete = str2double(query(visaObj,'*OPC?'));
	end
	%2. Get the voltag level (peak-to-peak) from every channel
	UppExciting=str2double(query(visaObj,':MEASure:VPP? CHAN1'));
	UppSignal=str2double(query(visaObj,':MEASure:VPP? CHAN2'));
    %3. Check if value is in valid range. The measurement returns
    %ErrorValue if the signal is out of range. So in this case we use the
    %max Range and measure again.
    if UppExciting == ErrorValue
        fprintf(visaObj,':CHAN1:SCAL 5V');
        fprintf(visaObj,':DIGitize');
        UppExciting=str2double(query(visaObj,':MEASure:VPP? CHAN1'));
    end
    if UppSignal == ErrorValue
        fprintf(visaObj,':CHAN2:SCAL 5V');
        fprintf(visaObj,':DIGitize');
        UppSignal=str2double(query(visaObj,':MEASure:VPP? CHAN2'));
    end
	%4. Calculate the voltage/div. Round up to the first decimal place
	UdivExciting = (ceil(UppExciting/8*1.1*10)/10);
	UdivSignal   = (ceil(UppSignal/8*1.3*10)/10);
	%5. Set the voltage/div. 
	if ~isnan(UdivExciting) && (UppExciting < ErrorValue)
		fprintf(visaObj,[':CHAN1:SCAL ' num2str(UdivExciting) 'V']);
	end
	if ~isnan(UdivSignal) && (UppSignal < ErrorValue)
		fprintf(visaObj,[':CHAN2:SCAL ' num2str(UdivSignal) 'V']);
    end
    %6. read the applied values from the oszilloscope.
	CH1Res=str2double(query(visaObj,':CHAN1:SCAL?'));
	CH2Res=str2double(query(visaObj,':CHAN2:SCAL?'));
end
