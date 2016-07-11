function strategy = rtbChooseStrategy(varargin)
% Choose a batch processing strategy appropriate for the given hints.
%
% strategy = rtbChooseStrategy('hints', hints) selects an appropriate batch
% processing strategy based on the given hints.batchRenderStrategy, and
% returns an object of the chosen type.
%
% This utility provides some flexibilty about how users may specify the
% strategy.  The given hints.batchRenderStrategy may be one of the
% following:
%   - an object that extends RtbBatchRenderStrategy -- select the given object
%   - the name of a class that extends RtbBatchRenderStrategy -- select the
%   given class, pass the givne hints to the class constructor, and return
%   the new object
%   - empty, or anything else -- choose RtbVersion3Strategy by default
%
%%% RenderToolbox3 Copyright (c) 2012-2016 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.

parser = inputParser();
parser.addParameter('hints', rtbDefaultHints(), @isstruct);
parser.parse(varargin{:});
hints = parser.Results.hints;

%% Choose the batch rendering strategy.
if isobject(hints.batchRenderStrategy)
    strategy = hints.batchRenderStrategy;
elseif 2 == exist(hints.batchRenderStrategy, 'file')
    constructorFunction = str2func(hints.batchRenderStrategy);
    strategy = feval(constructorFunction, hints);
else
    strategy = RtbVersion3Strategy(hints);
end
fprintf('Using strategy %s\n\n', class(strategy));
