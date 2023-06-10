
from SCons.Script import Command

###############################################################################
###                                PREAMBLE                                 ###
###############################################################################

# Assigning input file paths to variables for convenience
build_inputs_path = "drive/raw/base/"
raw_cities = build_inputs_path + "cities_families_1300_1918.dta"
raw_construction = build_inputs_path + "construction_all_xl.csv"
raw_conflict = build_inputs_path + "conflict_incidents.csv"

# Assigning utility script paths to variables for convenience
# (varnames in CamelCase to be distinguishable from data)
HandleCommandArgs = "source/utils/HandleCommandArgs.R"
DropNACount = "source/utils/DropNACount.R"
GetAssignment = "source/utils/GetAssignment.R"
GetStackedData = "source/utils/GetStackedData.R"

# Scripts that will be sourced from the build lib:
ConstructionLib = "source/build/lib/ProcessConstruction.R"
ConflictLib = "source/build/lib/ProcessConflict.R"


###############################################################################
###                          BUILDING THE DATASET                           ###
###############################################################################

# This builds the territorial history data, sans construction and conflict
switches = Command('drive/derived/cities_switches.csv',   # target path (output file)
    [raw_cities, 'source/build/Switches.R'],              # source paths (input files)
    'Rscript source/build/Switches.R')                    # command line string


for t in [100, 50, 10, 1]:

    # This builds the full data, in multiple versions aggregated to different period lengths t

    build_target = f'drive/derived/cities_data_{t}y.csv'
    build_command = f'Rscript source/build/Aggregate.R {t}'

    build = Command(build_target,
                    [switches, 
                     ConstructionLib, ConflictLib, HandleCommandArgs,
                     "source/build/Aggregate.R"],
                    build_command)
    
    # regression should continue here, in the same for loop

    ###############################################################################
    ###                OUTPUTTING REGRESSION TABLES AND FIGURES                 ###
    ###############################################################################

