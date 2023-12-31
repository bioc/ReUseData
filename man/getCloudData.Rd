% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getCloudData.R
\name{getCloudData}
\alias{getCloudData}
\title{getCloudData Download the pregenerated curated data sets from
ReUseData cloud bucket}
\usage{
getCloudData(datahub, outdir = character())
}
\arguments{
\item{datahub}{The \code{dataHub} object returned from \code{dataSearch()}
with 1 data record available on ReUseData cloud bucket.}

\item{outdir}{The output directory for the data (and concomitant
annotation files) to be downloaded. It is recommended to use a
new folder under a shared folder for a new to-be-downloaded
data.}
}
\value{
Data and concomitant annotation files will be downloaded to
the user-specified folder that is locally searchable with
\code{dataSearch()}.
}
\description{
getCloudData Download the pregenerated curated data sets from
ReUseData cloud bucket
}
\examples{
outdir <- file.path(tempdir(), "gcpData")
dh <- dataSearch(c("ensembl", "GRCh38"))
dh <- dh[grep("http", dataPaths(dh))]

## download data from google bucket
getCloudData(dh[1], outdir = outdir)

## Update local data caching
dataUpdate(outdir)  ## no "cloud=TRUE" here, only showing local data cache

## Now the data is available to use locally 
dataSearch(c("ensembl", "GRCh38"))

}
