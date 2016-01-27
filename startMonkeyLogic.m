function startMonkeyLogic(varargin)

% July 2104, Updated Jan 2016 for "gitMonkeyLogicRy"
% MAC

% check that matlab has been launched in java
if  ~usejava('jvm')
    error('Must run MATLAB with Java enabled')
end

% check that matlab has been launched as admin
if ~isWindowsAdmin
    error('Must run MATLAB as administrator for DAQ. Quit MATLAB and re-run as administrator.')
end

if nargin < 1
    ML_ver = '';
elseif nargin == 1
    ML_ver = varargin{1};
end

% remove any prexisting MonkeyLogic folders from search path
splitPath = regexp(path,'C:','split');
for folderIDX = 1:size(splitPath, 2)
    if ~isempty(findstr(splitPath{folderIDX}, 'MonkeyLogic'))
        rmpath(strcat('C:',splitPath{folderIDX}));
    end
end

% get current directory which should contain ML versions and Tasks
ML_folder = pwd;
Tasks_folder = [ML_folder, filesep, 'MonkeyLogic', ML_ver, filesep 'Tasks', filesep];
Utils_folder = [ML_folder, filesep, 'UTILS', filesep];

% put monkeylogic on path
addpath(genpath(sprintf('%s\\MonkeyLogic%s',ML_folder,ML_ver)));
% remove subdirectory "tasks" and "docs" 
rmpath(genpath(Tasks_folder));
rmpath(genpath([ML_folder, filesep, 'MonkeyLogic', ML_ver, filesep 'Docs', filesep]))
% add UTILS folder to path if it exists
if exist(Utils_folder,'dir') == 7
    addpath(Utils_folder);
end

% clear out runtime folder, yes do
runtimefiles = sprintf('%s\\MonkeyLogic%s\\runtime\\*.m',ML_folder,ML_ver);
delete(runtimefiles);

% force monkeylogic to reset runtime, task, and home directories
if ispref('MonkeyLogic')
    p = getpref('MonkeyLogic');
    LastTaskDir =  p.Directories.ExperimentDirectory;
    rmpref('MonkeyLogic');
    if exist(LastTaskDir,'dir') == 7
        success = set_ml_directories(LastTaskDir);
    else
        success = set_ml_directories(Tasks_folder);
    end
    if ~success
        error('MonkeyLogic prefrences not set as supplied')
    end
end



% the main event!
monkeylogic


function success = set_ml_directories(expdir)

success = 0;
d = which('monkeylogic');
if isempty(d),
    pname = uigetdir(pwd, 'Please indicate the location of the MonkeyLogic files...');
    if pname(1) == 0,
        return
    end
    addpath(pname);
else
    pname = fileparts(d);
end

basedir = [pname filesep];
runtimedir = [basedir 'runtime' filesep];

% check that supplied experiment directory exists
if exist(expdir,'dir') ~= 7;
    pname = uigetdir(basedir, 'Please select the experiment directory...');
    if pname(1) == 0,
        return
    end
    expdir = [pname filesep];
end

MLPrefs.Directories.BaseDirectory = basedir;
MLPrefs.Directories.RunTimeDirectory = runtimedir;
MLPrefs.Directories.ExperimentDirectory = expdir;
setpref('MonkeyLogic', 'Directories', MLPrefs.Directories);
if ispref('MonkeyLogic', 'Directories'),
    success = 1;
end

function tf = isWindowsAdmin()
%ISWINDOWSADMIN True if this user is in admin role.
wi = System.Security.Principal.WindowsIdentity.GetCurrent();
wp = System.Security.Principal.WindowsPrincipal(wi);
tf = wp.IsInRole(System.Security.Principal.WindowsBuiltInRole.Administrator);


