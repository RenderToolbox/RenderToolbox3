function struct = rtbVisitStructFields(struct, visitFunction, varargin)
%% Recursively visit and/or update the fields in (nested) struct array.
%
% struct = rtbVisitStructFields(struct, visitFunction, varargin)
% recursively traverses fields of the given struct array and applies the
% given visitFunction to each one.  Depending on the values returned from
% the visitFunction, may update the struct field.
%
% The idea here is to recursively traverse all the fields of a nested
% struct array.  And we want to write the fussy recursive code once, here
% in  this function.  Then we want to reuse this traversal for various
% different computations, each implemented in a different visitFunction.
%
% visitFunction must have the following inputs and outputs:
%   funciton [value, isUpdate] = myVisitFun(value, varargin)
% The input value is the value of field from the original struct. Varargin
% is any extra arguments passed to this function, to pass on to the given
% visitFunction.  The output value may be the same input value, or a newly
% computed value.  The output isUpdate is a flag used to decide whether the
% original struct field should be updated, or just left alone.
%
% struct = rtbVisitStructFields(struct, visitFunction, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('struct', @isstruct);
parser.addRequired('visitFunction', @(f) isa(f, 'function_handle'));
parser.parse(struct, visitFunction);
struct = parser.Results.struct;
visitFunction = parser.Results.visitFunction;

% Kick off recursion with the original struct.
struct = traverseFields(struct, visitFunction, varargin{:});


%% Recursively traverse struct fields.
function struct = traverseFields(struct, visitFunction, varargin)

nElements = numel(struct);
topLevelFields = fieldnames(struct);
for ee = 1:nElements
    for tt = 1:numel(topLevelFields)
        field = topLevelFields{tt};
        value = struct(ee).(field);
        try %#ok<TRYNC>
            [value, isUpdate] = feval(visitFunction, value, varargin{:});
            if isUpdate
                struct(ee).(field) = value;
            end
        end
    end
end
