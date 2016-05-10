function pbrtNode = rtbMexximpCameraToMPbrt(scene, camera, varargin)
%% Convert a mexximp camera to mPbrt transformation and Camera elements.
%
% pbrtNode = rtbMexximpCameraToMPbrt(scene, camera) converts the given
% mexximp camera to create an mPbrt scene Camera element and
% associated transformations.
%
% The given camera should be an element with type "cameras" as
% returned from mexximpSceneElements().
%
% By default, the camera will have type "perspective".  This may be
% overidden by passing the 'cameraType' parameter.  For example:
%   mexximpCameraToMPbrt( ... 'cameraType', 'orthographic');
%
% Returns an MPbrtElement with identifier Camera and parameters
% filled in based on the mexximp camera.
%
% pbrtNode = rtbMexximpCameraToMPbrt(scene, camera, varargin)
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
pbrtName = mexximpCleanName(cameraName, cameraIndex);

%% Dig out and convert parameter values.
internal = mPathGet(scene, camera.path);

% x-field of view in degrees
%   nominally, Assimp camera horizontalFov is the half-field-of-view
%   but it seems to behave like the full field of view.  Assimp bug?
xFov = internal.horizontalFov * 180 / pi();

% PBRT "fov" refers to the shorter image dimension
if internal.aspectRatio < 1
    % fov is xfov
    fov = xFov;
else
    % fov is yfov, scale opposite leg of a right triangle by aspect ratio
    fov = 2 * atand(tand(xFov ./ 2) ./ internal.aspectRatio);
end


% default camera orientation
internalTarget = internal.position + internal.lookAtDirection;
internalLookAt = [internal.position; internalTarget; internal.upDirection];
if 9 ~= numel(internalLookAt)
    internalLookAt = [0 0 0 0 0 -1 0 1 0];
end

% camera position in the scene
nameQuery = {'name', mexximpStringMatcher(camera.name)};
transformPath = cat(2, {'rootNode', 'children', nameQuery, 'transformation'});
externalTransform = mPathGet(scene, transformPath)';
if isempty(externalTransform)
    externalTransform = mexximpIdentity();
end

% invert the camera transformation to get point of view
externalTransform = inv(externalTransform);

%% Build the pbrt camera and associated transforms.
pbrtCamera = MPbrtElement('Camera', ...
    'name', pbrtName, ...
    'type', cameraType);
pbrtCamera.setParameter('fov', 'float', fov);

pbrtInternalLookAt = MPbrtElement.transformation('LookAt', internalLookAt, ...
    'comment', 'camera default orientation');

pbrtSceneTransform = MPbrtElement.transformation('ConcatTransform', externalTransform, ...
    'comment', 'camera scene position');

pbrtNode = MPbrtContainer('', 'indent', '');
pbrtNode.append(pbrtInternalLookAt);
pbrtNode.append(pbrtSceneTransform);
pbrtNode.append(pbrtCamera);
