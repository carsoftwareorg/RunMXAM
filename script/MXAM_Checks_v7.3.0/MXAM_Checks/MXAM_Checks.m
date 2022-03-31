classdef MXAM_Checks < handle
    %Start the ProjectHelper MT4 extension toolbox.
    properties
        strToolboxName char = 'MXAM_Checks'
        strInstallDir char
        avCheckSetsPath 
    end
    
    methods
        function [this] = MXAM_Checks()
            this.strInstallDir = fileparts(mfilename('fullpath')); % abstracted
            this.avCheckSetsPath.hcp1_chassis_floatingpoint_FE = '\projects\ef8\HCP1\hcp1_chassis_floatingpoint_FE.mxmp';
            this.avCheckSetsPath.hcp1_chassis_floatingpoint_CG = '\projects\ef8\HCP1\hcp1_chassis_floatingpoint_CG.mxmp';
            this.avCheckSetsPath.hcp1_chassis_floatingpoint = '\projects\ef8\HCP1\hcp1_chassis_floatingpoint.mxmp';
            this.avCheckSetsPath.hcp1_chassis_fixpoint = '\projects\ef8\HCP1\hcp1_chassis_fixpoint.mxmp';
            this.avCheckSetsPath.EFP_floatingpoint = '\projects\ef8\EFP\EFP_floatingpoint.mxmp';
            this.avCheckSetsPath.EFP_floatingpoint_ignored_CDS = '\projects\ef8\EFP\EFP_floatingpoint_ignored_CDS.mxmp';
            this.avCheckSetsPath.EFP_fixpoint = '\projects\ef8\EFP\EFP_fixpoint.mxmp';
            this.avCheckSetsPath.EFP_fixpoint_ignored_CDS = '\projects\ef8\EFP\EFP_fixpoint_ignored_CDS.mxmp';
        end
    end
    
    methods(Static)
        function Start()
            %Start the emcode toolbox
            oThis = MXAM_Checks();   
            strPackageDir = fullfile(oThis.strInstallDir, oThis.strToolboxName);

%             if exist('MXAM_Drive')
%                 obj_check = MXAM_Drive();
%                 struct_Obj_info = ver(obj_check.strToolboxName);
% 				correct_Ver_Check = '7.3.0';
%                 all_Versions = EnProVeManager_getSelectedVersion;
%                 if ~isempty(obj_check)
%                     if max(ismember(all_Versions,['MXAM_Drive/',correct_Ver_Check])) > 0
%                         if ~isequal(struct_Obj_info.Version,correct_Ver_Check)
%                             fprintf(2,'Toolbox %s is not compatible with Toolbox %s Version %s! Use instead %s %s \n', ...
%                                 oThis.strToolboxName, obj_check.strToolboxName, struct_Obj_info.Version, obj_check.strToolboxName, correct_Ver_Check);
%                         end
%                     else
%                         fprintf(2,'Toolbox %s is not compatible with Toolbox %s Version %s! Need to install %s %s \n', ...
%                             oThis.strToolboxName, obj_check.strToolboxName, struct_Obj_info.Version, obj_check.strToolboxName, correct_Ver_Check);
%                     end
%                 end
%             else
%                 fprintf(2,"Warning: no mxam_drive, so you can't use mxam checksets!\n");
%             end
% 
            assert(isempty(ver(oThis.strToolboxName)),  ...
                'Toolbox (%s) is already active! Deactivate with <a href="matlab:%s.Shutdown();">%s.Shutdown</a>', ...
                oThis.strToolboxName, mfilename, mfilename);
            
            addpath(genpath(oThis.strInstallDir));
            if exist(fullfile(strPackageDir), 'dir') % release version structure (product-package)
                addpath(strPackageDir);
            end
			
        end
        
        function Shutdown()
            oThis = MXAM_Checks();       
            if isempty(ver(oThis.strToolboxName))
                return
            end
            
            if ~isempty(findobj('type', 'figure', 'Name', 'PrjHelper'))
                close(findobj('type', 'figure', 'Name', 'PrjHelper'));
            end
            
            % remove all pathesastrPaths = regexp(path, pathsep, 'split');
            astrPaths = regexp(path, pathsep, 'split');
            astrTbPaths = {...
                oThis.strInstallDir, ...
                fullfile(oThis.strInstallDir, oThis.strToolboxName), ...
                };
            for strPath = astrTbPaths
                strPath = strPath{:}; %#ok<FXSET>
                
                if ismember(strPath, astrPaths)
                    rmpath(strPath);
                end
            end
        end
    end
end
