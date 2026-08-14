function p = PkgBuildRoot()
% Returns the path to this project's root (above +PkgBuild)
    p = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end