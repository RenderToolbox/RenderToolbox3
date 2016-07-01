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
%
%   funciton [value, isUpdate] = myVisitFun(value, varargin)
%
% The input value is the value of field from the original struct. Varargin
% is any extra arguments passed to this function, to pass on to the given
% visitFunction.  The output value may be the same input value, or a newly
% computed value.  The output isUpdate is a flag used to decide whether the
% original struct field should be updated, or just left alone.
%
% rtbVisitStructFields( ... 'visitArgs', visitArgs) specifies a cell array of
% arguments to pass to the given visitFunction, following the current field
% value.
%
% rtbVisitStructFields( ... 'filterFunction', filterFunction) specifies a
% function handle to use for filtering struct fields.  If the
% filterFunction is provided, it will be invoked for each struct field
% value, and the given visitFunction will only be invoked if the
% filterFunction returns true.  This is an optimization to avoid unnecesary
% invokations of the visitFunction.
%
% struct = rtbVisitStructFields(struct, visitFunction, varargin)
%
% Copyright (c) 2016 mexximp Team

parser = inputParser();
parser.addRequired('struct', @isstruct);
parser.addRequired('visitFunction', @(f) isa(f, 'function_handle'));
parser.addParameter('visitArgs', {}, @iscell);
parser.addParameter('filterFunction', []);
parser.parse(struct, visitFunction, varargin{:});
struct = parser.Results.struct;
visitFunction = parser.Results.visitFunction;
visitArgs = parser.Results.visitArgs;
filterFunction = parser.Results.filterFunction;

% kick off recursion with the original struct
struct = traverseFields(struct, visitFunction, filterFunction, visitArgs);


%% Recursively traverse struct fields.
function struct = traverseFields(struct, visitFunction, filterFunction, visitArgs)

nElements = numel(struct);
topLevelFields = fieldnames(struct);
for ee = 1:nElements
    for tt = 1:numel(topLevelFields)
        field = topLevelFields{tt};
        value = struct(ee).(field);
        if isstruct(value)
            % recursive case: dig into nested struct
            struct(ee).(field) = traverseFields(value, visitFunction, filterFunction, visitArgs);
            
        elseif isempty(filterFunction) || feval(filterFunction, value)
            % base case: apply the visit function to the field value
            try
                [value, isUpdate] = feval(visitFunction, value, visitArgs{:});
            catch foon
                isUpdate = false;
            end
            if isUpdate
                struct(ee).(field) = value;
            end
        end
    end
end
