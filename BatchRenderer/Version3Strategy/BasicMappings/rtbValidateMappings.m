function mappings = rtbValidateMappings(rawMappings)
%% Sanity check mappings and fill in default fields.
%
% mappings = rtbValidateMappings(rawMappings) sanity checks mappings
% contained in the given rawMappings cell array.  Fills in any default
% fields that were omitted from the cell array elements and ignores fields
% that are not recognized mappings fields.  Returns a struct array with
% standard mappings fields and one element per mapping.
%
% mappings = rtbValidateMappings(rawMappings)
%
% Copyright (c) 2016 mexximp Team


%% Declare standard mappings struct fields.
parser = inputParser();
parser.StructExpand = true;
parser.addParameter('name', '', @ischar);
parser.addParameter('index', [], @isnumeric);
parser.addParameter('broadType', '', @ischar);
parser.addParameter('specificType', '', @ischar);
parser.addParameter('operation', 'create', @ischar);
parser.addParameter('group', '', @ischar);
parser.addParameter('destination', 'Generic', @ischar);
parser.addParameter('properties', []);

% check each element one at a time
nMappings = numel(rawMappings);
validatedMappings = cell(1, nMappings);
for mm = 1:nMappings
    parser.parse(rawMappings{mm});
    mapping = parser.Results;
    
    % convert single-element properties to cell, for processing convenience
    if isstruct(mapping.properties)
        mapping.properties = {mapping.properties};
    end
    
    % check each property element one at a time
    if iscell(mapping.properties)
        nProperties = numel(mapping.properties);
        validatedProperties = cell(1, nProperties);
        for pp = 1:nProperties
            validatedProperties{pp} = rtbMappingProperty(mapping.properties{pp});
        end
        mapping.properties = [validatedProperties{:}];
    end
    
    validatedMappings{mm} = mapping;
end
mappings = [validatedMappings{:}];
