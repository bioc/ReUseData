[![R-CMD-check](https://github.com/rworkflow/ReUseData/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/rworkflow/ReUseData/actions/workflows/R-CMD-check.yaml)

# Introduction

ReUseData is an _R/Bioconductor_ software tool to provide a systematic
and versatile approach for standardized and reproducible data
management. ReUseData facilitates transformation of shell or other ad
hoc scripts for data preprocessing into workflow-based data
recipes. Evaluation of data recipes generate curated data files in
their generic formats (e.g., VCF, bed). Both recipes and data are
cached using database infrastructure for easy data management and
reuse. Prebuilt data recipes are available through ReUseData portal
("https://rcwl.org/dataRecipes/") with full annotation and user
instructions. Pregenerated data are available through ReUseData cloud
bucket that is directly downloadable through "getCloudData()".

This quick start shows the basic use of package functions in 2 major
categories for managing:

- Data recipes
- Reusable data 

Details for each section can be found in the other vignettes
`ReUseData_recipe.html` and `ReUseData_data.html`.

# Package installation

```
BiocManager::install(c("ReUseData", "Rcwl"))
library(ReUseData)
```

# Data recipes 

All pre-built data recipes are included in the package and can be
easily updated (`recipeUpdate`), searched (`recipeSearch`) and loaded
(`recipeLoad`). Details about data recipes can be found in the
vignette `ReUseData_recipe.html`.

## Search and load a data recipe

```
recipeUpdate(cachePath = "ReUseDataRecipe", force = TRUE)
recipeSearch("echo")
recipeLoad("echo_out", return = TRUE)
```

## Evaluate a data recipe

A data recipe can be evaluated by assigning values to the recipe
parameters. `getData` runs the recipe as a CWL scripts internally, and
generates the data of interest with annotation files for future reuse.

```
Rcwl::inputs(echo_out)
echo_out$input <- "Hello World!"
echo_out$outfile <- "outfile"
outdir <- file.path(tempdir(), "SharedData")
res <- getData(echo_out,
               outdir = outdir,
               notes = c("echo", "hello", "world", "txt"))
res$out
readLines(res$out)
```

## Create your own data recipes

One can create a data recipe from scratch or by converting an existing
shell script for data processing, by specifying input parameters,
output globbing patterns using `recipeMake` function.

```
script <- system.file("extdata", "echo_out.sh", package = "ReUseData")
rcp <- recipeMake(shscript = script,
                  paramID = c("input", "outfile"),
                  paramType = c("string", "string"),
                  outputID = "echoout",
                  outputGlob = "*.txt")
Rcwl::inputs(rcp)
Rcwl::outputs(rcp)
```

# Reusable data 

The data that are generated from evaluating data recipes are
automatically annotated and tracked with user-specified keywords and
time/date tags. It uses a similar cache system as for recipes for
users to easily update (`dataUpdate`), search (`dataSearch`) and use
(`toList`). 

Pre-generated data files from existing data recipes are saved in
Google Cloud Bucket, that are ready to be queried
(`dataSearch(cloud=TRUE)`) and downloaded (`getCloudData`) to local
cache system with annotations. 

## Update data files that are generated using `ReUseData`

```
dh <- dataUpdate(dir = outdir)
dataSearch(c("echo", "hello"))
dataNames(dh)
dataParams(dh)
dataNotes(dh)
```

## Export data into workflow-ready files

```
toList(dh, format="json", file = file.path(outdir, "data.json"))
```

## Download pregenerated data from Google Cloud

```
dh <- dataUpdate(dir = outdir, cloud = TRUE)
getCloudData(dh[2], outdir = outdir)
```
