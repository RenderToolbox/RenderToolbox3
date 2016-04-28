%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Write a scene XML document to file.
%   @param sceneFile file name or path to write
%   @param docNode XML document node object 
%
% @details
% Write a new XML scene file with the given @a sceneFile name (which use
% the extension .dae or .xml).  The given @a domDoc must be an XML document
% node as returned from ReadSceneDOM().
%
% @details
% Usage:
%   WriteSceneDOM(sceneFile, docNode)
%
% @ingroup SceneDOM
function WriteSceneDOM(sceneFile, docNode)

xmlwrite(sceneFile, docNode);