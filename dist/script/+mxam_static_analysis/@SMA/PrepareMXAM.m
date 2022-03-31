function PrepareMXAM(this)
    % Add necessary paths. Do not remove them afterwards to avoid deinitialization problems
    
    strMxamBatch = fullfile(this.strMxamDir, 'libs\adapters\com.modelengineers.mxam.tooladapter.matlab\matlabfunctions\mxambatch');
    strMxamAPI = fullfile(this.strMxamDir, 'libs\adapters\com.modelengineers.mxam.tooladapter.matlab\matlabfunctions\mxamapi');

    addpath(this.strChecksetDir);

    addpath(this.strMxamDir);
    addpath(strMxamBatch);
    addpath(strMxamAPI);            
end
