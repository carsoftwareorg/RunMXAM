% strArtifact = 'MXAM_Test';
% strArtifactDir = '.\testdata\MXAM\';
% strChecksetDir = 'C:\Users\DevInf-2\Documents\projects\matlab-test\script\MXAM_Checks_v7.3.0\MXAM_Checks';
% strCheckset = 'projects\ef8\HCP1\hcp1_chassis_fixpoint.mxmp';
% strMxamDir = 'C:\Tools\MXAM\7_2_0';

disp(strMxamDir);
disp(strArtifact);
disp(strArtifactDir);
disp(strChecksetDir);
disp(strCheckset);

strReportExtension = 'PDF'; % Default file extension for report
strReportDir = fullfile(pwd, '\_results\MXAM');
strReportFilename = 'Report';

sma = mxam_static_analysis.SMA;
sma.strArtifact = strArtifact;
sma.strCheckset = strCheckset;
sma.strReportExtension = strReportExtension;
sma.strReportDir = strReportDir;
sma.strReportFilename = strReportFilename;
sma.strMxamDir = strMxamDir;
sma.strArtifactDir = strArtifactDir;
sma.strChecksetDir = strChecksetDir;

sma.run