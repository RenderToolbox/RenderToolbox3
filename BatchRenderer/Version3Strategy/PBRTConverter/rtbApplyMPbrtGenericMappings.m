function pbrtScene = rtbApplyMPbrtGenericMappings(pbrtScene, mappings)
%% Apply mappings with the "Generic" destination directly to the scene.
%
% pbrtScene = rtbApplyMPbrtGenericMappings(pbrtScene, mappings) adjusts the
% given mPbrt pbrtScene in place, by applying the given Generic mappings as
% scene adjustments.
%
% This generally amounts to translating Generic type names and values to
% PBRT type names and values, locating scene elements of the scene object
% and updating their field values based on the mappings properties.
%
% pbrtScene = rtbApplyMPbrtGenericMappings(pbrtScene, mappings)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('pbrtScene', @isobject);
parser.addRequired('mappings', @isstruct);
parser.parse(pbrtScene, mappings);
pbrtScene = parser.Results.pbrtScene;
mappings = parser.Results.mappings;

%% Select only RenderToolbox3 "Generic" mappings.
isGeneric = strcmp('Generic', {mappings.destination});
genericMappings = mappings(isGeneric);
nGenericMappings = numel(genericMappings);

%% Update the scene, one mapping at a time.
for mm = 1:nGenericMappings
    
    %% Translate Generic type names to PBRT identifier names.
    %   this allows us to find mPbrtScene elements by PBRT identifier
    mapping = genericMappings(mm);
    switch mapping.broadType
        case 'meshes'
            identifier = 'Object';
        case 'lights'
            identifier = 'LightSource';
        case 'materials'
            identifier = 'MakeNamedMaterial';
        case {'floatTextures', 'spectrumTextures'}
            identifier = 'Texture';
        otherwise
            warning('applyMPbrtGenericMappings:invalidBroadType', ...
                'Unrecognized broadType <%s> for Generic mapping.', ...
                mapping.broadType);
            continue;
    end
    
    %% Create/find/delete a scene element.
    element = applyMPbrtMappingOperation(pbrtScene, mapping, ...
        'identifier', identifier);
    if isempty(element)
        continue;
    end
    
    %% Apply Generic mappings special operations.
    switch mapping.operation
        case 'blessAsAreaLight'
            % Turn an existing Object into an AreaLightSource
            %
            % We start with an Object declaration and invokation:
            % # 1_LightX
            % ObjectBegin "1_LightX"
            %	NamedMaterial "1_ReflectorMaterial"
            %	Include "pbrt-geometry/1_LightX.pbrt"
            % ObjectEnd
            % ...
            % # 1_LightX
            % AttributeBegin
            %	ConcatTransform [-0.500001 0.000000 -0.866025 0.000000 0.000000 1.000000 0.000000 0.000000 0.866025 0.000000 -0.500001 0.000000 -11.000000 0.000000 11.000000 1.000000]
            %	ObjectInstance "1_LightX"
            % AttributeEnd
            %
            % We combine these into one Attribute with an AreaLightSource:
            % AttributeBegin
            % 	ConcatTransform [-0.500001 0.000000 -0.866025 0.000000 0.000000 1.000000 0.000000 0.000000 0.866025 0.000000 -0.500001 0.000000 -11.000000 0.000000 11.000000 1.000000]
            %	AreaLightSource "diffuse"
            %       "spectrum L" "D65.spd"
            %       "integer nsamples" [8]
            %	NamedMaterial "1_ReflectorMaterial"
            %	Include "pbrt-geometry/1_LightX.pbrt"
            % AttributeEnd
            
            % remove the original object declaration
            object = pbrtScene.find('Object', ...
                'name', element.name, ...
                'remove', true);
            
            % locate the object instance attribute
            attribute = pbrtScene.find('Attribute', 'name', element.name);
            
            % remove the original ObjectInstance invokation
            attribute.find('ObjectInstance', ...
                'remove', true);
            
            % declare the AreaLightSource
            areaLight = MPbrtElement('AreaLightSource', ...
                'name', element.name, ...
                'type', 'diffuse');
            areaLight.setParameter('L', 'spectrum', ...
                getMappingProperty(mapping, 'intensity', '300:1 800:1'));
            areaLight.setParameter('nsamples', 'integer', 8);
            attribute.append(areaLight);
            
            % move over the original material
            material = object.find('NamedMaterial');
            attribute.append(material);
            
            % move over the original include file
            include = object.find('Include');
            attribute.append(include);
            
        case 'blessAsBumpMap'
            %% Turn an existing material into a bumpmap material.
            %
            % We start with a float imagemap texture and a material
            % # texture earthTexture
            % Texture "earthTexture" "float" "imagemap"
            %	"string filename" "earthbump1k-stretch-rgb.exr"
            %	"float gamma" [1]
            %	"float maxanisotropy" [20]
            %	"bool trilinear" "false"
            %	"float udelta" [0.0]
            %	"float uscale" [1.0]
            %	"float vdelta" [0.0]
            %	"float vscale" [1.0]
            %	"string wrap" "repeat"
            % ...
            % # material Material-material
            % MakeNamedMaterial "Material-material"
            %   "string type" "matte"
            %   "spectrum Kd" "mccBabel-11.spd"
            %
            % We enclose the texture in a "scale" texture so that we can
            % apply a scale factor.  Then we add this scale texture to the
            % existing material.  We also need to sort these elements
            % because they depend on each other.
            %
            % Texture "earthTexture" "float" "imagemap" ...
            %
            % Texture "earthBumpMap-scaled" "float" "scale"
            %    "texture tex1" "earthTexture"
            %    "float tex2" [0.1]
            %
            % # material Material-material
            % MakeNamedMaterial "Material-material"
            %    "string type" "matte"
            %    "spectrum Kd" "mccBabel-11.spd"
            %    "texture bumpmap" "earthBumpMap-scaled"
            
            % locate the original texture
            textureName = getMappingProperty(mapping, 'texture', '');
            originalTexture = pbrtScene.world.find('Texture', ...
                'name', textureName);
            
            % wrap the original texture in a new scale texture
            scaledTextureName = [originalTexture.name '_scaled'];
            scaleTexture = MPbrtElement.texture(scaledTextureName, 'float', 'scale');
            scaleTexture.setParameter('tex1', 'texture', originalTexture.name);
            scaleTexture.setParameter('tex2', 'float', ...
                getMappingProperty(mapping, 'scale', 1));
            pbrtScene.world.prepend(scaleTexture);
            
            % move textures to the front, in dependency order
            pbrtScene.world.prepend(scaleTexture);
            pbrtScene.world.prepend(originalTexture);
            
            % add the scale texture to the blessed material
            element.setParameter('bumpmap', 'texture', scaledTextureName);            
    end
    
    %% Apply Generic mappings properties as PBRT element parameters.
    switch mapping.broadType
        case 'materials'
            switch mapping.specificType
                case 'matte'
                    element.type = 'matte';
                    element.setParameter('Kd', 'spectrum', ...
                        getMappingProperty(mapping, 'diffuseReflectance', '300:0 800:0'));
                    
                case 'anisoward'
                    element.type = 'anisoward';
                    element.setParameter('Kd', 'spectrum', ...
                        getMappingProperty(mapping, 'diffuseReflectance', '300:0 800:0'));
                    element.setParameter('Ks', 'spectrum', ...
                        getMappingProperty(mapping, 'specularReflectance', '300:0 800:0'));
                    element.setParameter('alphaU', 'float', ...
                        getMappingProperty(mapping, 'alphaU', 0.15));
                    element.setParameter('alphaV', 'float', ...
                        getMappingProperty(mapping, 'alphaV', 0.15));
                    
                case 'metal'
                    element.type = 'metal';
                    element.setParameter('eta', 'spectrum', ...
                        getMappingProperty(mapping, 'eta', '300:0 800:0'));
                    element.setParameter('k', 'spectrum', ...
                        getMappingProperty(mapping, 'k', '300:0 800:0'));
                    element.setParameter('roughness', 'float', ...
                        getMappingProperty(mapping, 'roughness', .05) / 5);
            end
            
        case 'lights'
            switch mapping.specificType
                case {'point', 'spot'}
                    element.type = mapping.specificType;
                    element.setParameter('I', 'spectrum', ...
                        getMappingProperty(mapping, 'intensity', '300:0 800:0'));
                    
                case 'directional'
                    element.type = 'distant';
                    element.setParameter('L', 'spectrum', ...
                        getMappingProperty(mapping, 'intensity', '300:0 800:0'));
            end
            
        case {'floatTextures', 'spectrumTextures'}
            % texture name and pixel type declared in the element value
            if strcmp('spectrumTexture', mapping.broadType)
                pixelType = 'spectrum';
            else
                pixelType = 'float';
            end
            element.value = {element.name, pixelType};
            
            switch mapping.specificType
                case 'bitmap'
                    element.type = 'imagemap';
                    element.setParameter('filename', 'string', ...
                        getMappingProperty(mapping, 'filename', ''));
                    element.setParameter('gamma', 'float', ...
                        getMappingProperty(mapping, 'gamma', 1));
                    element.setParameter('maxanisotropy', 'float', ...
                        getMappingProperty(mapping, 'maxAnisotropy', 20));
                    element.setParameter('udelta', 'float', ...
                        getMappingProperty(mapping, 'offsetU', 0));
                    element.setParameter('vdelta', 'float', ...
                        getMappingProperty(mapping, 'offsetV', 0));
                    element.setParameter('uscale', 'float', ...
                        getMappingProperty(mapping, 'scaleU', 1));
                    element.setParameter('vscale', 'float', ...
                        getMappingProperty(mapping, 'scaleV', 1));
                    
                    wrap = getMappingProperty(mapping, 'wrapMode', 'repeat');
                    if strcmp('zero', wrap)
                        wrap = 'black';
                    end
                    element.setParameter('wrap', 'string', wrap);
                    
                    filterMode = getMappingProperty(mapping, 'filterMode', '');
                    isTrilinear = strcmp('trilinear', filterMode);
                    element.setParameter('trilinear', 'bool', isTrilinear);
                    
                case 'checkerboard'
                    element.type = 'checkerboard';
                    
                    element.setParameter('udelta', 'float', ...
                        getMappingProperty(mapping, 'offsetU', 0));
                    element.setParameter('vdelta', 'float', ...
                        getMappingProperty(mapping, 'offsetV', 0));
                    element.setParameter('uscale', 'float', ...
                        getMappingProperty(mapping, 'checksPerU', 2));
                    element.setParameter('vscale', 'float', ...
                        getMappingProperty(mapping, 'checksPerV', 2));
                    element.setParameter('tex2', 'spectrum', ...
                        getMappingProperty(mapping, 'oddColor', '300:0 800:0'));
                    element.setParameter('tex1', 'spectrum', ...
                        getMappingProperty(mapping, 'evenColor', '300:0 800:0'));
                    element.setParameter('mapping', 'string', 'uv');
                    element.setParameter('dimension', 'integer', 2);
            end
    end
end
