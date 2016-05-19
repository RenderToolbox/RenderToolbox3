%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Modify a Collada document once, before all other processing.
%   @param docNode XML Collada document node Java object
%   @param hints struct of RenderToolbox3 options
%
% @details
% This function is a template for a RenderToolbox3 "BeforeAll" remodeler
% function.  A remodeler is a set of user-defined functions for modifying
% Collada parent scene documents.
%
% @details
% By default, RenderToolbox3 does not invoke any remodeler.  If the name of
% a remodeler is specified in the @b hints.remodeler argument passed to a
% function like MakeSceneFiles(), then RenderToolbox3 will automatically
% invoke the named remodeler during scene file generation.
%
% @details
% The name of a BeforeAll function must match a specific pattern: it must
% begin with "RTB_BeforeAll_", and it must end with the name of a
% remodeler, for example "SampleRemodeler".  This pattern allows
% RenderToolbox3 to automatically locate the BeforeAll function for a given
% remodeler.  BeforeAll functions should be included in the Matlab path.
%
% @details
% A BeforeAll function must accept as its first argument an XML document
% node Java object, as returned from ReadSceneDom().  This @a docNode
% will represent the entire Collada parent scene.  It must accept as its 
% second argument a struct of RenderToolbox3 options as returned from
% rtbDefaultHints().
%
% @details
% A BeforeAll function may modify the given XML document in any way, or not
% at all.  These modifications will be applied once, before all other scene
% file processing, so they will affect all generated scene files.
%
% @details
% A BeforeAll function must return the given XML document node Java object,
% or a different XML document node Java object, if desired.
%
% Usage:
%   docNode = RTB_BeforeAll_SampleRemodeler(docNode, hints)
%
% @ingroup RemodelerPlugins
function docNode = RTB_BeforeAll_SampleRemodeler(docNode, hints)

disp('SampleRemodeler BeforeAll function.')

disp('docNode is:');
disp(docNode);
disp('hints is:');
disp(hints);
