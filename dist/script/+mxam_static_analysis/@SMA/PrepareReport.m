function PrepareReport(this)
    % Find/Create report directory
    
    if ~isfolder(this.strReportDir)
        mkdir(this.strReportDir)
    end

    this.strReportFullFile = fullfile(this.strReportDir, [this.strReportFilename, '.', this.strReportExtension]);
end
