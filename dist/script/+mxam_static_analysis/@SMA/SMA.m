classdef SMA < matlab.unittest.TestCase
    % Run a MXAM Analysis on a testmodel with emlib blocks inside.
    
    properties % Options
        strArtifact
        strArtifactDir
        strCheckset
        strChecksetDir
        strReportExtension
        strReportDir
        strReportFilename
        strMxamDir
    end
    
    properties % Working Properties, to be filled in Test Preparation
        strReportFullFile char % Path to Report
        sResult struct % MXAM Results
    end
    
    methods (TestMethodSetup) % Prepare MXAM Run
        PrepareMXAM(this)                
        PrepareReport(this)
        PrepareTestModel(this)
    end
    
    methods (Test) % MXAM Run
        MxamAnalysis(this)
    end
    
    methods (TestMethodTeardown) % Evaluate Results from MXAM Run
        EvaluateResults(this)
    end
    
    methods (Static)
        ShowResults()
        asResults = ProcessMxamResults(r_exec_opts, bShow)
    end
    
end
