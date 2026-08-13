function template(pat, opt)
% Copy package template files to a target location
% Syntax:
%   PkgBuild.template([PATTERNS],[prj=pwd],[dryrun=false])
% Examples:
%   % To see the list of available files, use either
%   PkgBuild.template(dryrun=true)
%   PkgBuild.template('**', prj=pwd, dryrun=true)
%
%   % To copy individual files/folders
%   mkdir('foo')
%   PkgBuild.template('matlab.toml', prj='foo')
%   PkgBuild.template('tests', prj='foo')
%   PkgBuild.template('**/release.yaml', 'resources/*.m', prj='foo')
%
%   % Use !pat for exceptions
%   PkgBuild.template('**','!**/*.md', dryrun=true)

    arguments (Repeating)
        pat (1,1) string
    end

    arguments
        opt.prj (1,1) string {mustBeFolder} = pwd()
        opt.dryrun (1,1) logical = false
    end

    templateRoot = fullfile(PkgBuildRoot,'template');

    pat = cat(1, pat{:});
    if isempty(pat) || startsWith(pat(1),"!")
        pat = ["**"; pat];
    end

    src = string.empty;
    for p = pat'
        if startsWith(p,'!')
            f = listFiles(fullfile(templateRoot, extractAfter(p,1)));
            src = setdiff(src, f);
        else
            f = listFiles(fullfile(templateRoot, p));
            src = union(src, f);
        end
    end

    rel = arrayfun(@(s) extractAfter(s, strlength(templateRoot) + 1), src);
    tgt = arrayfun(@(r) fullfile(opt.prj,r), rel);
    existing = arrayfun(@isfile, tgt);

    [toCopy, toSkip] = reportMessages(rel, existing, opt);
    disp(toCopy);

    if opt.dryrun 
        disp(toSkip);
        return
    end
    if any(existing)
        warning('PkgBuild:template:skip', toSkip);
    end

    for j = find(~existing(:))'
        p = fileparts(tgt{j});
        if ~isfolder(p)
            mkdir(p);
        end
        copyfile(src{j}, tgt{j});
    end
end

function f = listFiles(pat)

    EXCLUDED = {'..', '.', '.git'};
    d = dir(pat);
    discards = arrayfun(@(d) ismember(d.name, EXCLUDED), d);
    f = arrayfun(@(d) string(fullfile(d.folder, d.name)), d(~discards));
    if isempty(f)
        f = string.empty;
        return
    end

    folders = arrayfun(@isfolder, f);
    ff = arrayfun(@listFiles, f(folders),'unif', 0);
    f = unique(cat(1, f(~folders), ff{:}));
end

function [toCopy, toSkip] = reportMessages(rel, existing, opt)

    if opt.dryrun
        msgPat = 'DRYRUN: %d files would be copied to %s';
    else
        msgPat = 'Copying %d files to %s';
    end
    toCopy = string(sprintf(msgPat, nnz(~existing), opt.prj));
    
    if isempty(existing)
        toCopy = strjoin([toCopy, "the provided pattern(s) matched no files :/"], ', ');
    end
    if any(~existing)
        toCopy = toCopy + sprintf('\n  %s', rel(~existing));
    end

    if any(existing)
        toSkip = "The following files already exist, and will NOT be copied:";
        toSkip = toSkip + sprintf('\n  %s', rel(existing));
    else
        toSkip = string.empty();
    end
end