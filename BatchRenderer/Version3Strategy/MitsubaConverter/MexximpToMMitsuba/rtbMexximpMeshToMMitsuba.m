function [plyFile, plyRelativePath] = rtbMexximpMeshToMMitsuba(scene, mesh, varargin)
%% Convert a mexximp mesh to a PLY file that we can pass to Mitsuba.
%
% plyFile = rtbMexximpMeshToMMitsuba(scene, mesh) converts the given mexximp
% mesh to a Stanford Triangle Format (PLY) file that we can pass to
% Mitsuba.
%
% The given mesh should be an element with type "meshes" as
% returned from mexximpSceneElements().  Only the following mesh fields are
% converted:
%   - name
%   - materialIndex
%   - vertices
%   - faces
%   - normals
%   - textureCoordinates0
%
% The actual vertex data for the given mesh will be written to a PLY file.
%
% rtbMexximpMeshToMMitsuba( ... 'workingFolder', workingFolder) specify the
% folder where PLY file will be written.  The default is pwd().
%
% rtbMexximpMeshToMMitsuba( ... 'meshSubfolder', meshSubfolder) specify the
% sub-folder of the workingFolder where the PLY file will be written.
% The default is 'mitsuba-geometry'.  The Mitsuba PLY plugin will use a
% relative path which incorporates the meshSubfolder, but not the
% workingFolder.
%
% rtbMexximpMeshToMMitsuba( ... 'rewriteMeshData', rewriteMeshData)
% choose whether to overwrite an existing PLY file if it exists (true),
% or to skip over existing files with the same name.  The default is true,
% always write fresh PLY files.  Setting rewriteMeshData to false may
% save time for large meshes, at the risk of letting the PLY files go
% out of date.
%
% Returns an a file name for the new PLY file that was written.  Also
% returns a relative path to the PLY file that PLYs the meshSubfolder
% but omits the meshSubfolder
%
% [plyFile, plyRelativePath] = rtbMexximpMeshToMMitsuba(scene, mesh, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('scene', @isstruct);
parser.addRequired('mesh', @isstruct);
parser.addParameter('workingFolder', pwd(), @ischar);
parser.addParameter('meshSubfolder', 'mitsuba-geometry', @ischar);
parser.addParameter('rewriteMeshData', true, @islogical);
parser.parse(scene, mesh, varargin{:});
scene = parser.Results.scene;
mesh = parser.Results.mesh;
workingFolder = parser.Results.workingFolder;
meshSubfolder = parser.Results.meshSubfolder;
rewriteMeshData = parser.Results.rewriteMeshData;

%% Dig out the name.
meshName = mesh.name;
meshIndex = mesh.path{end};
mitsubaId = mexximpCleanName(meshName, meshIndex);

% build the PLY folder and file names
plyRelativePath = fullfile(meshSubfolder, [mitsubaId '.ply']);
plyFile = fullfile(workingFolder, plyRelativePath);
plyFolder = fullfile(workingFolder, meshSubfolder);

%% Build up mesh data to send to a PLY file.
data = mPathGet(scene, mesh.path);

% required xyz and face data
xyz = data.vertices;
faces = cat(1, data.faces.indices)';

% more optional args
plyArgs = {};

if ~isempty(data.normals)
    plyArgs = cat(2, {'normals', data.normals});
end

if ~isempty(data.textureCoordinates0)
    % only use the first set of texture coordinates
    % always assume 2 uv components (no uvw)
    uvs = data.textureCoordinates0(1:2, :);
    plyArgs = cat(2, {'uvs', uvs});
end

if ~isempty(data.colors0)
    rgbs = data.colors0(1:3, :);
    plyArgs = cat(2, {'colors', rgbs});
end


%% If necessary, write the PLY file.
if 2 == exist(plyFile, 'file') && ~rewriteMeshData
    % use an existing PLY file
    return;
end

% need a folder to land in
if 7 ~= exist(plyFolder, 'dir')
    mkdir(plyFolder);
end

mexximpWriteTriangleMeshPly(plyFile, xyz, faces, ...
    'format', 'binary_little_endian', ...
    plyArgs{:});
