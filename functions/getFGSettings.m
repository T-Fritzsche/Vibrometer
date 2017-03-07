function [frequency, amplitudeVpp,offset] = getFGSettings(serial)
    %returns the current frequency, peak-to-peak value of the amplitude and the
    %offset of the frequency generator.

     operationComplete = str2double(query(serial,'*OPC?'));
    while ~(operationComplete==1)
        operationComplete = str2double(query(serial,'*OPC?'));
         pause(0.01);
    end
    currentSettings=query(serial,'SOUR1:APPL?');    %issue the cmd
    % will return sth like %"SIN +3.9764400000000E+04,+2.000E+00,+0.00E+00"
    % so we split at either 'SIN ' or ',' and extract the numbers.
    pattern='(SIN\s|,)+';
    tok = regexpr(currentSettings,pattern,'split');

    frequency    = str2double(tok{1,2});    
    amplitudeVpp = str2double(tok{1,3});   
    offset       = str2double(tok{1,4}); 
end