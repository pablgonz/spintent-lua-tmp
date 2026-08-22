## spintent — Spanish parse intent

Release v0.98 \[2026-08-20\]

## Description

This package provides enumerated list environments compatible with
_tagging_ PDF for creating “simple exercise sheets” along with
“multiple choice questions”, storing the “answers” to these in memory
using <code>&langle;multicol&rangle;</code> package.

## Requirements

The minimum requirement is LaTeX release 2026-11-01. Loads and depend
on updated version of [unicode-math](https://ctan.org/pkg/unicode-math).

## Installation

The <code>&langle;spintent&rangle;</code> package is present in TeX Live and MiKTeX, use the
package manager to install.

For manual installation, download [spintent.zip](http://mirrors.ctan.org/macros/latex/contrib/spintent.zip) and unzip it,
then run:

```
$ luatex spintent.ins
```

and move all files to appropriate locations:

```
  spintent.sty  ->  TDS:tex/lualatex/spintent/spintent.sty
  spintent.lua  ->  TDS:tex/lualatex/spintent/spintent.lua
  spintent.pdf  ->  TDS:doc/lualatex/spintent/spintent.pdf
  README.md     ->  TDS:doc/lualatex/spintent/README.md
  spintent.dtx  ->  TDS:source/lualatex/spintent/spintent.dtx
  spintent.ins  ->  TDS:source/lualatex/spintent/spintent.ins
```

then run `mktexlsr`. To produce the documentation with source code run `arara spintent.dtx`.

## Examples

The file <code>&langle;spintent.pdf&rangle;</code> contains attached examples, which can be extracted
from the PDF viewer or from the command line by running:

```
$ pdfdetach -saveall spintent.pdf
```

and then you can use the excellent `arara` tool to compile them.

## License

The <code>&langle;spintent&rangle;</code> package may be modified and distributed under the terms and
conditions of the [LaTeX Project Public License](https://www.latex-project.org/lppl/), version 1.3c or greater.

## Contents

- README.md \(this file\)
- spintent.pdf \(documentation\)
- spintent.dtx \(master file that produced all files\)
- spintent.ins \(installer to extract all files\)

## Author and copyright

Copyright &#169; 2026 by Pablo González L <pablgonz@educarchile.cl>
