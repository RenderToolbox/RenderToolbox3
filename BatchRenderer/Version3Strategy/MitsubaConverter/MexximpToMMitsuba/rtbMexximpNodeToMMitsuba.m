function mitsubaNodes = rtbMexximpNodeToMMitsuba(scene, node, meshFiles, materialIds, varargin)
%% Convert a mexximp nodes to Mitsuba ply shape elements.
%
% mitsubaNodes = rtbMexximpNodeToMMitsuba(scene, node, meshFiles) converts the
% given mexximp node to zero or more mMitsuba ply shape elements, each of
% which includes the node's transformation, the name of one of the ply
% files in the given meshFiles, and a reference to the bsdf that represents
% the node's material.
%
% Returns a cell array of MMitsuba elements, each of which contains
% the node's transformation and invokes the node's ply mesh and bsdf
% material.
%
% mitsubaNodes = rtbMexximpNodeToMMitsuba(scene, node, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('scene', @isstruct);
parser.addRequired('node', @isstruct);
parser.addRequired('meshFiles', @iscell);
parser.addRequired('materialIds', @iscell);
parser.parse(scene, node, meshFiles, materialIds, varargin{:});
scene = parser.Results.scene;
node = parser.Results.node;
meshFiles = parser.Results.meshFiles;
materialIds = parser.Results.materialIds;

%% Dig out the name.
nodeName = node.name;
nodeIndex = node.path{end};
mitsubaId = mexximpCleanName(nodeName, nodeIndex);

%% Follow 0-based indices to instantiated meshes.
data = mPathGet(scene, node.path);
nObjects = numel(data.meshIndices);
mitsubaNodes = cell(1, nObjects);
meshIndices = data.meshIndices + 1;
for oo = 1:nObjects
    meshIndex = meshIndices(oo);
    meshName = mexximpCleanName(scene.meshes(meshIndex).name, meshIndex);
    
    % unique instantiation of a mesh
    shapeId = [mitsubaId '_' meshName];
    shape = MMitsubaElement(shapeId, 'shape', 'ply');
    mitsubaNodes{oo} = shape;
    
    % follow 0-based index to ply file name
    shape.append(MMitsubaProperty.withValue('filename', 'string', meshFiles{meshIndex}));
    
    % follow 0-based index to material and bsdf id
    materialIndex = 1 + scene.meshes(meshIndex).materialIndex;
    shape.append(MMitsubaProperty.withData('', 'ref', 'id', materialIds{materialIndex}));
    
    % transform
    nodeTransform = data.transformation;
    shape.append(MMitsubaProperty.withNested('toWorld', 'transform', 'matrix', ...
        'value', nodeTransform(:)'));
end
