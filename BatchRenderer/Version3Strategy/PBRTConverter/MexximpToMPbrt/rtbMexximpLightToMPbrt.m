function pbrtNode = rtbMexximpLightToMPbrt(scene, light, varargin)
%% Convert a mexximp light to mPbrt transformation and LightSource elements.
%
% pbrtNode = rtbMexximpLightToMPbrt(scene, light) converts the given
% mexximp light to an mPbrt scene LightSource element and
% associated transformations.
%
% The given light should be an element with type "lights" as
% returned from mexximpSceneElements().
%
% Returns an MPbrtElement with identifier LightSource and parameters
% filled in based on the mexximp light.
%
% pbrtNode = rtbMexximpLightToMPbrt(scene, light, varargin)
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
pbrtName = mexximpCleanName(lightName, lightIndex);

%% Dig out and convert transformations.
internal = mPathGet(scene, light.path);

% light position in the scene
nameQuery = {'name', mexximpStringMatcher(light.name)};
transformPath = cat(2, {'rootNode', 'children', nameQuery, 'transformation'});
externalTransform = mPathGet(scene, transformPath)';
if isempty(externalTransform)
    externalTransform = mexximpIdentity();
end

%% Build the pbrt light and associated transform.
pbrtLight = MPbrtElement('LightSource', 'name', pbrtName);

pbrtSceneTransform = MPbrtElement.transformation('ConcatTransform', externalTransform);

pbrtNode = MPbrtContainer('Attribute');
pbrtNode.append(pbrtSceneTransform);
pbrtNode.append(pbrtLight);

%% Fill in type-specific parameter values.
switch internal.type
    case 'directional'
        pbrtLight.type = 'distant';
        pbrtLight.setParameter('L', 'rgb', internal.diffuseColor);
        pbrtLight.setParameter('from', 'point', [0 0 0]);
        pbrtLight.setParameter('to', 'point', internal.lookAtDirection);
        
    case 'point'
        pbrtLight.type = 'point';
        pbrtLight.setParameter('I', 'rgb', internal.diffuseColor);
        pbrtLight.setParameter('from', 'point', [0 0 0]);
        
    case 'spot'
        pbrtLight.type = 'spot';
        pbrtLight.setParameter('I', 'rgb', internal.diffuseColor);
        pbrtLight.setParameter('from', 'point', [0 0 0]);
        pbrtLight.setParameter('to', 'point', internal.lookAtDirection);
        
        outerAngle = internal.outerConeAngle * 180 / pi();
        innerAngle = internal.innerConeAngle * 180 / pi();
        deltaAngle = outerAngle - innerAngle;
        pbrtLight.setParameter('coneangle', 'float', innerAngle);
        pbrtLight.setParameter('conedeltaangle', 'float', deltaAngle);
        
end
