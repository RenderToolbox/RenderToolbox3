function mitsubaNode = rtbMexximpCameraToMMitsuba(scene, camera, varargin)
%% Convert a mexximp camera to mMitsuba sensor element.
%
% mitsubaNode = rtbMexximpCameraToMMitsuba(scene, camera) converts the given
% mexximp camera to create an mMitsuba sensor element and
% associated transformations.
%
% The given camera should be an element with type "cameras" as
% returned from mexximpSceneElements().
%
% By default, the camera will have type "perspective".  This may be
% overidden by passing the 'cameraType' parameter.  For example:
%   rtbMexximpCameraToMMitsuba( ... 'cameraType', 'orthographic');
%
% Returns an mMitsuba sensor element with type camera and parameters
% filled in based on the mexximp camera.
%
% mitsubaNode = rtbMexximpCameraToMMitsuba(scene, camera, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('scene', @isstruct);
parser.addRequired('camera', @isstruct);
parser.addParameter('cameraType', 'perspective', @ischar);
parser.parse(scene, camera, varargin{:});
scene = parser.Results.scene;
camera = parser.Results.camera;
cameraType = parser.Results.cameraType;

%% Dig out the name.
cameraName = camera.name;
cameraIndex = camera.path{end};
mitsubaId = mexximpCleanName(cameraName, cameraIndex);

%% Dig out and convert parameter values.
internal = mPathGet(scene, camera.path);

% x-field of view in degrees
%   nominally, Assimp camera horizontalFov is the half-field-of-view
%   but it seems to behave like the full field of view.  Assimp bug?
xFov = internal.horizontalFov * 180 / pi();

% camera initial orientation
internalOrigin = internal.position';
internalTarget = internal.position' + internal.lookAtDirection';
internalUp = internal.upDirection';

% camera position in the scene
nameQuery = {'name', mexximpStringMatcher(camera.name)};
transformPath = cat(2, {'rootNode', 'children', nameQuery, 'transformation'});
externalTransform = mPathGet(scene, transformPath);
if isempty(externalTransform)
    externalTransform = mexximpIdentity();
end

% flip the x-axis for our convention
externalTransform = mexximpScale([-1 1 1]) * externalTransform;

%% Build the mitsuba camera and associated transforms.
mitsubaNode = MMitsubaElement(mitsubaId, 'sensor', cameraType);
mitsubaNode.append(MMitsubaProperty.withValue('fov', 'float', xFov));
mitsubaNode.append(MMitsubaProperty.withValue('fovAxis', 'string', 'x'));

toWorld = MMitsubaProperty('toWorld', 'transform');
toWorld.append(MMitsubaProperty.withData('', 'lookat', ...
    'origin', internalOrigin, ...
    'target', internalTarget, ...
    'up', internalUp));
toWorld.append(MMitsubaProperty.withValue('', 'matrix', externalTransform(:)'));
mitsubaNode.append(toWorld);

%% Add some default nested elements expected by Mitsuba.
filter = MMitsubaElement('rfilter', 'rfilter', 'gaussian');
filter.append(MMitsubaProperty.withValue('stddev', 'float', 0.5));
film = MMitsubaElement('film', 'film', 'hdrfilm');
film.append(filter);
mitsubaNode.append(film);

sampler = MMitsubaElement('sampler', 'sampler', 'ldsampler');
sampler.append(MMitsubaProperty.withValue('sampleCount', 'integer', 8));
mitsubaNode.append(sampler);

