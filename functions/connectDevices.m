function[sAxis,visaOszi,sFG,sVibrometer,sucessfull]=connectDevices() %
%set and initialize the connection to the external devices 
%(function generator, oscilloscope, x-y-stage, %vibrometer) 
% if all the connctions can be established, the function returns
% 'sucessfull=1' otherwise '0' and a uiwait-errormessage
%
sucessfull=1;
%% Open the interface to the xy-motor-control
try
    sAxis = serial('COM6');
    set(sAxis,'BaudRate',115200,'Parity','none','Terminator','LF','Timeout',0.5); 
    fopen(sAxis);
catch exceptions
    uiwait(msgbox('Could not connect to Axis'))
    sucessfull=0;
    return
end

%empty input buffer
flushinput(sAxis);
%% Open the interface to the oszilloscope
% Init instrument DSO-X2002A
try
    visaOszi = visa('agilent','USB0::0x0957::0x179B::MY51360284::0::INSTR');
    % Set the buffer size
    visaOszi.InputBufferSize = 1000000;
    % Set the timeout value
    visaOszi.Timeout = 1000;
    % Set the Byte order
    visaOszi.ByteOrder = 'littleEndian';
    % Open the connection
    fopen(visaOszi);
catch exceptions
    uiwait(msgbox('Could not connect to Oszilloscope'))
    sucessfull=0;
    return
end
%% Open the interface to the function generator
try
    sFG = serial('COM4');
    set(sFG,'BaudRate',115200,'Parity','none','Terminator','CR','Timeout',1); 
    fopen(sFG);
    ID=query(sFG,'*IDN?');
    if isempty(strfind(ID,'GW INSTEK,AFG-2225'))
        sucessfull=0;
    end
catch exceptions
   uiwait(msgbox('Could not connect to Function Generator'))
    sucessfull=0;
    return
end

%empty input buffer
flushinput(sFG);
%% Open the interface to the vibrometer
try
    sVibrometer = serial('COM7');
    set(sVibrometer,'BaudRate',9600,'Parity','none','Terminator',{'LF','CR'},'Timeout',2); 
    fopen(sVibrometer);
catch exceptions
    uiwait(msgbox('Could not connect to Vibrometer'))
    sucessfull=0;
    return
end
%empty input buffer
flushinput(sVibrometer);
