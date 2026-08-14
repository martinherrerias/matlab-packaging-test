# TemplatePackage

This is a reusable MATLAB package scaffold intended to be cloned as the starting point for new work:

```
git clone -d1 --branch template https://github.com/UoMResearchIT/MATLAB-Package-Builder my-new-package
```

It is also used by the main branch (the **`PkgBuild`** utility) as testbed and source of individual file templates.

## Scope

This is an opinionated structre template. Its job is to provide a sensible starting point for MATLAB toolbox development, with:

- a single source of project metadata in [matlab.toml](matlab.toml) (in line with R2026b+)
- a clean separation between bundled package content and development-only files
- good software engineering practices (unit-tests, name-spacing, documentation, etc.)
- CI/CD GitHub integration

## Repository layout

- [matlab.toml](matlab.toml) — central project metadata and package configuration
- [buildfile.m](buildfile.m) — `buildtool` script, rigged to use `PkgBuild.fromTOML` as `release` task.
- [package.ignore](package.ignore) — files and folders [excluded](#excluded-files-and-folders) from the packaged toolbox bundle.
- [+TemplatePackage/](+TemplatePackage/) — MATLAB [package namespace](#package-namespace); rename this to match your package.
- [doc/](doc/) — documentation and getting-started content bundled with the package
- [external/](external/) — third-party code or git submodules used during development (see [below](#external-dependencies))
- [resources/](resources/) — packaging assets (cannot contain MATLAB code)
- [scripts/](scripts/) — startup and shutdown hooks for the workspace
- [tests/](tests/) — example unit tests for the project

## Excluded files and folders

The `package.ignore` file lists files and folders that should not be included in the packaged toolbox bundle. This is important to keep the end-user installation clean and free of development artifacts.

In R2025a-R2026a this file was called `toolbox.ignore`. *PkgBuild* should adjust the name automatically depending on the MATLAB version.

## Package namespace

It's good manners to [namespace](https://mathworks.com/help/matlab/matlab_oop/namespaces.html) your package functions, to avoid name collisions with other packages. Functions will be avaiable to the user as `YourPackage.functionName`. For existing code, you can always `import YourPackage.*` and use the bare function names.

### External dependencies

The `external/` directory is intended for dependencies that are required for  runtime/development, but should not be shipped as part of the published toolbox bundle (by default, the directory is listed in `package.ignore`). See the [external/README.md](external/README.md) for details.

### Project hooks

MATLAB versions older than R2026b will not recognize the `matlab.toml` as a project file, i.e. startup/shudown scripts, path management, and other project settings will not be automatically applied during development. As a workaround you could add `PkgBuild.startup();` to a `startup.m` file on your project root.

## CI/CD

The project is set up to use GitHub Actions for continuous integration and deployment. The workflow is defined in `.github/workflows/release.yml` and wraps a call to `buildtool -buildFile resources/buildfile.m` triggered by a (`v`-prefixed) tag push. It should run tests, check for code warnings, bundle the package into a `*mltbx` file, and attach it to a draft release. When configured 

Set `draft: false` in the workflow to automatically publish the release, or leave it as `true` to manually review and publish.

The first time you create a release for a project, you will have to [configure FileExchange](https://uk.mathworks.com/matlabcentral/fileexchange/my-file-exchange/github-app-installation-guide) to automatically upload package releases.
