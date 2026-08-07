function opts = mapToolboxOptions(prjTOML)
% Populate matlab.addons.toolbox.ToolboxOptions from matlab.toml,
% trying to ensure consistent behavior pre- and post-R2026b

arguments
    prjTOML (1,1) string {mustBeFile} = prjPath('matlab.toml')
end

wd = cd(fileparts(prjTOML));
restoreWd = onCleanup(@() cd(wd));

if version('-release') >= "2026b"
% R2026b+ can populate options automatically from the matlab.toml

    if isfile("package.ignore")
        ws = warning();
        restoreWs = onCleanup(@() warning(ws));
        warning('off','MATLAB:toolbox_packaging:packaging:ToolboxIgnoreDeprecated');
    end
    opts = matlab.addons.toolbox.ToolboxOptions(prjTOML);

    opts.Readme = prjPath('README.md');
    opts.OutputFile = opts.PackageName + '@' + opts.ToolboxVersion + '.mltbx';
    return
end

% for <= R2026a, use external/matlab-toml parser

ps = path;
addpath('external/matlab-toml');
restorePath = onCleanup(@() path(ps));

prj = readTOML(prjTOML);
pkg = prj.package;

root = fullfile(fileparts(prjTOML), pkg.package_root);
pid = pkg.id;
opts = matlab.addons.toolbox.ToolboxOptions(root, pid);

% NOTE: R2026b uses ToolboxName = pkg.display_name and .PackageName = pkg.name
opts.ToolboxName = pkg.name;
opts.ToolboxVersion = pkg.version;

opts.AuthorName = pkg.provider.name;
opts.AuthorCompany = pkg.provider.organization;
opts.AuthorEmail = pkg.provider.email;
opts.Summary = pkg.summary;
opts.Description = pkg.description;

opts.ToolboxMatlabPath = pkg.folders.path;

opts = mapReleases(pkg.release_compatibility, opts);

% TODO: TOML doesn't record "MATLAB online" compatibility
opts.SupportedPlatforms = mapSupportedPlatforms(pkg.supported_platforms);

opts.ToolboxImageFile = pkg.preview_image_file;
opts.ToolboxGettingStartedGuide = pkg.getting_started_file;
opts.OutputFile = [pkg.name '@' pkg.version '.mltbx'];

% TODO: TOML doesn't record MATLAB addons?
% opts.RequiredAddons = ?

% TODO: ToolboxOptions doesn't support non-scalar platforms
% opts.RequiredAdditionalSoftware = f(pkg.required_additional_software);

% % TODO: pointers to example/tutorial files
% opts.AppGalleryFiles: [0×0 string]

end

function path = prjPath(varargin)
    try
        [status, root] = system('git rev-parse --show-toplevel');
        assert(status == 0);
        root = strtrim(root);
    catch err
        root = fileparts(fileparts(mfilename('fullpath')));
        if isempty(root), root = pwd; end
    end
    path = fullfile(root, varargin{:});
end

function cfg = readTOML(prjTOML)
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
