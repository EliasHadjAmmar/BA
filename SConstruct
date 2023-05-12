
from SCons.Script import Command

# Assigning input file paths to variables for convenience
raw_rulers = "build/input/families_rulers_imputed.dta"
raw_construction = "build/input/construction_all_xl.csv"
raw_cities = "build/input/cities_families_1300_1918.dta"
raw_territories = "build/input/territories.csv"
raw_wages = "build/input/clean_crafts.xlsx"
destatis1881 = "build/input/destatis1881.csv"
city_locations = "build/input/city_locations.csv"
territory_codes = "build/input/territory_codes.csv"

# Assigning utility script paths to variables for convenience
# (varnames in CamelCase to be distinguishable from data)
DropNACount = "utils/DropNACount.R"
BaselineSample = "utils/BaselineSample.R"
AggregateYears = "utils/AggregateYears.R"
GetStackedData = "utils/GetStackedData.R"


###############################################################################
###                          BUILDING THE DATASET                           ###
###############################################################################

# This builds the list of extinction events
rulers = Command('build/temp/rulers.csv',        # target path (output file)
    [raw_rulers, 'build/code/Rulers.R'],         # source paths (input files)
    'Rscript build/code/Rulers.R')               # command line string

extinctions_rulers = Command('build/temp/last_rulers.csv',
    [rulers, 'build/code/ExtinctionsRulers.R'],
    'Rscript build/code/ExtinctionsRulers.R')

extinctions_terrs = Command('build/temp/ext_terrs.csv',
    [raw_territories, 'build/code/ExtinctionsTerritories.R'],
    'Rscript build/code/ExtinctionsTerritories.R')

extinctions = Command('build/output/extinctions.csv',
    [extinctions_rulers, extinctions_terrs, 'build/code/CombineExtinctions.R'],
    'Rscript build/code/CombineExtinctions.R')


# This builds the lineages-level dataset
terr_sizes = Command('build/temp/terr_sizes.csv',
    [raw_cities, 'build/code/LineageSize.R'],
    'Rscript build/code/LineageSize.R')

lineages = Command('build/output/lineages.csv',
    [territory_codes, terr_sizes, extinctions, 'build/code/CombineLineageData.R'],
    'Rscript build/code/CombineLineageData.R')


# This builds the city-level dataset
construction = Command('build/temp/construction_new.csv',
    [raw_construction, 'build/code/Construction.R'],
    'Rscript build/code/Construction.R')

cities1875 = Command('build/temp/cities1875.csv',
    [city_locations, destatis1881, 'build/code/Population1875.R'],
    'Rscript build/code/Population1875.R')

wages = Command('build/temp/wages.csv',
    [raw_wages, 'build/code/Wages.R'],
    'Rscript build/code/Wages.R')

cities = Command('build/output/cities.csv',
    [raw_cities, city_locations, construction, cities1875, wages, 'build/code/CombineCityData.R'],
    'Rscript build/code/CombineCityData.R')


# This builds the full dataset
build_full = Command('build/output/build_full.csv',
    [cities, lineages, 'build/code/CombineAll.R'],
    'Rscript build/code/CombineAll.R')

build = Command('build/output/build.csv',
    [build_full, DropNACount, 'build/code/CleanBuild.R'],
    'Rscript build/code/CleanBuild.R')


###############################################################################
###                OUTPUTTING REGRESSION TABLES AND FIGURES                 ###
###############################################################################

baseline_did = Command('analysis/output/tables/baseline_did.tex',
    [build, BaselineSample, 'analysis/code/baseline/BaselineDiD.R'],
    'Rscript analysis/code/baseline/BaselineDiD.R')

baseline_did_countdiff = Command('analysis/output/tables/baseline_did_countdiff.tex',
    [build, BaselineSample, 'analysis/code/baseline/BaselineDiD_countdiff.R'],
    'Rscript analysis/code/baseline/BaselineDiD_countdiff.R')

# baseline_es = Command('analysis/output/tables/???.png',
#     [build, BaselineSample, AggregateYears, 'analysis/code/baseline/BaselineEventStudy.R'],
#     'Rscript analysis/code/BaselineEventStudy.R')

assignment = Command('analysis/temp/assignment.csv',
    [build, extinctions, 'analysis/code/stacked/GetSubExps.R'],
    'Rscript analysis/code/stacked/GetSubExps.R')

stacked_did = Command('analysis/output/tables/stacked_did.tex',
    [build, extinctions, assignment, GetStackedData, 'analysis/code/stacked/StackedDiD.R'],
    'Rscript analysis/code/stacked/StackedDiD.R')