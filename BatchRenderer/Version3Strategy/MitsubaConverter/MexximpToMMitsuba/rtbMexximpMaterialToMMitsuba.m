function mitsubaNode = rtbMexximpMaterialToMMitsuba(scene, material, varargin)
%% Convert a mexximp material to an mMitsuba bsdf element.
%
% mitsubaNode = rtbMexximpMaterialToMMitsuba(scene, material) cherry picks
% material properties from the given mexximp material and scene and uses
% these to create an mMitsuba bsdf element.
%
% The given material should be an element with type "materials" as
% returned from mexximpSceneElements().
%
% The Assimp/mexximp material model is flexible, complicated, and messy.
% This function cherry picks from the given mexximp scene and material
% and ignores most material properties.  Only the following mexximp
% material properties are used (see mexximpConstants('materialPropertyKey'))':
%   - 'name'
%   - 'diffuse'
%   - 'specular'
%   - 'texture'
%
% By default, the new mitsuba bsdf will have pluginType "ward", diffuse
% parameter "diffuseReflectance" and specular parameter
% "specularReflectance".  These may be overidden by passing values for
% these named parameters.  For example:
%   mexximpMaterialToMPbrt( ...
%       'materialDefault', MMitsubaElement('', 'bsdf', 'diffuse'), ...
%       'materialDiffuseParameter', 'reflectance', ...
%       'materialSpecularParameter', '');
%
% Returns an MMitsubaNode with type 'bsdf' and parameters
% filled in based on mexximp material properties.
%
% mitsubaNode = rtbMexximpMaterialToMMitsuba(scene, material, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.KeepUnmatched = true;
parser.addRequired('scene', @isstruct);
parser.addRequired('material', @isstruct);
parser.addParameter('materialDefault', MMitsubaElement('', 'bsdf', 'diffuse'), @isobject);
parser.addParameter('materialDiffuseParameter', 'diffuseReflectance', @ischar);
parser.addParameter('materialSpecularParameter', 'specularReflectance', @ischar);
parser.parse(scene, material, varargin{:});
scene = parser.Results.scene;
material = parser.Results.material;
materialDefault = parser.Results.materialDefault;
materialDiffuseParameter = parser.Results.materialDiffuseParameter;
materialSpecularParameter = parser.Results.materialSpecularParameter;

%% Dig out the material name.
materialName = material.name;
materialIndex = material.path{end};
mitsubaId = mexximpCleanName(materialName, materialIndex);

%% Dig out diffuse and specular rgb and texture values.
properties = mPathGet(scene, cat(2, material.path, {'properties'}));
diffuseRgb = queryProperties(properties, 'key', 'diffuse', 'data', []);
specularRgb = queryProperties(properties, 'key', 'specular', 'data', []);
diffuseTexture = queryProperties(properties, 'textureSemantic', 'diffuse', 'data', '');
specularTexture = queryProperties(properties, 'textureSemantic', 'specular', 'data', '');

%% Build the mitsuba material.
mitsubaNode = materialDefault.copy();
mitsubaNode.id = mitsubaId;

diffuseNode = mitsubaNode.find(materialDiffuseParameter);
if ~isempty(materialDiffuseParameter) && ~isempty(diffuseNode)
    if ~isempty(diffuseTexture)
        diffuseNode.type = 'texture';
        diffuseNode.data = struct('type', 'bitmap');
        diffuseNode.append(MMitsubaProperty.withValue('filename', 'string', diffuseTexture));
    elseif ~isempty(diffuseRgb)
        diffuseNode.type = 'rgb';
        diffuseNode.data.value = diffuseRgb(1:3);
    end
end

specularNode = mitsubaNode.find(materialSpecularParameter);
if ~isempty(materialSpecularParameter) && ~isempty(specularNode)
    if ~isempty(specularTexture)
        specularNode.type = 'texture';
        specularNode.data = struct('type', 'bitmap');
        specularNode.append(MMitsubaProperty.withValue('filename', 'string', specularTexture));
    elseif ~isempty(specularRgb)
        specularNode.type = 'rgb';
        specularNode.data.value = specularRgb(1:3);
    end
end

%% Query a material property, return default if no good match.
function result = queryProperties(properties, queryField, queryValue, resultField, defaultResult)
query = {queryField, mexximpStringMatcher(queryValue)};
[resultIndex, resultScore] = mPathQuery(properties, query);
if 1 == resultScore
    result = properties(resultIndex).(resultField);
else
    result = defaultResult;
end
