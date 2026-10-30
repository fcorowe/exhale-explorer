# Adapt the repository's standalone dashboard to the available local inputs.
args <- commandArgs(trailingOnly = FALSE)
script <- normalizePath(sub("^--file=", "", args[grepl("^--file=", args)][1]))
here <- dirname(script)
project <- here
repo <- here
data_root <- Sys.getenv("EXHALE_DATA_ROOT", unset = "")
if (!nzchar(data_root) || !dir.exists(data_root)) {
  stop("Set EXHALE_DATA_ROOT to the Consolidated-Datasets folder containing <pollutant>/UK-Upper-Geogs CSV inputs. Hosting the existing HTML does not require these inputs.")
}
data_root <- normalizePath(data_root)
resources <- file.path(here, "resources")
preview <- file.path(here, "preview")
dir.create(preview, showWarnings = FALSE)

for (pkg in c("sf", "dplyr", "jsonlite", "viridisLite", "digest")) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Missing R package: ", pkg)
}
suppressPackageStartupMessages(library(sf))
suppressPackageStartupMessages(library(dplyr))

required_resources <- c("ew-msoa-2021-full.geojson", "scotland-iz-2022-full.geojson",
                        "ni-sdz-2021.geojson", "ne_10m_lakes.shp", "ne_10m_lakes_europe.shp",
                        "leaflet.js", "leaflet.css")
if (!all(file.exists(file.path(resources, required_resources)))) {
  stop("First run: python3 fetch-resources.py")
}

read_boundaries <- function(filename, code, name, country = NULL) {
  x <- sf::st_read(file.path(resources, filename), quiet = TRUE)
  stopifnot(code %in% names(x), name %in% names(x))
  x$geog_code <- as.character(x[[code]])
  x$geog_name <- as.character(x[[name]])
  x$country <- if (is.null(country)) {
    ifelse(startsWith(x$geog_code, "E"), "England", "Wales")
  } else country
  x <- x[, c("geog_code", "geog_name", "country")]
  sf::st_transform(x, 4326)
}

geoms <- bind_rows(
  read_boundaries("ew-msoa-2021-full.geojson", "MSOA21CD", "MSOA21NM"),
  read_boundaries("scotland-iz-2022-full.geojson", "IZCode", "IZName", "Scotland"),
  read_boundaries("ni-sdz-2021.geojson", "SDZ2021_cd", "SDZ2021_nm", "Northern Ireland")
)
stopifnot(nrow(geoms) == 9448L, !anyDuplicated(geoms$geog_code),
          !any(sf::st_is_empty(geoms)))

pollutants <- c("Benzene", "NO2", "PM2.5", "PM10", "SO2", "O3")
paths <- setNames(vapply(pollutants, function(poll) {
  file.path(data_root, poll,
            "UK-Upper-Geogs", paste0("UK-Upper-Geogs-Consolidated-Dataset-", poll,
                                     "-2021-&-2022.csv"))
}, character(1)), pollutants)
input_checks <- list()

read_pollutant <- function(poll) {
  x <- read.csv(paths[[poll]], check.names = FALSE, stringsAsFactors = FALSE)
  common <- c("geog_code", "geog_name", "region_name", "country", "year", "quantile_rank")
  columns <- c(area_weighted_mean_indicator = paste0("area_weighted_mean_", poll))
  if (poll == "O3") {
    columns <- c(columns, exposed_1_plus_days_indicator = "at_least_1_day_exposed_to_O3_above_120_ug")
  } else {
    threshold <- switch(poll, Benzene = "above_European_Commission_threshold",
                        SO2 = "above_DEFRA_threshold", "above_WHO_threshold")
    columns <- c(columns, PWE_indicator = paste0("PWE_to_", poll),
                 above_threshold_indicator = threshold)
  }
  counts <- c("exposed_age_15_under", "total_age_15_under", "exposed_age_65_plus", "total_age_65_plus", "total_population_count")
  missing <- setdiff(c(common, unname(columns), counts), names(x))
  if (length(missing)) stop(poll, ": missing columns: ", paste(missing, collapse = ", "))
  stopifnot(nrow(x) == 9448L, !anyDuplicated(x$geog_code),
            setequal(x$geog_code, geoms$geog_code))
  index <- match(x$geog_code, geoms$geog_code)
  stopifnot(all(x$country == geoms$country[index]),
            all(x$year == ifelse(x$country == "Scotland", 2022L, 2021L)))
  input_checks[[poll]] <<- list(
    path = file.path(poll, "UK-Upper-Geogs", basename(paths[[poll]])),
    sha256 = digest::digest(file = paths[[poll]], algo = "sha256"),
    rows = nrow(x), matched_boundaries = length(index),
    missing_indicator_values = lapply(x[unname(columns)], function(v) sum(is.na(v)))
  )
  out <- x[c(common, counts)]
  for (column in names(columns)) out[[column]] <- x[[columns[[column]]]]
  out$air_pollutant <- poll

  out
}

