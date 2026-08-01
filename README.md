## spintent — Spanish parse intent
![GitHub release (latest by date)](https://img.shields.io/github/v/release/pablgonz/spintent?label=version)
![GitHub Release Date](https://img.shields.io/github/release-date/pablgonz/spintent)
![GitHub last commit](https://img.shields.io/github/last-commit/pablgonz/spintent)

## Descripción

El paquete <code>&langle;spintent&rangle;</code> proporciona una serie de utilidades para docentes de educación
primaria y secundaria que necesiten crear documentos `PDF` _accesibles_ \(_tagged_ PDF\)
en español utilizando `LuaLaTeX`.

## Requerimientos

The minimum requirement is `LaTeX` release 2026-11-01. Loads and depend on updated version of [unicode-math](https://ctan.org/pkg/unicode-math).

## Installation

The <code>&langle;spintent&rangle;</code> package is present in [TeX Live](https://www.tug.org/texlive/) and [MiKTeX](https://miktex.org/), use the
package manager to install.

For manual installation, download [spintent.zip](http://mirrors.ctan.org/macros/latex/contrib/spintent.zip) and unzip it,
then run:

```
$ luatex spintent.ins
```

and move all files to appropriate locations:

```
  spintent.sty  ->  TDS:tex/luatex/spintent/spintent.sty
  spintent.lua  ->  TDS:tex/luatex/spintent/spintent.lua
  spintent.pdf  ->  TDS:doc/luatex/spintent/spintent.pdf
  README.md     ->  TDS:doc/luatex/spintent/README.md
  spintent.dtx  ->  TDS:source/luatex/spintent/spintent.dtx
  spintent.ins  ->  TDS:source/luatex/spintent/spintent.ins
```

then run `mktexlsr`. To produce the documentation with source code run `arara spintent.dtx`.

## Examples

The file <code>&langle;spintent.pdf&rangle;</code> contains attached examples, which can be extracted
from the PDF viewer or from the command line by running:

```
$ pdfdetach -saveall spintent.pdf
```

and then you can use the excellent `arara` tool to compile them.

## Development

The version numbers and dates are guaranteed to be correct in
the repository is in the `l3build` configuration file `build.lua`.

The date format is `YYYY-MM-DD`. If it is important to you
that the files created have the correct version and date, you should run
`l3build tag` before any other build-related task.

You can run:

- `l3build unpack` to extract the code files into the directory `build/unpacked/`.
- `l3build doc` to build the documentation.
- `l3build install` put all files  in your `TEXMFHOME`.
- `l3build uninstall` will remove them.
- `l3build testpkg` to test files.
- `l3build examples` to compile example files.

## License

The <code>&langle;spintent&rangle;</code> package may be modified and distributed under the terms and
conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.

## Content of the repository

```
├── README.md
├── build.lua
├── ctan.ann
└── sources
    ├── CTANREADME.md
    ├── spintent.dtx
    ├── spintent.ins
    ├── spintent.lua
    ├── spintent.sty
    └── test-pkg
        ├── spintent-01.tex
        ├── spintent-02.tex
        ├── spintent-03.tex
        ├── spintent-04.tex
        ├── spintent-05.tex
        ├── spintent-06.tex
        ├── spintent-07.tex
```

## Copyright

Copyright &#169; 2026 by Pablo González L <pablgonz@educarchile.cl>
