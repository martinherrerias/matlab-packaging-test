function cfg = toml2struct(prjTOML, useExternal)
% Return a nested structure with the contents of a PRJTOML,
% while trying to provide a consistent output from either:
%   <a href="https://uk.mathworks.com/matlabcentral/fileexchange/67858-matlab-toml">toml.read</a> external toolbox (default on R2026a and earlier)
%   <a href="matlab:help matlab.internal.project.metadata.TomlTable">matlab.internal.project.metadata.TomlTable</a> (R2026b+)
%
% Syntax:
%   S = TOML2STRUCT(PRJTOML, USEEXTERNAL)
% Inputs:
%   PRJTOML - a matlab.toml file
%   USEEXTERNAL - defaults to version('-release') < "2026b"
% Output:
%   S - a nested structure. Field names will have been massaged by
%       matlab.lang.makeValidName, and string representations made
%       uniform (string arrays).
%
% See also: PkgBuild.mapToolboxOptions

arguments
    prjTOML (1,1) string {mustBeFile} = 'matlab.toml'
    useExternal (1,1) logical = version('-release') < "2026b"
end

if ~useExternal
    rootTable = matlab.internal.project.metadata.TomlTable(prjTOML);
    cfg = TomlTable2Struct(rootTable);
    return
end

if isempty(which('toml.read'))
    try
        originalPath = path;
        restorePath = onCleanup(@() path(originalPath));
        addpath(fullfile(PkgBuildRoot,'external','matlab-toml'));
        assert(~isempty(which('toml.read')));
    catch
        error('PkgBuild:mapToolboxOptions:toml', 'Failed to load external matlab-toml parser. Please ensure external/matlab-toml is on the path.');
    end
end

cfg = toml.read(prjTOML);
cfg = toml.map_to_struct(cfg);
cfg = flattenCells(cfg);

end

function v = flattenCells(v)
% unwrap values wrapped as single cells
% provide consistent string representations

    if iscell(v)
        if all(cellfun(@(x) ischar(x) || isstring(x), v))
            v = string(v);
        elseif isscalar(v)
            v = v{1};
        end
    end
    if isstruct(v)
        for fld = fieldnames(v)'
            f = fld{1};
            v.(f) = flattenCells(v.(f));
        end
    end
end

function s = TomlTable2Struct(t)
    s = struct();
    for j = 1:numel(t.Keys)
        k = t.Keys{j};
        v = flattenCells(t{k});
        f = matlab.lang.makeValidName(k);
        if isa(v,'matlab.internal.project.metadata.TomlTable')
            s.(f) = TomlTable2Struct(v);
        else
            s.(f) = v;
        end
    end
end
