function ShowResults()
    % Get the mxam results struct, which was assigned into the base workspace by MXAM and show
    % results in a clearly arranged, human readable way in the MATLAB command window.
    
    r_exec_opts = evalin('base', 'mxam_last_r_exec_opts');
    SMA.ProcessMxamResults(r_exec_opts, true);

end
