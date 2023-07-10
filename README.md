## Structure of the repo

- `source`: contains all code.
  - `source/build` assembles the dataset.
  - `source/analysis` runs regressions and creates tables, figures and maps.
  - `source/utils` contains utility code that is used by multiple scripts.
  - `source/slides` contains code that I added after the submission (for my presentation slides, WIP)
- `paper`: contains all materials for compiling PDFs.
  - `paper/output`: contains figures, tables and maps created by code in `source`.
  - `paper/paper.tex`: compiles into the submitted PDF.
  - `paper/references.bib`: bibliography (I don't cite every paper in it)
  - `paper/slides.tex`: not part of my submission, compiles into my presentation slides (WIP).
- `drive`: contains data and literature.
  - `drive/raw`: raw datasets from which I build everything else.
  - `drive/derived`: my data build(s).
  - `drive/literature`: downloaded PDFs of papers I cite (and some more I don't cite).

## Instructions for replication

The easiest way to replicate my paper is to install the open-source build utility [SCons](https://scons.org/pages/download.html), which I use. SCons relies on a `SConstruct` file in the root directory of the project which functions like a blueprint and tracks the dependencies between code, data, and output files. With SCons installed, running the entire pipeline in the correct order is a breeze:
- clone this repo to your computer.
- move the `drive` folder from Dropbox into the `BA` root directory.
- at the beginning of every R script in `BA/source`, change the `setwd("~/GitHub/BA")` to the correct file path if necessary.
- open the command line / Terminal and `cd` to the `BA` root directory.
- Enter `scons` into the command line. This will automatically execute the whole pipeline in the correct order.

Tables, figures, and maps are written to `BA/paper/output`. The submitted PDF was separately compiled from `BA/paper/paper.tex`.

