
from SCons.Script import Command

###############################################################################
###                                PREAMBLE                                 ###
###############################################################################

# Assigning input file paths to variables for convenience
build_inputs_path = "drive/raw/base/"
raw_cities = build_inputs_path + "cities_families_1300_1918.dta"
raw_construction = build_inputs_path + "construction_all_xl.csv"
raw_conflict = build_inputs_path + "conflict_incidents.csv"
raw_population = "drive/raw/population/bairoch1988.csv"

# Assigning utility script paths to variables for convenience
# (varnames in CamelCase to be distinguishable from data)
HandleCommandArgs = "source/utils/HandleCommandArgs.R"
DropNACount = "source/utils/DropNACount.R"
GetAssignment = "source/utils/GetAssignment.R"
GetStackedData = "source/utils/GetStackedData.R"
DataPrepSuite = "source/utils/DataPrepSuite.R"
etableDefaults = "source/utils/etableDefaults.R"

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


# This produces a subset of Bairoch (1988)'s population data, matched to city_ids.
population = Command('drive/derived/population.csv',
    [raw_population, 'source/build/population/MatchBairoch.R'],
    'Rscript source/build/population/MatchBairoch.R')


for t in [100, 50, 10, 1]:

    # This builds the full data, in multiple versions aggregated to different period lengths t
    script = "source/build/Aggregate.R"
    target = f'drive/derived/cities_data_{t}y.csv'
    build = Command(target, # target path
                    [switches, script, # data and code
                     ConstructionLib, ConflictLib, HandleCommandArgs], # auxiliary code
                    f'Rscript {script} {t}') # command line string
    
    ###############################################################################
    ###                OUTPUTTING REGRESSION TABLES AND FIGURES                 ###
    ###############################################################################

    # Continues in the for-loop because I often want to run them on multiple builds

    # This replicates Fig. 5 in Schoenholzer and Weese (2022), with t = (50, 100)
    if t in [50, 100]:
        script = "source/analysis/baseline/ReplicateSW22.R"
        target = f'paper/output/regressions/SW22_replication_{t}y.png'
        SW_rep = Command(target, 
                         [build, script, 
                          HandleCommandArgs, DataPrepSuite, etableDefaults], 
                         f'Rscript {script} {t}')
    
    # This produces the baseline regression.
    script = "source/analysis/baseline/Baseline.R"
    target = f'paper/output/regressions/baseline_{t}y.tex'
    baseline = Command(target, 
                        [build, script, 
                        HandleCommandArgs, DataPrepSuite, etableDefaults], 
                        f'Rscript {script} {t}')
    
    # This produces the baseline regression with the post-window limited to 200 years.
    script = "source/analysis/baseline/Window.R"
    target = f'paper/output/regressions/window_{t}y.tex'
    window = Command(target,
                     [build, script,
                      HandleCommandArgs, DataPrepSuite, etableDefaults],
                      f'Rscript {script} {t}')