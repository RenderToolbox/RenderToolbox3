function mitsubaScene = rtbMexximpToMitsuba(mexximpScene, varargin)
%% Convert a mexximp scene struct to an mMitsuba scene object.
%
% mitsubaScene = rtbMexximpToMitsuba(mexximpScene) converts the given
% mexximpScene struct to an mMitsuba scene object suitable for modifying,
% writing to file, rendering, etc.
%
% This function forwards any named parameters to various helper functions,
% including:
%   - mexximpCameraToMMitsuba()
%   - mexximpLightToMMitsuba()
%   - mexximpMaterialToMMitsuba()
%   - mexximpMeshToMMitsuba()
%   - mexximpNodeToMMitsuba()
% Please see these functions documentation about what parameters they
% accept.  (Sorry not to reproduce all of this this parameter documentation
% here. It would be handy for a while, but it would probably go out of
% date.)
%
% Returns an mMitsuba scene object based on the given mexximpScene struct.
%
% mitsubaScene = rtbMexximpToMitsuba(mexximpScene, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('mexximpScene', @isstruct);
parser.parse(mexximpScene);
mexximpScene = parser.Results.mexximpScene;

%% Fresh scene to add to.
mitsubaScene = MMitsubaElement.scene();

%% Camera and POV transformations.
elements = mexximpSceneElements(mexximpScene);
elementTypes = {elements.type};
cameraInds = find(strcmp('cameras', elementTypes));
for cc = cameraInds
    mitsubaNode = mexximpCameraToMMitsuba(mexximpScene, elements(cc), varargin{:});
    mitsubaScene.append(mitsubaNode);
end

%% bsdf for each material.
%   Invoked by ref from shapes below.
materialInds = find(strcmp('materials', elementTypes));
nMaterials = numel(materialInds);
materialIds = cell(1, nMaterials);
for mm = 1:nMaterials
    mitsubaNode = mexximpMaterialToMMitsuba(mexximpScene, elements(materialInds(mm)), varargin{:});
    mitsubaScene.append(mitsubaNode);
    materialIds{mm} = mitsubaNode.id;
end

%% Emitters and toWorld transformations.
lightInds = find(strcmp('lights', elementTypes));
for ll = lightInds
    mitsubaNode = mexximpLightToMMitsuba(mexximpScene, elements(ll), varargin{:});
    mitsubaScene.append(mitsubaNode);
end

%% PLY file for each mesh.
%   Invoked by filename from shapes below.
meshInds = find(strcmp('meshes', elementTypes));
nMeshes = numel(meshInds);
meshFiles = cell(1, nMeshes);
for mm = 1:nMeshes
    [~, meshFiles{mm}] = mexximpMeshToMMitsuba(mexximpScene, elements(meshInds(mm)), varargin{:});
end

% PLY shape element for each node.
nodeInds = find(strcmp('nodes', elementTypes));
for nn = nodeInds
    mitsubaNodes = mexximpNodeToMMitsuba(mexximpScene, elements(nn), meshFiles, materialIds, varargin{:});
    
    % skip nodes that don't invoke any mesh objects
    for oo = 1:numel(mitsubaNodes)
        mitsubaScene.append(mitsubaNodes{oo});
    end
end
