function pbrtNodes = rtbMexximpNodeToMPbrt(scene, node, varargin)
%% Convert a mexximp node to mPbrt ObjectInstances and transformations.
%
% pbrtNodes = rtbMexximpNodeToMPbrt(scene, node, varargin) converts the given
% mexximp node to zero or more mPbrt Attribute containers, each of which
% includes the node's transformation and an ObjectInstance for one of the
% node's meshIndices.
%
% Returns a cell array of Attribute MPbrtContainers, each of which contains
% the node's transformation and one an ObjectInstance elements.
%
% pbrtNodes = rtbMexximpNodeToMPbrt(scene, node, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('scene', @isstruct);
parser.addRequired('node', @isstruct);
parser.parse(scene, node, varargin{:});
scene = parser.Results.scene;
node = parser.Results.node;

%% Dig out the name.
nodeName = node.name;
nodeIndex = node.path{end};
pbrtName = mexximpCleanName(nodeName, nodeIndex);

%% Add the node transformation to an Attribute.
data = mPathGet(scene, node.path);

%% Follow 0-based indices to instantiated meshes.
nObjects = numel(data.meshIndices);
pbrtNodes = cell(1, nObjects);
meshIndices = data.meshIndices + 1;
for oo = 1:nObjects
    meshIndex = meshIndices(oo);
    meshName = mexximpCleanName(scene.meshes(meshIndex).name, meshIndex);
    
    attribute = MPbrtContainer('Attribute', ...
        'name', meshName, ...
        'comment', ['from node ' pbrtName]);
    transformation = MPbrtElement.transformation('ConcatTransform', data.transformation');
    attribute.append(transformation);
    
    objectInstance = MPbrtElement('ObjectInstance', 'value', meshName);
    attribute.append(objectInstance);
    
    pbrtNodes{oo} = attribute;
end
