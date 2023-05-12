# Instructions for replication

The project is structured as a code pipeline consisting of `build`, `analysis` and `paper` code. 

The `build` and `analysis` folders each contain an `SConstruct` file which specifies the dependencies between the code files in that folder.
If you have the Open Source build utility [SCons](https://scons.org/pages/download.html) installed on your computer, you can conveniently run all the code in the correct order from the command line by following these steps:
- CREATE SYMLINKS ELSE IT WILL NOT WORK (consider going for a full `drive` approach to avoid this)
- `cd` to the repository.
- Enter `scons` into the command line. 

If you do not wish to use SCons, you can also run the code in the correct order manually. 
I added comments with natural-language instructions to the `SConstruct` files for that purpose.

After creating tables and figures, open `paper.tex` in your LaTeX editor of choice and compile. This will output the thesis in PDF format.
