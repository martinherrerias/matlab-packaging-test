function startup(prjTOML)
% Provide TOML-based project-initialization on R2026a and earlier, i.e.
%
% - add [folders].path to MATLAB path
% - run [project].startup-files
%

arguments
    prjTOML (1,1) string {mustBeFile} = 'matlab.toml'
end

prj = PkgBuild.toml2struct(prjTOML);

root = fileparts(prjTOML);
if strlength(root) == 0, root = pwd; end
oldPath = cd(root);
goBack = onCleanup(@() cd(oldPath));

if isfield(prj,'folders') && isfield(prj.folders,'path')
    paths = cellstr(prj.folders.path);
    addpath(paths{:});
end

if isfield(prj,'project') && isfield(prj.project,'startup_files')
    arrayfun(@run, prj.project.startup_files);
end
