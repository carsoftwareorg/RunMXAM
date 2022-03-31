classdef SMA < emlib.Testing.EmlibTest
    % Run a MXAM Analysis on a testmodel with emlib blocks inside.
    
    properties % Options
        strArtifact = 'EMLIB_STATIC_TEST' % Test model, containing all emlib blocks
        strChecksetFilename = 'ef_floating_prj.mxmp' % Checks to execute
        strReportExtension = 'PDF' % Default file extension for report
        strReportDir = fullfile(emlib.Helper.Path.GetTestDir, '_results')
        strReportFilename = ['MXAM_Check_' datestr(now,'yyyymmdd')]
    end
    
    properties % Working Properties, to be filled in Test Preparation
        strMxamDir char % Path of MXAM
        strChecksetFullfile char % Path to Checkset    
        strReportFullFile char % Path to Report
        sResult struct % MXAM Results
    end
    
    methods (TestMethodSetup) % Prepare MXAM Run
        
        function FindMxam(this)
            % Find MXAM on the local machine
            
            % 1. MXAM is a valid Toolbox and already in path (easy)
            strMxamExecutable = which('mxam');
            this.strMxamDir = fileparts(strMxamExecutable);

            % Check if we found gold. Otherwise: No chance, abort the test execution
            this.assumeNotEmpty(this.strMxamDir, 'MXAM Drive could not be found on MATLAB path');
        end
        
        function FindCheckset(this)
            % Find Checkset file on local machine
            
            % 1. Checkset is a valid Toolbox and already in path (easy)
            strChecksetDir = fileparts(which('MXAM_Checks')); % Use Toolbox Handler as marker for checkset folder
            
            % Otherwise: No Chance, just abort the test execution
            this.assumeNotEmpty(strChecksetDir, 'Checkset directory could not be found');
            
            % Get the actual file
            asContents = dir([strChecksetDir '\**\*.mxmp']);
            abIsCheckSet = strcmp(this.strChecksetFilename, {asContents.name});
            this.strChecksetFullfile = fullfile(asContents(abIsCheckSet).folder, asContents(abIsCheckSet).name);
            
            % Verify there is exactly one Checksetfile
            this.assumeNotEmpty(this.strChecksetFullfile, sprintf(...
                'No Checkset file ''%s'' was found in ''%s''.', this.strChecksetFilename, strChecksetDir));
            this.assumeClass(this.strChecksetFullfile, 'char', sprintf(...
                'More than one checkset file ''%s'' was found in ''%s''.', this.strChecksetFilename, strChecksetDir));
            
        end
        
        function PrepareReport(this)
            % Find/Create report directory
            
            if ~isdir(this.strReportDir)
                mkdir(this.strReportDir)
            end

            this.strReportFullFile = fullfile(this.strReportDir, [this.strReportFilename, '.', this.strReportExtension]);
            
        end
        
        function PrepareTestModel(this)
            % Do necessary steps to prepare the testmodel
            
            % Check if TestModel is available
            this.assumeNotEmpty(which(this.strArtifact), sprintf(...
                'TestModel ''%s'' could not be found, please generate the test models first.', this.strArtifact));
            
            % Load Testmodel, MXAM would use 'open_system' otherwise, which takes too much time
            this.ApplyFixture('OpenModelFixture', this.strArtifact);
                        
        end
        
        function PrepareMXAM(this)
            % Add necessary paths. Do not remove them afterwards to avoid deinitialization problems
            
            strMxamBatch = fullfile(this.strMxamDir, '\libs\adapters\com.modelengineers.mxam.tooladapter.matlab\matlabfunctions\mxambatch');
            strMxamAPI = fullfile(this.strMxamDir, 'libs\adapters\com.modelengineers.mxam.tooladapter.matlab\matlabfunctions\mxamapi');

            addpath(this.strMxamDir);
            addpath(strMxamBatch);
            addpath(strMxamAPI);            
        end
        
    end
    
    methods (Test) % MXAM Run
        
        function MxamAnalysis(this)
            % Invoke MXAM, run an analysis and check results.
            
            % Get execution options from mxam api
            sMxamExecOpt = mxamapi_execution_options;
            sMxamExecOpt.s_project = this.strChecksetFullfile;
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
        
    end
    
    methods (TestMethodTeardown) % Evaluate Results from MXAM Run
        
        function EvaluateResults(this)
            % Get the results from MXAM run and let the testcase pass or fail depending on the results
            
            % Extract actual readable results
            asResults = this.ProcessMxamResults(this.sResult, false);
            
            % Create Links
            strShowLink = sprintf('<a href="matlab: emlib.StaticTest.SMA.ShowResults;">Show Results</a>');
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
        
    end
    
    methods (Static)
        
        function ShowResults()
            % Get the mxam results struct, which was assigned into the base workspace by MXAM and show
            % results in a clearly arranged, human readable way in the MATLAB command window.
            
            r_exec_opts = evalin('base', 'mxam_last_r_exec_opts');
            emlib.StaticTest.SMA.ProcessMxamResults(r_exec_opts, true);

        end
        
        function asResults = ProcessMxamResults(r_exec_opts, bShow)
            % Unpack the MXAM output argument, try to get the actual results and pack them to a readable
            % MATLAB structure.
            % Note this method doesn't follow to coding guidelines to avoid confusion with the xml
            % structure of the Mxam result.
            
            response = r_exec_opts.r_result.response;
            
            % The r_results variable is obviously the xml output of the MXAM analysis which was converted
            % to a MATLAB struct using xml2struct (see Matlab user contributions). Try to find the
            % desired information in there.
            
            % Assumptions
            % * ONE Model File
            % * Several Checks
            %
            % Desired Look of the report
            % * Our Report shall be Check-centristic, not 'guideline' centristic, like the MXAM report
            % * Small header/footer with Overall result
            % ** Modelname
            % ** Checksetname
            % ** Overall result
            % ** Number of Checks
            % ** Absolute and relative percentage of result type
            
            % Informations from report
            % * Structure:
            % ** Document --> Chapter --> Guideline --> Check --> Finding
            % * The interesting informations can be found in 'Finding'
            % * there the following attributes are of interest:
            % ** result
            % ** message
            % ** path
            % * The Checks must be extracted from the xml structure.
            % * If the check is not passed, there is a 'finding' child.
            % * There can be several findings under one check!
            
            %% Get overall result
            % Numbers
            avSummary = response.report.summary;
            abIsChecks = cellfun(@(x) strcmp(x.Attributes.items, 'checks'), avSummary);
            sCheckSummary = avSummary{abIsChecks};
            abIsFindings = cellfun(@(x) strcmp(x.Attributes.items, 'findings'), avSummary);
            sFindingSummary = avSummary{abIsFindings};
            
            % Get the thing
            avCountCheck = sCheckSummary.count;
            abPassed = cellfun(@(x) strcmp(x.Attributes.type, 'Passed'), avCountCheck);
            abInfo = cellfun(@(x) strcmp(x.Attributes.type, 'Passed with Infos'), avCountCheck);
            abWarning = cellfun(@(x) strcmp(x.Attributes.type, 'Warnings'), avCountCheck);
            abFailed = cellfun(@(x) strcmp(x.Attributes.type, 'Failed'), avCountCheck);
            abAborted = cellfun(@(x) strcmp(x.Attributes.type, 'Aborted'), avCountCheck);
            
            avCountFindings = sFindingSummary.count;
            abFindingIsFailed = cellfun(@(x) strcmp(x.Attributes.type, 'Failed'), avCountFindings);
            
            if any(abPassed);   nPassed = str2double(avCountCheck{abPassed}.Text);  else; nPassed = 0;  end
            if any(abInfo);     nInfo = str2double(avCountCheck{abInfo}.Text);      else; nInfo = 0;    end
            if any(abWarning);  nWarning = str2double(avCountCheck{abWarning}.Text);else; nWarning = 0; end
            if any(abFailed);   nFailed = str2double(avCountCheck{abFailed}.Text);  else; nFailed = 0;  end
            if any(abAborted);  nAborted = str2double(avCountCheck{abAborted}.Text);else; nAborted = 0; end
            
            nOverall = nPassed + nInfo + nWarning + nFailed + nAborted;
            
            if any(abFindingIsFailed)
                nFindings = str2double(avCountFindings{abFindingIsFailed}.Text);
            else
                nFindings = 0;
            end
            
            % Meta data
            strProjectName = response.report.project.title.Text;
            strDuration = response.report.analysis.duration.Text;
            strModel = response.report.artifacts.artifact.name.Text;
            
            %% Get Individual Check results
            % Get all chapters
            avChapters = response.report.document.chapter;
            
            % Get all guidelines
            avGuidelines = cellfun(@(x) x.guideline, avChapters, 'Uniform', false);
            % The result is mixed. If there is only one guideline in a chapter, it is a struct, otherwise a cell
            abIsStruct = cellfun(@(x) isstruct(x), avGuidelines);
            avGuidelines(abIsStruct) = cellfun(@(x) {{x}}, avGuidelines(abIsStruct));
            avGuidelines = horzcat(avGuidelines{:});
            
            % Get all checks
            avChecks = cellfun(@(x) x.check, avGuidelines, 'Uniform', false);
            % The result is mixed. If there is only one guideline in a chapter, it is a struct, otherwise a cell
            abIsStruct = cellfun(@(x) isstruct(x), avChecks);
            avChecks(abIsStruct) = cellfun(@(x) {{x}}, avChecks(abIsStruct));
            avChecks = horzcat(avChecks{:});
            
            % Get rid of unselected checks
            astrResults = cellfun(@(x) x.result.Text, avChecks, 'Uniform', false);
            avChecks(strcmp(astrResults, 'Unselected')) = [];
            
            % Now we got checks without and with findings. A check can have none, one or several findings depending on it's status.
            % The final number of elements in the result table depends on the number of findings + the checks without any findings.
            
            % Find check results with and without findings
            astrResults = cellfun(@(x) x.result.Text, avChecks, 'Uniform', false);
            
            % Deal with passed checks (no findings)
            avPassedChecks = avChecks(strcmp(astrResults, 'Passed'));
            astrCheckNames = cellfun(@(x) x.Attributes.id, avPassedChecks, 'Uniform', false);
            
            astrPassed = cell(size(astrCheckNames));
            for i = 1:numel(avPassedChecks)
                astrPassed{i} = struct(...
                    'Check', astrCheckNames{i}, ...
                    'Result', avPassedChecks{i}.result.Text, ...
                    'Path', '', ...
                    'Message', '');
            end
            
            % Deal with anormal checks (with findings)
            avAnormalChecks = avChecks(~strcmp(astrResults, 'Passed'));
            avFindings = cellfun(@(x) x.finding, avAnormalChecks, 'Uniform', false);
            abIsStruct = cellfun(@(x) isstruct(x), avFindings);
            avFindings(abIsStruct) = cellfun(@(x) {{x}}, avFindings(abIsStruct));
            astrCheckNames = cellfun(@(x) x.Attributes.id, avAnormalChecks, 'Uniform', false);
            
            astrFindings = cell(size(astrCheckNames));
            for i = 1:numel(avFindings)
                astrFindings{i} = struct(...
                    'Check', astrCheckNames{i}, ...
                    'Result', cellfun(@(x) x.result.Text, avFindings{i}, 'Uniform', false), ...
                    'Path', cellfun(@(x) x.path.Text, avFindings{i}, 'Uniform', false), ...
                    'Message', cellfun(@(x) x.message.Text, avFindings{i}, 'Uniform', false));
            end
            
            % Concatenate and sort
            asResults = horzcat(astrFindings{:}, astrPassed{:});
            % Sort alphabetical
            [~,idx]=sort({asResults.Check});
            asResults=asResults(idx);
            % Sort for result
            [~,idx]=sort({asResults.Result});
            asResults=asResults(idx);
            
            % Replace bad strings
            for i = 1:numel(asResults)
                asResults(i).Message = strrep(asResults(i).Message, '<', '');
                asResults(i).Message = strrep(asResults(i).Message, '>', '');
            end
            
            %% Show Results
            % Create Output for Command Window
            if ~bShow
                return
            end
            
            % Replace paths by path links
            for i = 1:numel(asResults)
                nLimit = 35;
                strCurrentPath = asResults(i).Path;
                if isempty(strCurrentPath); continue; end
                if numel(strCurrentPath) > nLimit
                    asResults(i).Path = sprintf('<a href="matlab: open_system(''%s'');hilite_system(''%s'');">%s</a>', ...
                        strModel, strCurrentPath, ['...' strCurrentPath(end-nLimit:end)]);
                else
                    asResults(i).Path = sprintf('<a href="matlab: open_system(''%s'');hilite_system(''%s'');">%s</a>', ...
                        strModel, strCurrentPath, strCurrentPath);
                end
            end
            
            % Print Header
            fprintf('\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')
            fprintf('\n+++ emlib MXAM Results +++++++++++++++++++++++++++++++++++++')
            fprintf('\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n')
            
            % Results
            if numel(asResults) > 1
                disp(struct2table(asResults));
            else % Numel = 1
                fprintf('\n');
                fprintf('Check:\t\t%s\n', asResults.Check);
                fprintf('Result:\t\t%s\n', asResults.Result);
                fprintf('Path:\t%s\n', asResults.Path);
                fprintf('Message:\t%s\n', asResults.Message);
            end
            
            % Summary
            fprintf('\n+++ Project:\t%s', strProjectName);
            fprintf('\n+++ Artifact:\t%s', strModel);
            fprintf('\n+++ Duration:\t%s\n', strDuration);
            fprintf('\n+++ Checks:\t\t%d', nOverall);
            fprintf('\n+++ Findings:\t%d', nFindings);
            fprintf('\n+++ Relative:\t%d%% pass,\t%d%% warning,\t%d%% fail,\t%d%% error', ...
                round((nPassed+nInfo)/nOverall*100), ...
                round(nWarning/nOverall*100), ...
                round(nFailed/nOverall*100), ...
                round(nAborted/nOverall*100));
            fprintf('\n+++ Absolute:\t%d pass, \t%d warning, \t%d fail, \t%d error', ...
                nPassed+nInfo, nWarning, nFailed, nAborted);
            fprintf('\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n')
            
        end
        
    end
    
end