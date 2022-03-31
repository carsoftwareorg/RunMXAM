function PrepareTestModel(this)
    % Do necessary steps to prepare the testmodel

    % Prepare chekcset
    addpath(this.strArtifactDir);

    % Check if TestModel is available
    this.assumeNotEmpty(which(this.strArtifact), sprintf(...
        'TestModel ''%s'' could not be found, please generate the test models first.', this.strArtifact));
    
    % Load Testmodel, MXAM would use 'open_system' otherwise, which takes too much time
    % this.applyFixture(this.strArtifact);
                        
end
