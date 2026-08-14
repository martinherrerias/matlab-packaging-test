function fromTOML(prjTOML, propName, propVal)
% Build *mltbx from matlab.toml using PkgBuild.mapToolboxOptions
% Syntax:
%   PkgBuild.fromTOML(prjTOML) - Writes package to pkgname@version.mltbx
%   PkgBuild.fromTOML(..., Name, Value) - Override one or more
%     matlab.addons.toolbox.ToolboxOptions properties, e.g.:
%     PkgBuild.fromTOML('matlab.toml', 'OutputFile','test.mltbx')
%
% See also: PkgBuild.mapToolboxOptions, matlab.addons.toolbox.packageToolbox

    arguments
        prjTOML (1,1) string {mustBeFile} = 'matlab.toml'
    end
    
    arguments (Repeating)
        propName (1,1) string {mustBeToolBoxOption(propName)}
        propVal
    end

    opts = PkgBuild.mapToolboxOptions(prjTOML);

    for j = 1:numel(propName)
        opts.(propName{j}) = propVal{j};
    end

    matlab.addons.toolbox.packageToolbox(opts);
end

function mustBeToolBoxOption(value)
    mc = ?matlab.addons.toolbox.ToolboxOptions;
    props = mc.PropertyList;
    filter = arrayfun(@(p) (p.Dependent && isempty(p.SetMethod)) || p.Constant || strcmp(p.SetAccess, 'immutable'), props);
    mustBeMember(value, {mc.PropertyList(~filter).Name})
end
