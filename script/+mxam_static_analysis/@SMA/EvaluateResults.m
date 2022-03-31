function EvaluateResults(this)
    % Get the results from MXAM run and let the testcase pass or fail depending on the results
    
    % Extract actual readable results
    asResults = this.ProcessMxamResults(this.sResult, false);
    
    % Create Links
    strShowLink = sprintf('<a href="matlab: SMA.ShowResults;">Show Results</a>');
    strReportLink = sprintf('<a href="matlab: open(''%s'');">Open Report</a>', ...
        this.strReportFullFile);
    
    %% Actual Test
    % Pass if neighter aborts, nor failures happend during the analysis
    %astrBadResults = {'Aborted', 'Failed', 'Warning'};
    astrBadResults = {'Aborted', 'Failed'};
    for strBadResult = astrBadResults
        strBadResult = strBadResult{1}; %#ok<FXSET>
        abIsBad = strcmp({asResults.Result}, strBadResult);
        if any(abIsBad)
            astrNames = {asResults.Check};
            strNames = strjoin(unique(astrNames(abIsBad)), ', ');
            this.verifyFail(sprintf('The following checks have the result ''%s'': %s. %s or %s.', ...
                strBadResult, strNames, strShowLink, strReportLink));
        end
    end
    
end