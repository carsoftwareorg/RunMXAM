function MxamAnalysis(this)
    % Invoke MXAM, run an analysis and check results.
    
    % Get execution options from mxam api
    sMxamExecOpt = mxamapi_execution_options;
    sMxamExecOpt.s_project = fullfile(this.strChecksetDir, this.strCheckset);
    sMxamExecOpt.cs_artifacts = {this.strArtifact};
    sMxamExecOpt.b_create_report = false; % Prevent direct output of Report
    sMxamExecOpt.b_synchronousExecution = true;
    sMxamExecOpt.r_reports = struct(...
        's_directory', this.strReportDir, ...
        's_name', this.strReportFilename, ...
        's_format', this.strReportExtension, ...
        's_detail', 'COMPACT');
    
    %% Start MXAM
    try
        this.sResult = mxamapi_start_batch_execution(sMxamExecOpt);
    catch oME
        this.verifyFail('Something strange happend during the MXAM analysis.')
        rethrow(oME);
    end
    
end