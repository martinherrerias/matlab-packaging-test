function opts = mapToolboxOptions(prjTOML)
% Populate matlab.addons.toolbox.ToolboxOptions from matlab.toml,
% trying to ensure consistent behavior pre- and post-R2026b
%
% Syntax:
%   opts = PkgBuild.mapToolboxOptions(prjTOML)

arguments
    prjTOML (1,1) string {mustBeFile}
end

root = fileparts(prjTOML);
if strlength(root) == 0, root = pwd(); end
wd = cd(root);
restoreWd = onCleanup(@() cd(wd));

%% R2026b+ can populate options automatically from the matlab.toml
if version('-release') >= "2026b"

    if isfile("toolbox.ignore") && ~isfile("package.ignore")
        copyfile("toolbox.ignore", "package.ignore");
        cleanupIgnore = onCleanup(@() delete("package.ignore"));
    end
    if isfile("package.ignore")
        ws = warning();
        restoreWs = onCleanup(@() warning(ws));
        warning('off','MATLAB:toolbox_packaging:packaging:ToolboxIgnoreDeprecated');
    end

    opts = matlab.addons.toolbox.ToolboxOptions(prjTOML);

    if isfile('README.md')
        opts.Readme = 'README.md';
    end

    opts.OutputFile = opts.PackageName + '@' + opts.ToolboxVersion + '.mltbx';

    return
end

%% for <= R2026a, use external/matlab-toml parser

if isfile("package.ignore") && ~isfile("toolbox.ignore")
    copyfile("package.ignore", "toolbox.ignore");
    cleanupIgnore = onCleanup(@() delete("toolbox.ignore"));
end

prj = readTOML(prjTOML);
pkg = prj.package;

root = fullfile(pwd, pkg.package_root);
pid = pkg.id;
opts = matlab.addons.toolbox.ToolboxOptions(root, pid);

% NOTE: R2026b uses ToolboxName = pkg.display_name and .PackageName = pkg.name

FIELD_MAP = {
    'ToolboxName', 'display_name';
    'ToolboxVersion', 'version';
    'AuthorName', 'provider.name';
    'AuthorCompany', 'provider.organization';
    'AuthorEmail', 'provider.email';
    'Summary', 'summary';
    'Description', 'description';
    'ToolboxMatlabPath', 'folders.path';
    'ToolboxImageFile', 'preview_image_file';
    'ToolboxGettingStartedGuide', 'getting_started_file';
};

for j = 1:size(FIELD_MAP,1)
    tgt = FIELD_MAP{j,1};
    try
        % get [nested] pkg field
        src = strsplit(FIELD_MAP{j,2},'.');
        val = getfield(pkg, {1}, src{:});
    catch err
        if err.identifier ~= "MATLAB:nonExistentField", rethrow(err); end
        continue;
    end
    opts.(tgt) = val;
end

if isfield(pkg, 'release_compatibility') && ~isempty(pkg.release_compatibility)
    opts = mapReleases(pkg.release_compatibility, opts);
end

if isfield(pkg, 'supported_platforms') && ~isempty(pkg.supported_platforms)
    % TODO: TOML doesn't record "MATLAB online" compatibility
    opts.SupportedPlatforms = mapSupportedPlatforms(pkg.supported_platforms);
end

opts.OutputFile = [pkg.name '@' pkg.version '.mltbx'];

% TODO: complete mapping of dependencies (download URL, fancy version ranges, etc.)
if isfield(prj, 'dependencies') && ~isempty(prj.dependencies)
    opts.RequiredAddons = mapDependencies(prj.dependencies);
end

% TODO: ToolboxOptions doesn't support non-scalar platforms
% opts.RequiredAdditionalSoftware = f(pkg.required_additional_software);

% % TODO: pointers to example/tutorial files
% opts.AppGalleryFiles: [0×0 string]

end

function cfg = readTOML(prjTOML)

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

function s = flattenCells(s)
% toml.map_to_struct likes returning fields wrapped as single cells

    for fld = fieldnames(s)'
        f = fld{1};
        v = s.(f);
        if iscell(v) && isscalar(v)
            v = v{1};
        end
        if isstruct(v)
            v = flattenCells(v);
        end
        s.(f) = v;
    end
end

function opts = mapReleases(release_compatibility, opts)
% Map '22.1.* - 26.2.*' to ['R2022a', 'R2026b']

    pat = '(\d\d).([1,2])(?:\.\*)?\s?-\s?(\d\d)\.([1,2])(?:\.\*)?';
    tokens = regexp(release_compatibility, pat, 'tokens');
    if isempty(tokens)
        warning('Failed to map release_compatibility %s', release_compatibility);
    end
    label = @(tk1,tk2) sprintf('R20%s%s',tk1, char('a' + strfind('12', tk2) - 1));
    a = label(tokens{1}{1:2});
    b = label(tokens{1}{3:4});

    try
        opts.MinimumMatlabRelease = a;
    catch
        opts.MinimumMatlabRelease = 'R2014b';
    end
       
    try
        opts.MaximumMatlabRelease = b;
    catch
        opts.MaximumMatlabRelease = '';
    end
end

function s = mapSupportedPlatforms(supported_platforms)
    map = struct(Win64='windows', Glnxa64='linux', MatlabOnline='online');
    if version('-release') <= "2025a"
        map.Maci64='macos';
    else
        map.Mac='macos';
    end
    s = structfun(@(x) ismember(x, supported_platforms), map, 'unif', false);
end

function addons = mapDependencies(deps)

    deps = cellfun(@(f) matlab.mpm.Dependency(f, deps.(f).version, deps.(f).id), fieldnames(deps));
    addons = arrayfun(@dep2addon, deps);
end

function s = dep2addon(dep)

    vspecs = strsplit(dep.VersionRange, ' ');
    a = 'latest';
    b = 'latest';
    for j = 1:numel(vspecs)
        spec = strtrim(vspecs{j});
        if startsWith(spec, '<=')
            b = spec(3:end);
        elseif startsWith(spec, '>=')
            a = spec(3:end);
        elseif startsWith(spec, '=')
            a = spec(2:end);
            b = spec(2:end);
        else
            error('mapToolboxOptions:versionRange','Only <=, =, and >= version ranges are supported');
        end
    end

    s = struct('Name', dep.Name, 'Identifier', dep.ID, 'EarliestVersion', string(a), 'LatestVersion', string(b), 'DownloadURL', "");
end