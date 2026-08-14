function help()
% HELP  Display a summary of the PkgBuild toolbox and its features.
%
% See also PkgBuild.fromTOML, PkgBuild.template.

    readmes = {'README.md', 'template/README.md', 'doc/GettingStarted.m'};
    links = cellfun(@(f) sprintf('<a href="%s">%s</a>', fullfile(PkgBuildRoot, f), f), readmes, 'UniformOutput', false);

    fprintf('Check out the %s, and %s.\n', strjoin(links(1:end-1), ', '), links{end});
    fprintf('or use the help command for each function:\n\n');
    for f = functionList()
        % fprintf('  help PkgBuild.%s\n', f);
        fprintf('  <a href="matlab:help PkgBuild.%s">help PkgBuild.%s</a>\n', f, f);
    end
    fprintf('\n');
end

function f = functionList()

    % TODO: use namespaceFunctions in R2026a+
    EXCLUDED = {'help.m'};
    d = dir(fullfile(fileparts(mfilename('fullpath')),'*.m'));
    discards = arrayfun(@(d) ismember(d.name, EXCLUDED) || d.isdir, d);
    f = arrayfun(@(d) string(d.name(1:end-2)), d(~discards));
end
