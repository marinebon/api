# This is a Plumber API. In RStudio 1.2 or newer you can run the API by
# clicking the 'Run API' button above.

library(fs)
library(geojsonsf)
library(glue)
library(here)
library(jsonlite)
library(leaflet)
library(listviewer)
library(mapview)
library(plumber)
library(sf) # install.packages('sf', repos = c('https://r-spatial.r-universe.dev'))
library(stringr)
# renv::snapshot()

#* @apiTitle MarineBON APIs

#* Echo back the input
#* @param msg Return species present given ProtectedSeas ID
#* @get /psgid
function(psgid=""){
  # https://map.navigatormap.org/api/boundary/area/?gid=36
  # psgid = 36

  get_psply <- function(
    psgid,
    dir_cache = here::here("tmp"),
    url_pfx   = "https://map.navigatormap.org/api/boundary/area/?gid=",
    redo      = FALSE){
    # psgid = 36

    geo <- glue::glue("{dir_cache}/psgid_{psgid}.geojson")

    if (!file.exists(geo) | redo) {
      ply_url <- paste0(url_pfx, psgid)

      suppressWarnings({
        readLines(ply_url) |>
        stringr::str_replace('\\{"bounds":(.*)\\}', '\\1') }) |>
        geojsonsf::geojson_sf() |>
        sf::st_zm(drop = TRUE) |>
        sf::st_write(geo, delete_dsn = T)
    }

    st_read(geo, quiet = T)
  }

  ply <- get_psply(psgid)
  mapview::mapView(ply)



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
