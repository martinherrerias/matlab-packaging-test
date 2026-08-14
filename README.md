# MATLAB-Package-Builder

`PkgBuild` is at the same time an opinionated MATLAB project template and toolbox packaging utility. It tries to navigate the confusing MATLAB packaging landscape, embracing the transition to the post-R2026b `matlab.toml` project structure, but trying to wedge it into GitHub workflows that run on older MATLAB releases.

It has two main entry-points:

- `PkgBuild.fromTOML` builds a MATLAB toolbox file (`*.mltbx`) from a `matlab.toml`.
- `PkgBuild.template` copies project files and folders from a reusable template.

The overall structure of the package might be clearer when looking at the [template README](../template/README.md) (the _template_ is just another branch of this same repo). Beyond CI/CD, the template tries to encourage good software engineering practices (unit testing, namespacing, dependency management, etc.).

> [!NOTE]
> If you think we could do better, **please submit an issue or pull request**.

## Requirements

- Aiming for it to work on R2025a+ and all platforms (support for `toolbox.ignore` is missing on older releases, but most features should still work).
- For anything before R2026b, it uses an external [matlab-toml](https://github.com/g-s-k/matlab-toml) parser (see [below](#toml-projects-on-r2026b-pre-release)).

## Setup

Install via de Add-Ons explorer; download from [FileExchange](https://mathworks.com/matlabcentral/fileexchange/184426-matlab-package-builder); or clone, self-build, and install:

```matlab
!git clone --depth 1 --recurse-submodules https://github.com/UoMResearchIT/MATLAB-Package-Builder.git
cd MATLAB-Package-Builder
PkgBuild.fromTOML('matlab.toml', 'OutputFile','PkgBuild.mltbx')
mpminstall('PkgBuild.mltbx')
```

## Getting started

To create and build a new toolbox project from the bundled template:

```matlab
mkdir('my_test_package')
cd('my_test_package')
PkgBuild.template()
PkgBuild.fromTOML()
```

## Known Issues & Limitations

- Mapping from `matlab.toml` to pre-R2026b `matlab.addons.toolbox.ToolboxOptions` is not complete (and some features might just be incompatible).
- Older versions will not recognize the `matlab.toml` as a project file, i.e. things like startup/shudown scripts, path management, and other project settings will not be automatically applied during development. As a workaround, `PkgBuild.startup` can read the `matlab.toml`, add the defined project paths and trigger the startup scripts.
- `PkgBuild` has been tested on the R2026b-pre-release, but not on CI/CD runners yet... it will also (hopefully) provide little value beyond templating at that point.
- We could probably do better with the docs, maybe render help files on CI/CD and show in the template what *good* MATLAB documentation looks like.

# Design Notes

## GitHub Integration

Since [2024](https://uk.mathworks.com/matlabcentral/discussions/highlights/847426-enhancing-github-and-file-exchange-connection-matlab-and-simulink-integration-for-github-unveiled), it has been possible to link a raw GitHub repo and let it appear as a [FileExchange](https://www.mathworks.com/matlabcentral/fileexchange) repository.

An annoying aspect is that the GitHub app and the FileExchange metadata pipeline do not read the package metadata from either an [`mpackage.json`](#mpmcreate-and-mpminstall) or [`matlab.toml`](#toml-projects-on-r2026b-pre-release) directly. If you want the metadata to be extracted automatically, the release asset (*at the time of release creation*) must contain a packaged `.mltbx` file, with the metadata embedded inside it.

This is the reason the template's `release.yml` is triggered on a tag push rather than on release. Having it generate a *draft* release allows you to download and test the `.mltbx` file before publishing, but this can be changed if you are confident in the build process.

## Toolboxes and packages on R2026a and older versions

Until R2026a, MATLAB offered two distinct packaging systems: [project-based](#package-toolboxfrom-the-add-onsmenu) toolboxes and [`mpm`](#mpmcreate-and-mpminstall) packages. Access through [`matlab.addons.toolbox.ToolboxOptions`](#matlabaddonstoolboxtoolboxoptions) allows some navigation in between, so it's the tool we're using.

### _Package Toolbox_ from the Add-Ons menu

- Metadata (entered through _Project_ UI) stored in a mess of XML files under `resources/project` (and `%appdata%` or equivalent).
- Building the project would generate an `*.mltbx` file, that you could upload to FileExchange or share with colleagues.

### [`mpmcreate`](https://mathworks.com/help/matlab/ref/mpmcreate.html) and [`mpminstall`](https://mathworks.com/help/matlab/ref/mpminstall.html)

- Package config stored in `resources/mpackage.json`.
- Meant for local distribution (_Repositories_ are local folders).

### [`matlab.addons.toolbox.ToolboxOptions`](https://mathworks.com/help/matlab/ref/matlab.addons.toolbox.toolboxoptions.html)

Can be used to build a `*.mltbx` file programmatically. Some settings (but not all?) get imported from `resources/mpackage.json`, if available.

## TOML projects on R2026b (pre-release)

The reason of picking `matlab.toml` over `mpackage.json` is that the former promises to integrate *project* features on top of packaging, and though painful to use now, should work smoothly in R2026b and later.

- `matlab.toml` resolves the XML mess, and mostly[^1] works with `matlab.addons.toolbox.packageToolbox`
- `FileExchange` should be integrated as an `mpm` Repository
- `mpmcreate/install` seems still disconnected from (but can co-exist with) the TOML project file.
- R2026b not yet available on Docker or GH actions - which is where `PkgBuild` comes to the rescue!

[^1]: Everything but multi-platform dependencies?
