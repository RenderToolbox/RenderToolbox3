function mitsubaNode = rtbMexximpLightToMMitsuba(scene, light, varargin)
%% Convert a mexximp light to an mMitsuba emitter element.
%
% mitsubaNode = rtbMexximpLightToMMitsuba(scene, light) converts the given
% mexximp light to an mMitsuba emitter element.
%
% The given light should be an element with type "lights" as
% returned from mexximpSceneElements().
%
% Returns an MMitsubaElement with type emitter and parameters
% filled in based on the mexximp light.
%
% mitsubaNode = rtbMexximpLightToMMitsuba(scene, light, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('scene', @isstruct);
parser.addRequired('light', @isstruct);
parser.parse(scene, light, varargin{:});
scene = parser.Results.scene;
light = parser.Results.light;

%% Dig out the name.
lightName = light.name;
lightIndex = light.path{end};
mitsubaId = mexximpCleanName(lightName, lightIndex);

%% Dig out and convert transformations.
internal = mPathGet(scene, light.path);

% light internal orientation
internalDirection = internal.lookAtDirection';
if all(0 == internalDirection)
    internalDirection = [0 0 1];
end

% light position in the scene
nameQuery = {'name', mexximpStringMatcher(light.name)};
transformPath = cat(2, {'rootNode', 'children', nameQuery, 'transformation'});
externalTransform = mPathGet(scene, transformPath);
if isempty(externalTransform)
    externalTransform = mexximpIdentity();
end

%% Build an emitter with type-specific parameter values.
switch internal.type
    case 'directional'
        mitsubaNode = MMitsubaElement(mitsubaId, 'emitter', 'directional');
        mitsubaNode.append(MMitsubaProperty.withValue('irradiance', 'rgb', internal.diffuseColor'));
        
    case 'point'
        mitsubaNode = MMitsubaElement(mitsubaId, 'emitter', 'point');
        mitsubaNode.append(MMitsubaProperty.withValue('intensity', 'rgb', internal.diffuseColor'));
        
    case 'spot'
        mitsubaNode = MMitsubaElement(mitsubaId, 'emitter', 'spot');
        mitsubaNode.append(MMitsubaProperty.withValue('intensity', 'rgb', internal.diffuseColor'));
        
        outerAngle = internal.outerConeAngle * 180 / pi();
        innerAngle = internal.innerConeAngle * 180 / pi();
        mitsubaNode.append(MMitsubaProperty.withValue('beamWidth', 'float', innerAngle));
        mitsubaNode.append(MMitsubaProperty.withValue('cutoffAngle', 'float', outerAngle));
end

%% Add the inner orientation and world transformation.
toWorld = MMitsubaProperty('toWorld', 'transform');
toWorld.append(MMitsubaProperty.withData('', 'lookat', ...
    'origin', [0 0 0], ...
    'target', internalDirection, ...
    'up', [0 1 0]));
toWorld.append(MMitsubaProperty.withValue('', 'matrix', externalTransform(:)'));
mitsubaNode.append(toWorld);
