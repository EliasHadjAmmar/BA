# Instructions for replication

The project is structured as a code pipeline consisting of `build`, `analysis` and `paper` code. 
The `build` and `analysis` folders each contain an `SConstruct` file specifying the dependencies and order of execution of code files.
If you have the Open Source build utility [SCons](https://scons.org/pages/download.html) installed on your computer, you can conveniently run the code in the correct order from the command line by following these steps:
- `cd` to the `build` folder.
- Enter `SCONS` into the command line. This will output the data set.
- `cd` to the `analysis` folder.
- Enter `SCONS` into the command line. This will output regression tables and figures.
- Open `paper.tex` in your LaTeX editor of choice and compile. This will output the thesis in PDF format.

If you do not wish to use SCons, it is of course possible to run the individual code files manually.
