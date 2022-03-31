function []=configureMXAMChecksets()
	strInstallDir = fileparts(mfilename('fullpath'));
	strPackageDir = fullfile(strInstallDir, 'MXAM_Checks');
	cd(strPackageDir);
	MXAM_Checks.Start;

	
	

end
