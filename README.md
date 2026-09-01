## spintent — Spanish parse intent
![GitHub release (latest by date)](https://img.shields.io/github/v/release/pablgonz/spintent?label=version)
![GitHub Release Date](https://img.shields.io/github/release-date/pablgonz/spintent)
![GitHub last commit](https://img.shields.io/github/last-commit/pablgonz/spintent)

## Descripción

El paquete <code>&langle;spintent&rangle;</code> proporciona una serie de utilidades para docentes de educación
primaria y secundaria que necesiten crear documentos `PDF` _accesibles_ \(_tagged_ PDF\)
en español utilizando `LuaLaTeX`.

## Requerimientos

El requisito mínimo es la realización de `LaTeX` 2026-11-01. Se carga y depende de una versión actualizada de [unicode-math](https://ctan.org/pkg/unicode-math).

## Instalación

El paquete <code>&langle;spintent&rangle;</code> está disponible en [TeX Live](https://www.tug.org/texlive/) y [MiKTeX](https://miktex.org/), utilice el gestor
de paquetes de su distribución para instalarlo.

Para una instalación manual, descargue [spintent.zip](http://mirrors.ctan.org/macros/latex/contrib/spintent.zip) descomprímalo y luego
ejecute:

```
$ luatex spintent.ins
```

y mueva todos los archivos a las ubicaciones correspondientes:

```
  spintent.sty  ->  TDS:tex/lualatex/spintent/spintent.sty
  spintent.lua  ->  TDS:tex/lualatex/spintent/spintent.lua
  spintent.pdf  ->  TDS:doc/lualatex/spintent/spintent.pdf
  README.md     ->  TDS:doc/lualatex/spintent/README.md
  spintent.dtx  ->  TDS:source/lualatex/spintent/spintent.dtx
  spintent.ins  ->  TDS:source/lualatex/spintent/spintent.ins
```

luego ejecute `mktexlsr`. Para generar la documentación con el código fuente, ejecute `arara spintent.dtx`.

## Ejemplos

El archivo <code>&langle;spintent.pdf&rangle;</code> contiene ejemplos adjuntos, los cuales se pueden extraer
desde el visor de PDF o desde la línea de comandos ejecutando:

```
$ pdfdetach -saveall spintent.pdf
```

y luego puede utilizar la excelente herramienta `arara` para compilarlos.

## Desarrollo

Se garantiza que los números de versión y las fechas son correctos en el repositorio en el
archivo de configuración de `l3build` llamado `build.lua`.

El formato de la fecha es `AAAA-MM-DD`. Si para usted es importante que los archivos creados
tengan la versión y la fecha correctas, debe ejecutar `l3build tag` antes de cualquier otra
tarea relacionada con la compilación.

Puede ejecutar:

- `l3build unpack` para extraer los archivos de código en el directorio `build/unpacked/`.
- `l3build doc` para generar la documentación.
- `l3build install`  para colocar todos los archivos en su `TEXMFHOME`.
- `l3build uninstall` desinstalará los archivos de `TEXMFHOME`.
- `l3build testpkg` para ejecutar los archivos de prueba.
- `l3build examples` para compilar los archivos de ejemplo.

## Licencia

El paquete <code>&langle;spintent&rangle;</code> se puede modificar y distribuir bajo los términos y condiciones de la
[LaTeX Project Public License](https://www.latex-project.org/lppl/), versión 1.3c o superior.

## Contenido del Respositorio

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

Copyright &#169; 2026 por Pablo González L <pablgonz@educarchile.cl>
