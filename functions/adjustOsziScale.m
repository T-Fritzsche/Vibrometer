function [CH1Res,CH2Res] = adjustOsziScale(visaObj)
% reads the current voltage levels and adjusts the scale
% Returns the obtained scale for CH1,CH2 or NaN if no valid
% scale could be determined.
% steps:
% 1. digitze
% 2. get the voltage from every channel
% 3. calculate the voltage/div
% 4. check if NaN or 0 and set the best voltage/div
% done
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
	%3. Calculate the voltage/div. Round up to the first decimal place
	UdivExciting = (ceil(UppExciting/8*1.3*10)/10);
	UdivSignal   = (ceil(UppSignal/8*1.3*10)/10);
	%4. Check if valid scales. Set NaN if invalid.
	if (UdivExciting < 0.1)
		UdivExciting = NaN;
	end
	if (UdivSignal < 0.1)
		UdivSignal = NaN;
	end
	%5. Set the voltage/div
	if ~isNaN(UdivExciting)
		fprintf(visaOszi,[':CHAN1:SCAL 'num2str(UdivExciting) 'V']);
	end
	if ~isNaN(UdivSignal)
		fprintf(visaOszi,[':CHAN2:SCAL 'num2str(UdivSignal) 'V']);
	end
	CH1Res=UdivExciting;
	CH2Res=UdivSignal;
end