tables <- setNames(lapply(pollutants, read_pollutant), pollutants)
air_pollutants_params <- bind_rows(tables[setdiff(pollutants, "O3")])
o3 <- tables$O3

upstream <- file.path(here, "source/dashboard.R")
lines <- readLines(upstream, warn = FALSE)
start <- grep("^# STANDALONE HTML DASHBOARD", lines)
if (length(start) != 1L) stop("Cannot locate the upstream standalone dashboard section")
expressions <- parse(text = lines[start:length(lines)])
env <- new.env(parent = globalenv())
env$geoms <- geoms
env$air_pollutants_params <- air_pollutants_params
env$o3 <- o3
env$output_html <- file.path(preview, "hasp-static-exposure.html")

# Execute the original dashboard directly; this wrapper supplies only local inputs and paths.
for (expression in expressions) {
  assignment <- is.call(expression) && identical(expression[[1]], as.name("<-"))
  name <- if (assignment && is.symbol(expression[[2]])) as.character(expression[[2]]) else ""
  if (name == "output_html" || startsWith(paste(deparse(expression), collapse = ""), "utils::browseURL(")) next
  eval(expression, envir = env)
  if (name == "dashboard_root") env$dashboard_root <- repo
  if (name == "dashboard_resources") env$dashboard_resources <- resources
  if (name == "mapshaper_bin") env$mapshaper_bin <- file.path(here, "tools/node_modules/.bin/mapshaper")
}
explorer_title <- "Exposure to Hazards using Activity, Location and Environment (EXHALE) indicators: Static population exposure to air pollution across the United Kingdom, 2021-22"
geography_summary <- "Geography: Census 2021 Middle Super Output Areas for England and Wales; 2022 Intermediate Zones for Scotland; 2021 Super Data Zones for Northern Ireland."
stopifnot(file.exists(env$output_html), nrow(env$geoms_wgs) == 9448L,
          !any(sf::st_is_empty(env$geoms_wgs)),
          all(sf::st_geometry_type(env$geoms_wgs) == "MULTIPOLYGON"))
jsonlite::write_json(list(
  built_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
  upstream_script = substring(upstream, nchar(project) + 2),
  upstream_sha256 = digest::digest(file = upstream, algo = "sha256"),
  indicator_inputs = input_checks,
  boundary_sources = jsonlite::read_json(file.path(resources, "sources.json")),
  vulnerability_measures = "Four original percentage formulas restored using supplied upper-geography counts; whole-percent rounding",
  self_contained = TRUE,
  external_runtime_dependencies = character(0),
  sequential_palette = "Reversed cividis: low pale yellow to high dark blue (continuous exposure, quantile ranks and vulnerability percentages)",
  geography_count = nrow(geoms),
  title = explorer_title,
  geography_summary = geography_summary,
  heading_style = "BoI Imago Figtree Variable; responsive 26–42px; weight 700",
  geometry_type = "MultiPolygon only; non-area repair fragments removed",
  polygon_strokes = "1.2-pixel fill-matched round edges; no contrasting borders",
  zoom_simplification = "Disabled (smoothFactor = 0) to preserve shared edges",
  area_identification = "Native sticky hover tooltip; no sidebar readout",
  topology = jsonlite::read_json(file.path(resources, "topology-build.json")),
  lakes = list(count = nrow(env$lakes_wgs), source = "Natural Earth 1:10m lakes and Europe supplement"),
  output_sha256 = digest::digest(file = env$output_html, algo = "sha256")
), file.path(preview, "build-manifest.json"), pretty = TRUE, auto_unbox = TRUE)
message("Verified: all six pollutant tables match all 9,448 boundaries.")
