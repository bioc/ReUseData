% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/meta.R
\name{meta_data}
\alias{meta_data}
\title{meta_data}
\usage{
meta_data(dir = "", cleanup = FALSE, checkData = TRUE)
}
\arguments{
\item{dir}{The path to the shared data folder.}

\item{cleanup}{If remove any invalid intermediate files. Default is
FALSE. In cases one data recipe (with same parameter values)
was evaluated multiple times, the same data file(s) will match
to multiple intermediate files (e.g., .yml). \code{cleanup} will
remove older intermediate files, and only keep the most recent
ones that matches the data file. When there are any
intermediate files that don't match to any data file, \code{cleanup}
will also remove those.}

\item{checkData}{check if the data (listed as "# output: " in the
yml file) exists. If not, do not include in the output csv
file. This argument is added for internal testing purpose.}
}
\value{
a \code{data.frame} with yml file name, parameter values, data
file paths, date, and user-specified notes when generating the
data with \code{getData()}.
}
\description{
Functions to generate the meta csv file for local cached dataset.
}
\examples{
outdir <- file.path(tempdir(), "SharedData")
meta_data(outdir)
}
