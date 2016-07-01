%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Modify a scene document with a mapping.
%   @param idMap
%   @param mappings
%
% @details
% Modify the document represented by the given @a idMap, with the given
% @a mappings.  @a mappings must be a struct array of mappings data as
% returned from ParseMappings().  The mappings should contain Scene DOM
% paths on the left-hand side.
%
% @details
% Creates document nodes as needed, to satisfy the left-hand Scene DOM
% paths.
%
% @details
% Used internally by MakeSceneFiles().
%
% @details
% Usage:
%   ApplySceneDOMPaths(idMap, mappings)
%
% @ingroup Mappings
function ApplySceneDOMPaths(idMap, mappings)

for ii = 1:numel(mappings)
    
    map = mappings(ii);
    
    % create the path id node, if needed
    nodePath = PathStringToCell(map.left.value);
    id = nodePath{1};
    if ~idMap.isKey(id)
        docNode = idMap('document');
        docRoot = docNode.getDocumentElement();
        idNode = CreateElementChild(docRoot, 'merge', id);
        idMap(id) = idNode;
    end
    
    % apply the mapping right-hand value to the left-hand path
    SetSceneValue(idMap, nodePath, map.right.value, true, map.operator);
end