function writeToGUI(handles,localSettings)
% restores all the settings of the GUI, which were previously stored with 
% the 'readFromGUI' command.

	assignin('base','handles',handles);
	assignin('base','localSettings',localSettings);
	handles.SettFGenFreq.String =       num2str(localSettings.FGen.Freq);
	handles.SettFGenVpp.String =        num2str(localSettings.FGen.Vpp);
	handles.SettOsziAuto.Value =        localSettings.Oszi.AutoSettings;
	handles.SettOsziCH1EN.Value =       localSettings.Oszi.CH1EN;
	handles.SettOsziCH2EN.Value =       localSettings.Oszi.CH2EN;
	handles.SettOsziCH1Res.String =     num2str(localSettings.Oszi.CH1Res);
	handles.SettOsziCH2Res.String =     num2str(localSettings.Oszi.CH2Res);
	handles.SettOsziSelTBFromFG.Value = localSettings.Oszi.SelTBFromFG;
	handles.SettOsziTimebase.String =   num2str(localSettings.Oszi.TimeBase);
	handles.SettOsziAq1.Value =         localSettings.Oszi.Aq{1}.Nr;
	handles.SettOsziAq2.Value =         localSettings.Oszi.Aq{2}.Nr;
	handles.SettOsziAq3.Value =         localSettings.Oszi.Aq{3}.Nr;
	handles.SettOsziAq4.Value =         localSettings.Oszi.Aq{4}.Nr;
	handles.SettVibAuto.Value =         localSettings.Vib.AutoSettings;
	handles.SettVibVelRes.Value =       localSettings.Vib.VelResNR;
end
