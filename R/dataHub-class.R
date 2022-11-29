################
## dataHub
################

#' dataHub
#'
#' `dataHub` class, constructor, and methods. 
#' @rdname dataHub-class 
#' @exportClass dataHub
dataHub <- setClass("dataHub", contains = "cwlHub")

#' @rdname dataHub-class
#' @param BFC A BiocFileCache object created for data and recipes.
#' @return dataHub: a `dataHub` object.
#' @importClassesFrom RcwlPipelines cwlHub
#' @export
dataHub <- function(BFC){
    cwlh <- RcwlPipelines:::cwlHub(BFC)
    new("dataHub", cwlh)
}

## Methods
## 'mcols()' inherited from cwlHub, returns a DataFrame with all info including bfcmeta(bfc, "dataMeta"). 
## 'title()' inherited to return the 'rname' column in mcols(cwlHub). Here use `dataName()`

#' @rdname dataHub-class
#' @param object A `dataHub` object
#' @importFrom S4Vectors mcols get_showHeadLines get_showTailLines
#' @importMethodsFrom RcwlPipelines mcols
#' @exportMethod show
#' @examples
#' dataSearch()
#' dd <- dataSearch("reference", "38", "1000g"))
#' dataNames(dd)
#' dataParams(dd)
#' dataNotes(dd)
#' dataTags(dd)
#' toList(dd)
#' toList(dd, format = "json")
#' toList(dd, format = "yaml")


setMethod("show", "dataHub", function(object){
    rid <- object@rid
    mc <- mcols(object)

    cat("dataHub with", length(rid), "records\n")
    cat("cache path: ", bfccache(object), "\n")
    ## mdate <- tail(sort(as.Date(mc$mtime)), 1)
    ## cat("# last modified date: ", as.character(mdate), "\n")
    cat("# dataUpdate() to update the local data cache\n")
    cat("# dataSearch() to query a specific dataset\n")
    ## cat("# additional mcols(): rid, rpath, params, notes, version, date, tag, ...\n")
    cat("# Additional information can be retrieved using: \n")
    cat("# dataNames(), dataParams(), dataNotes(), dataPaths(), dataTag() or mcols()\n")
    ## https://github.com/Bioconductor/AnnotationHub/blob/master/R/Hub-class.R#L602
    .some <-
        function(elt, nh, nt, fill="...", width=getOption("width") - 13L)
    {
        answer <- if (length(elt) < nh + nt + 1L)
                      elt
                  else
                      c(head(elt, nh), fill, tail(elt, nt))
        ifelse(nchar(answer) > width,
               sprintf("%s...", substring(answer, 1L, width-3L)),
               answer)
    }
    if (length(rid) > 0) {
        nhead <- get_showHeadLines()
        ntail <- get_showTailLines()
        rownames <- paste0("  ", .some(rid, nhead, ntail))
        out <- matrix(c(.some(rep("|", length(rid)), nhead, ntail, fill=""),
                        .some(mc$rname, nhead, ntail),
                        ## .some(mc$params, nhead, ntail),
                        .some(mc$fpath, nhead, ntail)),
                      ncol=3L,
                      ## dimnames=list(rownames, c("", "name", "params", "Path")))
                      dimnames=list(rownames, c("", "name", "Path")))
        cat("\n")
        print(out, quote=FALSE, right=FALSE)
    }
})

#' @rdname dataHub-class
#' @return dataNames: the names of datasets in `dataHub` object.
#' @export
dataNames <- function(object){
    mcols(object)$rname
}

#' @rdname dataHub-class
#' @return dataParams: the data recipe parameter values for datasets in `dataHub` object.
#' @export
dataParams <- function(object){
    mcols(object)$params
}

#' @rdname dataHub-class
#' @return dataNotes: the notes of datasets in `dataHub` object.
#' @export
dataNotes <- function(object){
    mcols(object)$notes
}

#' @rdname dataHub-class
#' @return dataPaths: the file paths of datasets in `dataHub` object.
#' @export
dataPaths <- function(object){
    bfcinfo(object)$fpath
}
 
#' @rdname dataHub-class
#' @aliases dataTags
#' @param object A `dataHub` object.
#' @return dataTags: the tags of datasets in `dataHub` object.
#' @export
setGeneric("dataTags", function(object)standardGeneric("dataTags"))

#' @rdname dataHub-class
setMethod("dataTags", "dataHub", function(object) {
    if("tag" %in% colnames(mcols(object))){
        mcols(object)$tag
    }else{
        NULL
    }
})

#' @rdname dataHub-class
#' @param value The tag values to assign to datasets in `dataHub` object.
#' @param append Whether to append new tag or replace all tags.
#' @export
setGeneric("dataTags<-", function(object, append=TRUE, value)
    standardGeneric("dataTags<-"))

#' @rdname dataHub-class
setReplaceMethod("dataTags", "dataHub", function(object, append=FALSE, value){
    if(append){
        value <- paste0(dataTags(object), value)
    }
    dm <- bfcmeta(object, "dataMeta")
    idx <- match(object@rid, dm$rid)
    dm$tag[idx] <- value
    bfc <- BiocFileCache(object@cache, ask = FALSE)
    bfcmeta(bfc, "dataMeta", overwrite = TRUE) <- dm
    return(object)
})

#' subset dataHub
#' @rdname dataHub-class
#' @param x A `dataHub` object.
#' @param i The integer index of the `dataHub` object.
#' @export
setMethod("[", c("dataHub"), function(x, i) {
    rids <- x@rid[i]
    return(x[rids])
})
setGeneric("[")

#' combine dataHub
#' @rdname dataHub-class
#' @param x A `dataHub` object to be combined.
#' @param ... More `dataHub` objects to combine.
#' @export
setMethod("c", c("dataHub"), function(x, ...) {
    object <- list(x, ...)
    rids <- unlist(lapply(object, function(x)x@rid))
    x@rid <- unique(rids)
    return(x)
})
setGeneric("c")

#' dataHub to list
#' @rdname dataHub-class
#' @param x A `dataHub` object.
#' @param format can be "list", "json" or "yaml". Supports partial
#'     match. Default is list.
#' @param type The type of workflow input list, such as cwl.
#' @return toList: A list of datasets in specific format.
#' @export
#' 
toList <- function(x, format = c("list", "json", "yaml"), type = NULL){
    format <- match.arg(format)
    ## tl <- dataNames(x)
    pth <- dataPaths(x)
    if(!is.null(type) && type == "cwl"){
        dtype <- unlist(lapply(pth, function(x)file.info(x)$isdir))
        dtype <- ifelse(dtype, "Directory", "File")
        dl <- vector("list", length(pth))
        for(i in 1:length(pth)){
            dl[[i]] <- list(class = dtype[i],
                            path = pth[i])
        }
    } else {
        dl <- as.list(pth)
        names(dl) <- dataNames(x)
        if (format == "json") {
            dl <- jsonlite::toJSON(dl, pretty = TRUE, auto_unbox = TRUE)
        } else if (format == "yaml") {
            dl <- yaml::as.yaml(dl)
        }
    }
    return(dl)
}