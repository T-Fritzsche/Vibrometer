function [localSettings]=readFromGUI(handle)
% returns all the settings of the GUI, which can be restored later with the
% 'writeToGUI' command.
%
% hObject    handle to SettApply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','handles',handle);

localSettings.FGen.Freq =        str2double(handle.SettFGenFreq.String);
localSettings.FGen.Vpp =         str2double(handle.SettFGenVpp.String);
localSettings.Oszi.AutoSettings =handle.SettOsziAuto.Value;
localSettings.Oszi.CH1EN =       handle.SettOsziCH1EN.Value;
localSettings.Oszi.CH2EN =       handle.SettOsziCH2EN.Value;
localSettings.Oszi.CH1Res =      str2double(handle.SettOsziCH1Res.String);
localSettings.Oszi.CH2Res =      str2double(handle.SettOsziCH2Res.String);
localSettings.Oszi.SelTBFromFG = handle.SettOsziSelTBFromFG.Value;
localSettings.Oszi.TimeBase =    str2double(handle.SettOsziTimebase.String);
localSettings.Oszi.Aq{1}.Nr =    handle.SettOsziAq1.Value;
localSettings.Oszi.Aq{2}.Nr =    handle.SettOsziAq2.Value;
localSettings.Oszi.Aq{3}.Nr =    handle.SettOsziAq3.Value;
localSettings.Oszi.Aq{4}.Nr =    handle.SettOsziAq4.Value;
localSettings.Oszi.Aq{1}.Str =   handle.SettOsziAq1.String{localSettings.Oszi.Aq{1}.Nr,1};
localSettings.Oszi.Aq{2}.Str =   handle.SettOsziAq2.String{localSettings.Oszi.Aq{2}.Nr,1};
localSettings.Oszi.Aq{3}.Str =   handle.SettOsziAq3.String{localSettings.Oszi.Aq{3}.Nr,1};
localSettings.Oszi.Aq{4}.Str =   handle.SettOsziAq4.String{localSettings.Oszi.Aq{4}.Nr,1};
localSettings.Vib.AutoSettings = handle.SettVibAuto.Value;
localSettings.Vib.VelResNR =     handle.SettVibVelRes.Value;
assignin('base','localSettings',localSettings);
