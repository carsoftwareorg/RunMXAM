%% mcheck_cariad_bs_1001 - Ports must be labeled
%
% OUTPUT:
% =======
% result    - check summary(passed/failed/error messages)
% cr_items  - list of individual results of checked items
% r_stats   - struct with statistic s on the check result
% for details use 'open mes_check_info'
%
% INPUT:
% ======
% system    - model/subsystem to be checked
% cmd_s     - check options, syntax /<key>:<val>, 
% for details use 'open mes_check_info'
%
% REFERENCED GUIDELINE:
% =====================
% Reference:
% mcheck_cariad_bs_1001
%
% DESCRIPTION:
% ============
% It is checked whether the Cariad branding is applied to the blockset blocks.
%
% PASS/FAIL CRITERIA:
% ===================
% Fail: The IconOpaque mask property must have the value 'opaque-with-ports'
%
% SOLUTION:
% =========
% [What to do if a fail is returned]
%
% FIX OPERATION:
% ==============
% No automatic fix available
%
% CHECK PARAMETERS:
% =================
% No parameters are used.
%
% NOTE:
% =====
% [everything else, the user should know]
%
% PUBLIC INFORMATION
% *************************************************************************
% Copyright:    2022 Cariad
% Date:         $Date: $
% Revision:     $Rev: $
% *************************************************************************

% PRIVAT DOCUMENTATION
% -------------------------------------------------------------------------
% Author: [Your name] ([your.mail])
% $Id: $
% -------------------------------------------------------------------------
%
% CHECK HISTORY 
% =============
% [Bug fixes, big changes, format: YYYY/MM/DD (your initials): Message]
%
%% IMPLEMENTATION
function [result,cr_items,r_stats] = mes_mcheck_cariad_bs_1001(system,cmd_s)
%% STEP 1: Getting check info (assumes that check description is available)
[reg,s_regerr] = mxam_getCheckInfoFromDB('mcheck_cariad_bs_1000');
% Add custom information to the check info structure
reg.date            = '2022-01-27';
reg.filename        = mfilename;
reg.fixAllOnly      = 'yes'; % check does not support interactive fixing

%% STEP 2: Pre-processing: Validate input arguments and initialize variables
d_nargin = nargin;
mes_preprocess
if done == 1
    return
end
try
    %% STEP 3: Begin of custom check implementation
    % Get all blocks
    cs_blocks = find_system(model_name, ...
        'LookUnderMasks',   lookundermasks,...
        'FollowLinks',      followlinks,...
        'Type',             'block');
    
    %% STEP 4: Peri-processing: Apply ignorelist, global check parameters and update statistics.
    [cs_blocks,r_stats] = mes_periprocess(cs_blocks,r_peri_ops);
    
    %% STEP 5 : Check and/or repair blocks
    % define default fields for check item struct, returned by this check
    defaultItem = struct('result','failed','qualifier','block','linkaction','hilite');
    % loop over all blocks
    for ix = 1 : numel(cs_blocks)      
        hBlock = get_param(cs_blocks{ix},'Handle'); % the current block
        refBlock = get_param(hBlock, 'ReferenceBlock');
        if isempty(refBlock) || ~startsWith(refBlock, 'MinimalBlockset')
            continue
        end

        % get mask object
        objMask = Simulink.Mask.get(refBlock);
        
        % block must be masked
        if isempty(objMask)
            % build check item structure for current rule violation:
            r_item = mxam_newcritem(defaultItem, ...
                'message', 'The block must be masked.', ...
                'handle', hBlock, ...
                'path', mes_cleanpathname(hBlock), ...
                'name', mes_cleanName(hBlock));
            cr_items{end+1} = r_item; % add new check item to result list
        end

        % check IconOpaque property, must be 'opaque-with-ports'
        if ~strcmp(objMask.IconOpaque, 'opaque-with-ports')
            % build check item structure for current rule violation:
            r_item = mxam_newcritem(defaultItem,...
                'message', 'The property IconOpaque must be ''opaque-with-ports''.', ...
                'handle', hBlock, ...
                'path', mes_cleanpathname(hBlock), ...
                'name', mes_cleanName(hBlock));
            cr_items{end+1} = r_item; % add new check item to result list
            continue
        end
        
    end
    %% STEP 6: Post-processing: statistics and clean-up
    mes_postprocess % inline code used by all checks  
catch ME_Check
    % If an error occurs during check execution report this in the catch block.
    result = ['Error in ' reg.filename ': ', mes_shortErrorLocationString(ME_Check,true)]; % return error message
    mes_postprocess % but do postprocessing before returning
end
end