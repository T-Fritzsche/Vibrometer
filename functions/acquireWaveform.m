function[waveReturn]=AcquireWaveform(visaObj,Settings)
% This function starts the data acquisition of the oscilloscope, records the
% waveform of the exciting voltage of the function generator at channel 1 and
% the velocity dependent voltage of the vibrometer on channel 2. Additionally
% certain marker values (peak to peak voltage, frequency) which are specified
% in Settings.Oszi.Aq{i}.Str are also obtained and returned with the waveform.

    ErrorValue=9.9E+37; % value the oscilloscope returns in case of an error

  
        %% Check for System errors
    instrumentError = query(visaObj,':SYSTEM:ERR?');
    while ~isequal(instrumentError,['+0,"No error"' char(10)])
        disp(['Instrument Error: ' instrumentError]);
        instrumentError = query(visaObj,':SYSTEM:ERR?');
    end
    
    %% start run
    fprintf(visaObj,':DIGitize');
    pause(3);
    operationComplete = str2double(query(visaObj,'*OPC?'));
    while ~operationComplete
        operationComplete = str2double(query(visaObj,'*OPC?'));
    end

    %% Specify data and data processing

    % Maximum value storable in a INT16
    INT16tMAX = 2^16; 

    
%     prepare empty return values
    waveform.YData1=NaN;
    waveform.VoltsPerDiv1=NaN;
    waveform.YData2=NaN;
    waveform.VoltsPerDiv2=NaN;
    waveform.XData1=NaN;
    waveform.Aq1=NaN;
    waveform.Aq2=NaN;
    waveform.Aq3=NaN;
    waveform.Aq4=NaN;
    waveform.PhaseShift=NaN;
    waveform.Points=NaN;
    waveform.SecPerDiv=NaN;
    
    % Specify data from Channel 1
    if(Settings.Oszi.CH1EN==1)
        fprintf(visaObj,':WAVEFORM:SOURCE CHAN1'); 
        % Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
        fprintf(visaObj,':WAVEFORM:FORMAT WORD');
        % Set the byte order on the instrument as well
        fprintf(visaObj,':WAVEFORM:BYTEORDER LSBFirst');
        % Get the preamble block
        preambleBlock1 = query(visaObj,':WAVEFORM:PREAMBLE?');
        % The preamble block contains all of the current WAVEFORM settings.  
        % It is returned in the form <preamble_block><NL> where <preamble_block> is:
        %    FORMAT        : int16 - 0 = BYTE, 1 = WORD, 2 = ASCII.
        %    TYPE          : int16 - 0 = NORMAL, 1 = PEAK DETECT, 2 = AVERAGE
        %    POINTS        : int32 - number of data points transferred.
        %    COUNT         : int32 - 1 and is always 1.
        %    XINCREMENT    : float64 - time difference between data points.
        %    XORIGIN       : float64 - always the first data point in memory.
        %    XREFERENCE    : int32 - specifies the data point associated with
        %                            x-origin.
        %    YINCREMENT    : float32 - voltage diff between data points.
        %    YORIGIN       : float32 - value is the voltage at center screen.
        %    YREFERENCE    : int32 - specifies the data point where y-origin
        %                            occurs.
        % Now send commmand to read data
        fprintf(visaObj,':WAVEFORM:DATA?');
        % read back the BINBLOCK with the data in specified format and store it in
        % the waveform structure. FREAD removes the extra terminator in the buffer
        % waveform.RawData1 = binblockread(visaObj,'uint16'); fread(visaObj,1);
        waveform.RawData1 = binblockread(visaObj, 'uint16'); fread(visaObj,1);

        %  split the preambleBlock into individual pieces of info
        preambleBlock1 = regexp(preambleBlock1,',','split');

        % store all this information into a waveform structure for later use
        waveform.Format = str2double(preambleBlock1{1});     % This should be 1, since we're specifying INT16 output
        waveform.Type = str2double(preambleBlock1{2});  
        waveform.Points = str2double(preambleBlock1{3});
        waveform.Count = str2double(preambleBlock1{4});      % This is always 1
        waveform.XIncrement = str2double(preambleBlock1{5}); % in seconds
        waveform.XOrigin = str2double(preambleBlock1{6});    % in seconds
        waveform.XReference = str2double(preambleBlock1{7});
        waveform.YIncrement1 = str2double(preambleBlock1{8}); % V
        waveform.YOrigin = str2double(preambleBlock1{9});
        waveform.YReference = str2double(preambleBlock1{10});
        waveform.VoltsPerDiv1 = (INT16tMAX * waveform.YIncrement1 / 8);      % V maxVal mal die einzelnen Schritte durch 8div
        waveform.Offset = ((INT16tMAX/2 - waveform.YReference) * waveform.YIncrement1 + waveform.YOrigin);         % V
        waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10 ; % seconds
        waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds
        % Generate X & Y Data
        waveform.XData1 = waveform.XIncrement.*(0:waveform.Points-1) + waveform.XOrigin;
        waveform.YData1 = (waveform.YIncrement1.*(waveform.RawData1 - waveform.YReference)) + waveform.YOrigin; 
    end
    
    % Specify data from Channel 2; f�r Erkl�rung s. Channel1
    if(Settings.Oszi.CH2EN==1)
        fprintf(visaObj,':WAVEFORM:SOURCE CHAN2'); 
        fprintf(visaObj,':WAVEFORM:FORMAT WORD');
        fprintf(visaObj,':WAVEFORM:BYTEORDER LSBFirst');
        preambleBlock2 = query(visaObj,':WAVEFORM:PREAMBLE?');
        fprintf(visaObj,':WAVEFORM:DATA?');
        waveform.RawData2 = binblockread(visaObj,'uint16'); fread(visaObj,1);

        preambleBlock2 = regexp(preambleBlock2,',','split');

        % store all this information into a waveform structure for later use
        waveform.Format = str2double(preambleBlock2{1});     % This should be 1, since we're specifying INT16 output
        waveform.Type = str2double(preambleBlock2{2});
        waveform.Points = str2double(preambleBlock2{3});
        waveform.Count = str2double(preambleBlock2{4});      % This is always 1
        waveform.XIncrement = str2double(preambleBlock2{5}); % in seconds
        waveform.XOrigin = str2double(preambleBlock2{6});    % in seconds
        waveform.XReference = str2double(preambleBlock2{7});
        waveform.YIncrement2 = str2double(preambleBlock2{8}); % V
        waveform.YOrigin = str2double(preambleBlock2{9});
        waveform.YReference = str2double(preambleBlock2{10});
        waveform.VoltsPerDiv2 = (INT16tMAX * waveform.YIncrement2 / 8);
        % Generate X & Y Data
        waveform.XData2 = waveform.XIncrement.*(0:waveform.Points-1) + waveform.XOrigin;
        waveform.YData2 = (waveform.YIncrement2.*(waveform.RawData2 - waveform.YReference)) + waveform.YOrigin; 
    end
    % Measurements on display
    for i=1:4
        if ~(strcmp(Settings.Oszi.Aq{i}.Str,'') || strcmp(Settings.Oszi.Aq{i}.Str,''))  %check if !empty
            %seperate after the first space --> we need to enter a '?' in
            %betwen to create a request: VPP CHAN1 --> VPP? CHAN1
            splitCMD = regexp(Settings.Oszi.Aq{i}.Str,' ','split','once');   
            CMD=strcat(':MEASure:',splitCMD(1),{'? '},splitCMD(2)); % {'? }encapsulated to save space
            name=strcat('Aq',num2str(i));
            waveform.(matlab.lang.makeValidName(name))=str2double(query(visaObj,CMD{1})); %create valid variablename and save 
            pause(0.1);
       end
    end
    
    %works only if both channels are enabled
    if ((Settings.Oszi.CH1EN==1) && (Settings.Oszi.CH2EN==1))
        waveform.PhaseShift = str2double(query(visaObj,':MEASure:PHASe? CHAN2,CHAN1'));
    else
        waveform.PhaseShift=ErrorValue;
    end
    %run only once if value is correct.. otherwise repeat until RetryMax
    if waveform.PhaseShift == ErrorValue
        fprintf(visaObj,':DISPlay:CLEar');
        fprintf(visaObj,'*CLS');
        operationComplete = str2double(query(visaObj,'*OPC?'));
        while ~operationComplete
            operationComplete = str2double(query(visaObj,'*OPC?'));
        end
    end
    
    %generate the save-data
    waveReturn.YData1=waveform.YData1;
    waveReturn.VoltsPerDiv1=waveform.VoltsPerDiv1;
    waveReturn.YData2=waveform.YData2;
    waveReturn.VoltsPerDiv2=waveform.VoltsPerDiv2;
    waveReturn.XData=waveform.XData1;
    waveReturn.Aq1=waveform.Aq1;
    waveReturn.Aq2=waveform.Aq2;
    waveReturn.Aq3=waveform.Aq3;
    waveReturn.Aq4=waveform.Aq4;
    waveReturn.PhaseShift=waveform.PhaseShift;
    waveReturn.Points=waveform.Points;
    waveReturn.SecPerDiv=waveform.SecPerDiv;
end
