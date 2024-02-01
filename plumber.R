# This is a Plumber API. In RStudio 1.2 or newer you can run the API by
# clicking the 'Run API' button above.

library(DBI)
library(dbplyr)
library(dplyr)
library(duckdb)
library(fs)
library(geojsonsf)
library(glue)
library(here)
library(jsonlite)
library(leaflet)
library(librarian)
library(listviewer)
library(mapview)
library(plumber)
library(readr)
library(sf) # install.packages('sf', repos = c('https://r-spatial.r-universe.dev'))
library(stringr)
library(terra)
library(tibble)
# renv::snapshot()

# See [functions.R](https://github.com/marinebon/aquamapsduckdb/blob/main/inst/app/functions.R)
source(here("../aquamapsduckdb/inst/app/functions.R"))
# TODO: migrate functions into dedicated R package

# duckdb connection to AquaMaps ----
dir_bigdata     <- ifelse(
  Sys.info()[["sysname"]] == "Linux",
  "/share/data/aquamapsduckdb",
  "/Users/bbest/My Drive/projects/msens/data")
path_am         <- glue("{dir_bigdata}/am.duckdb")
dir_data        <- here("tmp")
nspp_tif        <- glue("{dir_data}/am_nspp.tif")
nspp_3857_tif   <- glue("{dir_data}/am_nspp_3857.tif")

stopifnot(file.exists(path_am))
con_am <- dbConnect(
  duckdb(
    dbdir     = path_am,
    read_only = T))
# dbDisconnect(con_am, shutdown = TRUE)

#* @apiTitle MarineBON APIs

serializers <- list(
  "json" = serializer_json(),
  "csv"  = serializer_csv(),
  "rds"  = serializer_rds())

#* Get species present for a given geography
#* @param gid geographic identifier (`gid`), such as for ProtectedSeas.net (e.g. `PSGID:939` for [Tortugas Ecological Reserve | ProtectedSeas.net](https://map.navigatormap.org/site-detail?site_id=939)) or MarineRegions.org (e.g. `MRGID:8439` for [Pitcairn Exclusive Economic Zone | MarineRegions.org](https://www.marineregions.org/gazetteer.php?p=details&id=8439))
#* @param species_db The species database from which to extract for the given geography. So far, only `aquamapsdata_2019-10` is available, which uses the species suitability from [AquaMaps.org](https://AquaMaps.org) (_version 10/2019_) as contained in in the [aquamapsdata](https://raquamaps.github.io/aquamapsdata/articles/intro.html#data-scope-and-content-1) R package (and converted into [aquamapsduckdb](https://github.com/marinebon/aquamapsduckdb)).
#* @param format The desired output format, one of: `json` (default; JavaScript Object Notation), `csv` (comma-seperated values table), or `rds` (R data serialization format).
#* @get /species_by_geography
function(gid = "PSGID:939", species_db = "aquamapsdata_2019-10", format = "json", res){

  g_db <- str_split_i(gid, ":", 1)
  g_id <- str_split_i(gid, ":", 2)

  g_dbs <- c("PSGID")  # TODO: Add "MRGID" for MarineRegions.org
  if (!g_db %in% g_dbs)
    stop(paste0("ERROR: Provided `gid` '", g_db, "' is not found in available geographic databases: '", paste(g_dbs, collapse = "', '"), "'."))

  if (!format %in% names(serializers))
    stop(paste0("ERROR: Provided `format` '", format, "' is not found in available formats: '", paste(names(serializers), collapse = "', '"), "'."))

  res$serializer <- serializers[[format]]

  # TODO: Add get_mrply() for MarineRegions.org to functions.R
  ply <- get_psply(g_id)

  am_spp_in_ply(ply) |>
    rename(avg_suitability = avg_probability)
}

#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @serializer png
#* @get /plot
function(){
  rand <- rnorm(100)
  hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b){
  as.numeric(a) + as.numeric(b)
}

# / home redirect ----
#* redirect to docs
#* @get /
#* @serializer html
function(req, res) {
  res$status <- 303 # redirect
  res$setHeader("Location", "./__docs__/")
  "<html>
  <head>
    <meta http-equiv=\"Refresh\" content=\"0; url=./__docs__/\" />
  </head>
  <body>
    <p>For documentation on this API, please visit <a href=\"http://api.marinebon.app/__docs__/\">http://api.marinebon.app/__docs__/</a>.</p>
  </body>
</html>"
}
