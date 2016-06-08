% If the user would like to run PBRT with a docker container instead of
% local PBRT, this function should be called in the scene script. 
% The function first pulls docker and then sets the PBRT executable to be
% the docker run command, along with the correct input file paths. In
% RunPBRT.m, the docker run command is called instead of local PBRT.
%
% Note: The hints.copyResources command must be set to true for docker to
% run correctly, since it requires all resource files to be in the same
% folder.

function SetupPBRTDocker(hints)

% Check if docker is installed
s = system('which docker');

if s
    warning('Docker not found! \n (OSX) Are you sure you''re running MATLAB in a Docker Quickstart Terminal? ');
else
    
    % Initialize the docker container (docker pull)
    dHub = 'vistalab/pbrt';  % Docker container at dockerhub
    fprintf('Checking for most recent docker container\n');
    system(sprintf('docker pull %s',dHub));
   
    % Note:
    % In the past we would use the command:
    % docker run -t -i --rm -v   [directory]:/data
    % Now instead of using the "/data" folder, we have:
    % docker run -t -i --rm -v   [directory]:[directory]
    % Although copying the entire folder structure into the container is
    % redundant, it allows us to have one RunPBRT command that is compatible
    % with both native PBRT and docker PBRT. This way, we don't have to change
    % the names of the "output" and "sceneCopy" inputs in RunPBRT.m
    
    workingFolder = GetWorkingFolder('', false, hints);
    name = sprintf('docker run -t -i --rm -v %s:%s vistalab/pbrt pbrt',workingFolder,workingFolder);
    setpref('PBRT','executable',name);
    
    fprintf('\nPBRT executable set to docker container.\n\n')

end

end