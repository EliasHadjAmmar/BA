# Instructions for replication

The `SConstruct` file specifies the dependencies between the code, data and utility files. The easiest way to replicate the results is to install the Open Source build utility [SCons](https://scons.org/pages/download.html), which I use. Once you have it on your computer, you can conveniently run all the code in the correct order from the command line by following these steps:
- change the `setwd("~/GitHub/BA")` to the file path of this folder on your machine.
- open the command line / Terminal and open this folder.
- Enter `scons` into the command line. 

After creating tables and figures, open `paper.tex` in your LaTeX editor of choice and compile. This should output the thesis in PDF format.
