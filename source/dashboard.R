# Loading Libraries
library(dplyr)
library(sf)

# Reading In .gpkg With Geometry
# Boundaries For UK Upper Geographies
geoms <- st_read("X:/UK-Geographies/Lower-&-Upper-Geogs/Imago-Specific-UK-Geographies/UK-2021-2022-List-Of-Upper-Geogs.geojson")

st_crs(geoms) # Checking CRS Of 'geoms' As CRS Has To Be WGS84 For It To Work In Interactive Dashboard

# Simplifying 'geoms' So They Don't Take Too Long To Load In Dashboard
#geoms <- st_simplify(geoms, dTolerance = 100, preserveTopology = TRUE)

geoms <- st_transform(geoms, 4326) # Transforming CRS Of 'geoms' To WGS84 As Required

# Creating Outline Boundary For All 4 UK
# Countries To Be Used In Later Shiny Plot
e_outline <- geoms %>%
  filter(country == "England") %>%
  st_make_valid()
e_outline <- st_as_sf(e_outline)
e_outline <- st_union(e_outline)

w_outline <- geoms %>%
  filter(country == "Wales") %>%
  st_make_valid()
w_outline <- st_as_sf(w_outline)
w_outline <- st_union(w_outline)

ni_outline <- geoms %>%
  filter(country == "Northern Ireland") %>%
  st_make_valid()
ni_outline <- st_as_sf(ni_outline)
ni_outline <- st_union(ni_outline)

s_outline <- geoms %>%
  filter(country == "Scotland") %>%
  st_make_valid()
s_outline <- st_as_sf(s_outline)
s_outline <- st_union(s_outline)

# Reading In .csv With The Consolidated Dataset Of
# Each Air Pollutant For Upper Geographies UK-Wide
benzene <- read.csv("X:/Consolidated-Datasets/Static-Indicators/HASP-Data-Product/Benzene/CSVs/UK-Upper-Geogs/UK-Upper-Geogs-Consolidated-Dataset-Benzene-2021-&-2022.csv")
no2 <- read.csv("X:/Consolidated-Datasets/Static-Indicators/HASP-Data-Product/NO2/CSVs/UK-Upper-Geogs/UK-Upper-Geogs-Consolidated-Dataset-NO2-2021-&-2022.csv")
o3 <- read.csv("X:/Consolidated-Datasets/Static-Indicators/HASP-Data-Product/O3/CSVs/UK-Upper-Geogs/UK-Upper-Geogs-Consolidated-Dataset-O3-2021-&-2022.csv")
pm25 <- read.csv("X:/Consolidated-Datasets/Static-Indicators/HASP-Data-Product/PM2.5/CSVs/UK-Upper-Geogs/UK-Upper-Geogs-Consolidated-Dataset-PM2.5-2021-&-2022.csv")
pm10 <- read.csv("X:/Consolidated-Datasets/Static-Indicators/HASP-Data-Product/PM10/CSVs/UK-Upper-Geogs/UK-Upper-Geogs-Consolidated-Dataset-PM10-2021-&-2022.csv")
so2 <- read.csv("X:/Consolidated-Datasets/Static-Indicators/HASP-Data-Product/SO2/CSVs/UK-Upper-Geogs/UK-Upper-Geogs-Consolidated-Dataset-SO2-2021-&-2022.csv")

# Adding A Column 'air_pollutant' To Indicate What
# Air Pollutant Each Data Frame Has The Parameters Of
benzene$air_pollutant <- "Benzene"
no2$air_pollutant <- "NO2"
pm25$air_pollutant <- "PM2.5"
pm10$air_pollutant <- "PM10"
so2$air_pollutant <- "SO2"
o3$air_pollutant <- "O3"

# Selecting Only Columns To Be Used For Later Computations & Plotting &
# Renaming A Few Columns So Data Frames Are Able To Be Binded Together Into One
# Note That O3 Will Be Handled Differently As The Indicators Are Different

benzene <- benzene %>% select(geog_code, geog_name, region_code, region_name, country, air_pollutant,
                              area_weighted_mean_indicator = area_weighted_mean_Benzene,
                              PWE_indicator = PWE_to_Benzene, above_threshold_indicator = above_European_Commission_threshold,
                              quantile_rank, exposed_age_15_under, total_age_15_under,
                              exposed_age_65_plus, total_age_65_plus, total_population_count)

no2 <- no2 %>% select(geog_code, geog_name, region_code, region_name, country, air_pollutant,
                      area_weighted_mean_indicator = area_weighted_mean_NO2,
                      PWE_indicator = PWE_to_NO2, above_threshold_indicator = above_WHO_threshold,
                      quantile_rank, exposed_age_15_under, total_age_15_under,
                              exposed_age_65_plus, total_age_65_plus, total_population_count)

pm25 <- pm25 %>% select(geog_code, geog_name, region_code, region_name, country, air_pollutant,
                        area_weighted_mean_indicator = area_weighted_mean_PM2.5,
                        PWE_indicator = PWE_to_PM2.5, above_threshold_indicator = above_WHO_threshold,
                        quantile_rank, exposed_age_15_under, total_age_15_under,
                              exposed_age_65_plus, total_age_65_plus, total_population_count)

pm10 <- pm10 %>% select(geog_code, geog_name, region_code, region_name, country, air_pollutant,
                        area_weighted_mean_indicator = area_weighted_mean_PM10,
                        PWE_indicator = PWE_to_PM10, above_threshold_indicator = above_WHO_threshold,
                        quantile_rank, exposed_age_15_under, total_age_15_under,
                              exposed_age_65_plus, total_age_65_plus, total_population_count)

so2 <- so2 %>% select(geog_code, geog_name, region_code, region_name, country, air_pollutant,
                      area_weighted_mean_indicator = area_weighted_mean_SO2,
                      PWE_indicator = PWE_to_SO2, above_threshold_indicator = above_DEFRA_threshold,
                      quantile_rank, exposed_age_15_under, total_age_15_under,
                              exposed_age_65_plus, total_age_65_plus, total_population_count)

o3 <- o3 %>% select(geog_code, geog_name, region_code, region_name, country, air_pollutant,
                    area_weighted_mean_indicator = area_weighted_mean_O3,
                    exposed_1_plus_days_indicator = at_least_1_day_exposed_to_O3_above_120_ug,
                    quantile_rank, exposed_age_15_under, total_age_15_under,
                              exposed_age_65_plus, total_age_65_plus, total_population_count)

# Binding All Air Pollutants' Data Frames (Except For O3
# Which Will Be Handled Separately) Into One Data Frame
air_pollutants_params <- bind_rows(benzene,
                               no2,
                               pm25,
                               pm10,
                               so2)

rm(benzene, no2, pm25, pm10, so2) # Removing As No Longer Needed

# Arranging 'air_pollutants_params' By Geog Code & Country So That
# The Parameters Of Every MSOA/IZ/SDZ Are Adjacent To Each Other
air_pollutants_params <- air_pollutants_params %>%
  arrange(geog_code, country)

# The four original vulnerability percentages are calculated in the standalone
# dashboard section below, using the supplied exposed and total counts.

# -------------------------------------------------------------------------------------------- #

# =====================================================================
# STANDALONE HTML DASHBOARD - RUN THIS DIRECTLY AFTER THE SET-UP SCRIPT
# (needs: geoms, air_pollutants_params and o3 to exist in the session)
# =====================================================================

# ---------------------------------------------------------------------
# 0. SETTINGS YOU MAY WANT TO CHANGE
# ---------------------------------------------------------------------
output_html            <- file.path("X:/Interactive-Dashboards", "HASP-Data-Product-Interactive-Dashboard.html")

script_arg <- grep("^--file=", commandArgs(), value = TRUE)
source_files <- Filter(Negate(is.null), lapply(sys.frames(), function(frame) frame$ofile))
dashboard_file <- if (length(source_files)) tail(source_files, 1)[[1]] else if (length(script_arg)) sub("^--file=", "", script_arg[1]) else ""
dashboard_root <- if (nzchar(dashboard_file)) normalizePath(file.path(dirname(dashboard_file), "../../..")) else getwd()
dashboard_resources <- Sys.getenv("EXHALE_EXPLORER_RESOURCES", file.path(dashboard_root, "analysis/interactive-explorer/resources"))
mapshaper_bin <- Sys.getenv("EXHALE_MAPSHAPER", file.path(dashboard_root, "analysis/interactive-explorer/tools/node_modules/.bin/mapshaper"))

SIMPLIFY_KEEP          <- 0.10
SIMPLIFY_TOL_M         <- 100
COORD_DIGITS           <- 7

GEOM_STROKE_COLOUR     <- "#e8e8f0"
GEOM_STROKE_WEIGHT     <- 1.2
GEOM_FILL_OPACITY      <- 1
COUNTRY_OUTLINE_WEIGHT <- 1.4


# Applied from theme.scss: Figtree Variable for sans-serif, Space Grotesk Variable for monospace
FONT_FAMILY_CSS        <- "'Figtree Variable', system-ui, sans-serif"
FONT_FAMILY_MONO       <- "'Space Grotesk Variable', monospace"

UG_M3                  <- "\u03bcg/m\u00b3"

# ---------------------------------------------------------------------
# 1. CHECKS
# ---------------------------------------------------------------------
for (pkg in c("jsonlite", "viridisLite")) {
  if (!requireNamespace(pkg, quietly = TRUE)) stop("Please install.packages('", pkg, "') first.")
}
if (!all(c("geog_code", "country") %in% names(geoms))) {
  stop("'geoms' needs 'geog_code' and 'country' columns.")
}

# ---------------------------------------------------------------------
# 2. HELPER FUNCTIONS FOR THE DROP-DOWN TEXT
# ---------------------------------------------------------------------
pollutant_choices <- c("Benzene", "NO2", "PM2.5", "PM10", "SO2", "O3")

indicator_choices <- function(poll) {
  if (poll == "O3") {
    stats::setNames(
      c("area_weighted_mean_indicator", "exposed_1_plus_days_indicator", "quantile_rank"),
      c(paste("Area-Weighted Mean Number Of Days Exposed To O3 Above 120", UG_M3),
        paste("At Least 1 Day Exposed To O3 Above 120", UG_M3, "Within The Census Year"),
        "Quantile Rank According To Area-Weighted Mean Indicator")
    )
  } else {
    stats::setNames(
      c("area_weighted_mean_indicator", "PWE_indicator",
        "above_threshold_indicator", "quantile_rank"),
      c(paste("Area-Weighted Mean", poll),
        paste("Population-Weighted Exposure To", poll),
        paste("Above", poll, "Threshold"),
        paste("Quantile Rank According To Area-Weighted Mean", poll))
    )
  }
}

vulnerability_vars <- c("prop_exposed_15_under_relative_to_total_15_under",
                        "prop_exposed_15_under_relative_to_total_population",
                        "prop_exposed_65_plus_relative_to_total_65_plus",
                        "prop_exposed_65_plus_relative_to_total_population")

vulnerability_choices <- function(poll) {
  labs <- unname(vulnerability_legend_titles[vulnerability_vars])
  supplied <- get_pollutant_data(poll)
  available <- vapply(vulnerability_vars, function(name) {
    name %in% names(supplied) && is.numeric(supplied[[name]]) && any(is.finite(supplied[[name]]))
  }, logical(1))
  c("None (Color By Static Exposure Indicator)" = "",
    stats::setNames(vulnerability_vars[available], labs[available]))
}

vulnerability_legend_titles <- c(
  prop_exposed_15_under_relative_to_total_15_under   = "Aged ≤15 exposed (% of age group)",
  prop_exposed_15_under_relative_to_total_population = "Aged ≤15 exposed (% of all residents)",
  prop_exposed_65_plus_relative_to_total_65_plus     = "Aged 65+ exposed (% of age group)",
  prop_exposed_65_plus_relative_to_total_population  = "Aged 65+ exposed (% of all residents)"
)

# Restore only the dashboard's four original percentage formulas.
add_vulnerability_percentages <- function(data) {
  required <- c("exposed_age_15_under", "total_age_15_under", "exposed_age_65_plus",
                "total_age_65_plus", "total_population_count")
  if (!all(required %in% names(data))) stop("Missing supplied vulnerability counts: ",
    paste(setdiff(required, names(data)), collapse = ", "))
  if (!all(vapply(data[required], function(x) is.numeric(x) && all(is.finite(x) & x >= 0), logical(1)))) {
    stop("Vulnerability counts must be finite, nonnegative numbers")
  }
  if (any(data$total_age_15_under <= 0 | data$total_age_65_plus <= 0 | data$total_population_count <= 0) ||
      any(data$exposed_age_15_under > data$total_age_15_under | data$exposed_age_65_plus > data$total_age_65_plus)) {
    stop("Invalid vulnerability denominator or exposed count exceeding its total")
  }
  data %>% mutate(
    prop_exposed_15_under_relative_to_total_15_under = round((exposed_age_15_under / total_age_15_under) * 100, 0),
    prop_exposed_15_under_relative_to_total_population = round((exposed_age_15_under / total_population_count) * 100, 0),
    prop_exposed_65_plus_relative_to_total_65_plus = round((exposed_age_65_plus / total_age_65_plus) * 100, 0),
    prop_exposed_65_plus_relative_to_total_population = round((exposed_age_65_plus / total_population_count) * 100, 0)
  )
}
air_pollutants_params <- add_vulnerability_percentages(air_pollutants_params)
o3 <- add_vulnerability_percentages(o3)

get_pollutant_data <- function(poll) {
  if (poll == "O3") o3 else air_pollutants_params[air_pollutants_params$air_pollutant == poll, ]
}

# ---------------------------------------------------------------------
# 3. GEOMETRY & DATA PREPARATION
# ---------------------------------------------------------------------
polygonal_only <- function(x) {
  # Geometry repair can retain collapsed points/lines alongside valid polygons.
  # Leaflet would render those points as markers rather than choropleth areas.
  polygons <- lapply(sf::st_geometry(x), function(geometry) {
    area <- sf::st_sfc(geometry, crs = sf::st_crs(x))
    if (inherits(geometry, "GEOMETRYCOLLECTION")) {
      area <- sf::st_collection_extract(area, "POLYGON", warn = FALSE)
    }
    if (length(area) > 1L) area <- sf::st_union(area)
    if (length(area) != 1L || any(sf::st_is_empty(area)) ||
        !all(sf::st_geometry_type(area) %in% c("POLYGON", "MULTIPOLYGON"))) {
      stop("A boundary has no unambiguous polygon geometry after repair")
    }
    sf::st_cast(area, "MULTIPOLYGON", warn = FALSE)[[1]]
  })
  sf::st_geometry(x) <- sf::st_sfc(polygons, crs = sf::st_crs(x))
  x
}

polygonal_geojson <- function(text) {
  # GDAL may repair rounded coordinates into mixed collections during export.
  # Keep polygon components at this final stage too, one feature per area.
  polygons <- function(geometry) {
    switch(geometry$type,
           Polygon = list(geometry$coordinates),
           MultiPolygon = geometry$coordinates,
           GeometryCollection = do.call(c, lapply(geometry$geometries, polygons)),
           list())
  }
  geojson <- jsonlite::fromJSON(text, simplifyVector = FALSE)
  geojson$features <- lapply(geojson$features, function(feature) {
    coordinates <- polygons(feature$geometry)
    if (!length(coordinates)) stop("An exported area has no polygon geometry")
    feature$geometry <- list(type = "MultiPolygon", coordinates = coordinates)
    feature
  })
  as.character(jsonlite::toJSON(geojson, auto_unbox = TRUE, digits = NA, null = "null"))
}

message("Simplifying geometries...")

geoms_bng <- geoms %>%
  st_zm(drop = TRUE, what = "ZM") %>%
  select(geog_code, country, any_of("geog_name")) %>%
  st_transform(27700) %>%
  st_make_valid()

# Simplify shared arcs once; never simplify neighbouring polygons independently.
geoms_bng <- polygonal_only(geoms_bng)
if (file.exists(mapshaper_bin)) {
  scratch <- tempfile("exhale-display-")
  dir.create(scratch)
  input <- file.path(scratch, "boundaries.shp")
  output <- file.path(scratch, "boundaries.geojson")
  st_write(geoms_bng, input, driver = "ESRI Shapefile", quiet = TRUE)
  status <- system2(mapshaper_bin, c("-i", shQuote(input), "snap-interval=0.01",
    "-simplify", "weighted", "interval=25", "keep-shapes",
    "-proj", "wgs84", "-o", shQuote(output), "precision=0.0000001", "force"))
  if (status != 0L) stop("Shared-edge geometry preparation failed")
  simplified <- st_read(output, quiet = TRUE)
  stopifnot(nrow(simplified) == nrow(geoms_bng), !anyDuplicated(simplified$geog_code),
            setequal(simplified$geog_code, geoms_bng$geog_code))
  geoms_bng <- st_transform(simplified[match(geoms_bng$geog_code, simplified$geog_code), ], 27700)
  unlink(scratch, recursive = TRUE)
} else {
  message("Mapshaper unavailable: retaining full boundary detail to preserve shared edges.",
          " Install with npm ci --prefix analysis/interactive-explorer/tools.")
}
geoms_bng <- polygonal_only(geoms_bng)

exterior_only <- function(geom) {
  if (any(st_geometry_type(geom) == "GEOMETRYCOLLECTION")) {
    geom <- st_union(st_collection_extract(geom, "POLYGON"))
  }
  mp    <- st_cast(geom, "MULTIPOLYGON")[[1]]
  polys <- lapply(mp, function(p) list(p[[1]]))
  st_sfc(st_multipolygon(polys), crs = st_crs(geom))
}

message("Building country outlines...")
country_names <- c("England", "Wales", "Scotland", "Northern Ireland")
outline_list  <- lapply(country_names, function(cn) {
  sub <- geoms_bng[geoms_bng$country == cn, ]
  if (nrow(sub) == 0) return(NULL)
  exterior_only(st_union(st_geometry(sub)))
})
keep <- !vapply(outline_list, is.null, logical(1))
outlines_wgs <- st_sf(country  = country_names[keep],
                      geometry = do.call(c, outline_list[keep])) %>%
  st_transform(4326)

geoms_wgs     <- st_transform(geoms_bng, 4326)
geoms_wgs$idx <- seq_len(nrow(geoms_wgs))

sf_to_geojson_text <- function(x) {
  tmp <- tempfile(fileext = ".geojson")
  st_write(x, tmp, driver = "GeoJSON", delete_dsn = TRUE, quiet = TRUE,
           layer_options = paste0("COORDINATE_PRECISION=", COORD_DIGITS))
  txt <- paste(readLines(tmp, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  unlink(tmp)
  polygonal_geojson(txt)
}
geojson_geoms    <- sf_to_geojson_text(geoms_wgs[, "idx"])
geojson_outlines <- sf_to_geojson_text(outlines_wgs)

# Reference water polygons affect map display only.
lake_paths <- file.path(dashboard_resources, c("ne_10m_lakes.shp", "ne_10m_lakes_europe.shp"))
if (!all(file.exists(lake_paths))) stop("Download map resources first: python3 analysis/interactive-explorer/fetch-resources.py")
lakes <- bind_rows(lapply(lake_paths, function(path) {
  x <- st_read(path, quiet = TRUE, wkt_filter = st_as_text(st_as_sfc(st_bbox(geoms_wgs))))
  x[, "name"]
}))
lakes <- st_make_valid(st_transform(lakes, 27700))
land <- st_make_valid(st_transform(outlines_wgs, 27700))
lakes <- st_filter(lakes, land)
lakes <- suppressWarnings(st_intersection(lakes, st_union(land)))
lakes <- lakes[as.numeric(st_area(lakes)) > 0, ]
lakes_wgs <- st_transform(polygonal_only(lakes), 4326)
geojson_water <- sf_to_geojson_text(lakes_wgs)

message("Preparing data...")
code <- geoms_wgs$geog_code

meta_src <- bind_rows(
  air_pollutants_params %>% select(geog_code, geog_name, region_name, country),
  o3                    %>% select(geog_code, geog_name, region_name, country)
) %>%
  mutate(across(everything(), as.character)) %>%
  distinct(geog_code, .keep_all = TRUE)

mi <- match(code, meta_src$geog_code)
meta <- list(
  code    = code,
  name    = meta_src$geog_name[mi],
  region  = meta_src$region_name[mi],
  country = meta_src$country[mi]
)
if ("geog_name" %in% names(geoms_wgs)) {
  meta$name <- ifelse(is.na(meta$name), as.character(geoms_wgs$geog_name), meta$name)
}
meta$country <- ifelse(is.na(meta$country), as.character(geoms_wgs$country), meta$country)

yes_no_vars <- c("above_threshold_indicator", "exposed_1_plus_days_indicator")
yn_recode <- function(x) {
  x <- as.character(x)
  x[x %in% c("TRUE", "1", "Yes", "YES", "yes")]  <- "Yes"
  x[x %in% c("FALSE", "0", "No", "NO", "no")]    <- "No"
  x
}

build_pollutant <- function(poll) {
  d    <- get_pollutant_data(poll)
  ind  <- indicator_choices(poll)
  vul  <- vulnerability_choices(poll)[-1]
  vars <- c(unname(ind), unname(vul))

  idx <- match(code, d$geog_code)
  dat <- lapply(vars, function(v) {
    x <- d[[v]][idx]
    if (v %in% yes_no_vars) yn_recode(x) else if (is.numeric(x)) round(x, 2) else x
  })
  names(dat) <- vars

  rk  <- dat$quantile_rank
  lv  <- sort(unique(rk[!is.na(rk)]))
  key <- as.character(lv)
  lab <- key
  lab[key == "0"] <- paste0("0 (Below The ", poll, " Threshold)")
  lab[key == "1"] <- paste0("1 (Least Exposed To ", poll, ")")
  lab[key == "4"] <- paste0("4 (Most Exposed To ", poll, ")")
  cols <- if (length(lv)) substr(viridisLite::cividis(length(lv), direction = -1), 1, 7) else character(0)

  cont_vars <- setdiff(vars, c(yes_no_vars, "quantile_rank"))
  ranges <- lapply(cont_vars, function(v) {
    x <- dat[[v]]; x <- x[!is.na(x)]
    if (length(x)) range(x) else c(0, 1)
  })
  names(ranges) <- cont_vars

  list(
    data = dat,
    spec = list(
      indicators      = data.frame(value = unname(ind), label = names(ind), stringsAsFactors = FALSE),
      vulnerabilities = data.frame(value = unname(vul), label = names(vul),
                                   short = unname(vulnerability_legend_titles[unname(vul)]),
                                   stringsAsFactors = FALSE),
      rank_levels     = data.frame(key = key, label = lab, color = cols, stringsAsFactors = FALSE),
      ranges          = ranges
    )
  )
}

built    <- lapply(stats::setNames(pollutant_choices, pollutant_choices), build_pollutant)
data_all <- lapply(built, `[[`, "data")
spec_all <- lapply(built, `[[`, "spec")

# Use one sequential scale for exposure values and vulnerability percentages.
sequential_palette <- substr(viridisLite::cividis(256, direction = -1), 1, 7)
palettes <- list(cividis = sequential_palette, vulnerability = sequential_palette)

to_json <- function(x) jsonlite::toJSON(x, auto_unbox = TRUE, na = "null", digits = 4)

config <- list(strokeColour  = GEOM_STROKE_COLOUR,
               strokeWeight  = GEOM_STROKE_WEIGHT,
               fillOpacity   = GEOM_FILL_OPACITY,
               outlineWeight = COUNTRY_OUTLINE_WEIGHT)

data_js <- paste0(
  "const GEOJSON = ",    geojson_geoms,    ";\n",
  "const OUTLINES = ",   geojson_outlines, ";\n",
  "const WATER = ", geojson_water, ";\n",
  "const META = ",       to_json(meta),     ";\n",
  "const DATA = ",       to_json(data_all), ";\n",
  "const SPEC = ",       to_json(spec_all), ";\n",
  "const PALETTES = ",   to_json(palettes), ";\n",
  "const POLLUTANTS = ", to_json(pollutant_choices), ";\n",
  "const CONFIG = ",     to_json(config),   ";\n"
)

# ---------------------------------------------------------------------
# 5. LEAFLET LIBRARY
# ---------------------------------------------------------------------
# All runtime assets are embedded. Missing build inputs must never silently
# switch the shared file to a CDN dependency.
embedded_asset <- function(filename, mime) {
  path <- file.path(dashboard_resources, filename)
  if (!file.exists(path)) stop("Missing display asset: ", filename,
    ". Run python3 analysis/interactive-explorer/fetch-resources.py first.")
  bytes <- readBin(path, "raw", n = file.info(path)$size)
  paste0("data:", mime, ";base64,", gsub("[[:space:]]", "", jsonlite::base64_enc(bytes)))
}
read_asset <- function(filename) {
  path <- file.path(dashboard_resources, filename)
  if (!file.exists(path)) stop("Missing display asset: ", filename,
    ". Run python3 analysis/interactive-explorer/fetch-resources.py first.")
  paste(readLines(path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
}
leaflet_css <- read_asset("leaflet.css")
for (image in c("layers.png", "layers-2x.png", "marker-icon.png")) {
  leaflet_css <- gsub(paste0("images/", image), embedded_asset(image, "image/png"), leaflet_css, fixed = TRUE)
}
# Obsolete Internet Explorer VML behaviour is unnecessary in modern browsers.
leaflet_css <- gsub("behavior: url(#default#VML);", "", leaflet_css, fixed = TRUE)
lib_css_tag <- paste0("<style>\n", leaflet_css, "\n</style>")
lib_js_tag <- paste0("<script>\n", sub("//# sourceMappingURL=[^\\n]*", "", read_asset("leaflet.js")), "\n</script>")
marker_icons <- list(iconUrl = embedded_asset("marker-icon.png", "image/png"),
                     iconRetinaUrl = embedded_asset("marker-icon-2x.png", "image/png"),
                     shadowUrl = embedded_asset("marker-shadow.png", "image/png"))
data_js <- paste0(data_js, "const MARKER_ICONS = ", to_json(marker_icons), ";\n")
asset_licenses <- list(Leaflet = read_asset("leaflet-license.txt"),
                      Figtree = read_asset("figtree-license.txt"),
                      Space_Grotesk = read_asset("space-grotesk-license.txt"))

# ---------------------------------------------------------------------
# 6. PAGE STYLE, LAYOUT & BROWSER-SIDE CODE (Updated with theme.scss colors & fonts)
# ---------------------------------------------------------------------
page_css <- r"---(
  html, body { height: 100%; margin: 0; padding: 0; overflow: hidden;
               font-family: "Figtree Variable", system-ui, sans-serif; color: #24226f; }
  body { display: flex; flex-direction: column; }

  /* Title band using $body-color (#24226f) from theme.scss */
  .app-header {
    flex: none; position: relative; z-index: 1000; box-sizing: border-box;
    background: #24226f; color: #ffffff; padding: 18px 32px 16px 32px; text-align: center;
    box-shadow: 0 2px 6px rgba(36,34,111,0.2);
  }
  .app-header h1 { margin: 0; font-size: clamp(26px, 3vw, 42px); line-height: 1.2; font-weight: 700; }
  .app-header p  { margin: 10px 0 0 0; font-size: clamp(13px, 1.2vw, 19px); line-height: 1.35; opacity: 0.9; }

  .app-body { flex: 1 1 auto; min-height: 0; display: flex; flex-direction: row; }
  .side-panel {
    width: 33.5%; min-width: 300px; overflow-y: auto; box-sizing: border-box;
    background: #fafafc; border-right: 1px solid #e0e0ea; padding: 18px;
  }
  .side-panel label { display: block; font-weight: 600; color: #24226f; font-size: 14px; margin: 0 0 5px 0; }
  .side-panel select.native-hidden { display: none; }
  .help-note { font-size: 12px; color: #5a5796; margin: -8px 0 18px 0; line-height: 1.4; }
  .map-panel { flex: 1; position: relative; min-width: 0; }
  #map, .leaflet-container { position: absolute; top: 0; right: 0; bottom: 0; left: 0; background: #ffffff; }

  /* Custom drop-downs with primary accent color #ff8f42 */
  .dd { position: relative; margin-bottom: 16px; }
  .dd-btn {
    display: block; width: 100%; box-sizing: border-box; text-align: left; cursor: pointer;
    padding: 8px 30px 8px 9px; font-size: 13px; line-height: 1.35; white-space: pre-line;
    border: 1px solid #c8c6e3; border-radius: 4px; background: #fff; color: #24226f;
  }
  .dd-btn:focus { outline: 2px solid #ff8f42; outline-offset: 1px; }
  .dd-btn::after {
    content: ""; position: absolute; right: 11px; top: 50%; margin-top: -3px;
    border-left: 5px solid transparent; border-right: 5px solid transparent; border-top: 6px solid #24226f;
  }
  .dd.open .dd-btn::after { border-top: 0; border-bottom: 6px solid #ff8f42; }
  .dd-list {
    display: none; position: absolute; left: 0; right: 0; top: 100%; margin: 2px 0 0 0; padding: 0; list-style: none;
    z-index: 2000; max-height: 60vh; overflow-y: auto; background: #fff;
    border: 1px solid #c8c6e3; border-radius: 4px; box-shadow: 0 4px 14px rgba(36,34,111,0.15);
  }
  .dd.open .dd-list { display: block; }
  .dd-list li { padding: 8px 10px; font-size: 13px; line-height: 1.35; white-space: pre-line; cursor: pointer; border-bottom: 1px solid #f0edf8; color: #24226f; }
  .dd-list li:last-child { border-bottom: 0; }
  .dd-list li.active { background: rgba(255,143,66,0.15); }
  .dd-list li.selected { font-weight: 700; color: #ff8f42; }

  /* North arrow */
  .north-arrow { background: rgba(255,255,255,0.9); border-radius: 6px; padding: 4px 6px 2px 6px; pointer-events: none; line-height: 0; }
  .leaflet-bottom.leaflet-right .north-arrow { margin: 0 14px 18px 0; }

  /* Legend */
  #legend { background: #ffffff; border: 1px solid #e0e0ea; border-radius: 6px; padding: 12px 14px; font-size: 13px; color: #24226f; }
  .lg-title { margin-bottom: 8px; line-height: 1.35; white-space: pre-line; }
  .lg-bar   { height: 14px; border-radius: 3px; border: 1px solid #c8c6e3; }
  .lg-scale { display: flex; justify-content: space-between; font-size: 12px; color: #5a5796; margin: 3px 0 8px 0; }
  .lg-row   { display: flex; align-items: center; margin: 4px 0; }
  .lg-sw    { display: inline-block; width: 18px; height: 14px; margin-right: 8px; border: 1px solid #c8c6e3; flex: none; }

  .dd-btn:disabled { opacity: .65; cursor: default; }
  .water-key { margin: 14px 0; font-size: 12px; }
  .area-tooltip { background: #fff; color: #24226f; border: 1px solid #c8c6e3; padding: 9px 12px; font-size: 13px; line-height: 1.5; pointer-events: none; }

  /* Hover box & click popup */
  .tip { position: absolute; display: none; z-index: 1100; pointer-events: none; background: #ffffff;
         border: 1px solid #c8c6e3; border-radius: 4px; padding: 8px 10px; box-shadow: 0 2px 8px rgba(36,34,111,0.2); }
  .info { font-size: 13px; line-height: 1.4; width: max-content; max-width: 360px; white-space: pre-line; color: #24226f; }
  .info hr { margin: 5px 0; border: 0; border-top: 1px solid #e0e0ea; }

  .leaflet-popup-content .info { font-size: 14px; line-height: 1.45; max-width: 500px; }
)---"

page_body <- r"---(
<div class="app-header">
  <h1>Exposure to Hazards using Activity, Location and Environment (EXHALE) indicators:<br>Static population exposure to air pollution across the United Kingdom, 2021-22</h1>
  <p>Geography: Census 2021 Middle Super Output Areas for England and Wales; 2022 Intermediate Zones for Scotland; 2021 Super Data Zones for Northern Ireland.</p>
</div>
<div class="app-body">
  <div class="side-panel">
    <label for="pollutant">Air Pollutant</label>
    <select id="pollutant"></select>

    <label for="indicator">Static Exposure Indicator</label>
    <select id="indicator"></select>

    <label for="vulnerability">Vulnerability Measure</label>
    <select id="vulnerability"></select>
    <div class="help-note">Vulnerability measures capture the extent to which vulnerable populations, specifically young people aged 15 and under and older people aged 65 and over, are exposed to risky levels of air pollutants.  Specifically these measures show the percentage of people living in places where air pollution exceeds the official threshold used for the selected pollutant. Thresholds differ by pollutant. For O3, exposure means at least one day above 120 µg/m³ during the census year. Two different measures are reported varying the denominator: using all ages or the respective age group. Check the Imago and HASP data catalogue for more air pollution indicators, for different periods, populations and metric definitions.</div>

    <div id="legend"></div><div class="water-key"><span style="display:inline-block;width:16px;height:12px;background:#9ecae1;margin-right:7px;vertical-align:middle"></span>Lakes and reservoirs</div>
  </div>
  <div class="map-panel"><div id="map"></div></div>
</div>
)---"

app_js <- r"---(
(function () {
  L.Icon.Default.mergeOptions(MARKER_ICONS);
  L.Icon.Default.prototype._getIconUrl = function (name) { return L.Icon.prototype._getIconUrl.call(this, name); };
  var FILL_OP = CONFIG.fillOpacity;
  var NODATA  = '#e8e8f0';
  var N       = META.code.length;
  var CAT_VARS    = ['above_threshold_indicator', 'exposed_1_plus_days_indicator'];
  var CAT_COLOURS = { 'Yes': '#ff8f42', 'No': '#24226f' };
  var PAL_BY_IND  = { area_weighted_mean_indicator: 'cividis', PWE_indicator: 'cividis' };

  function esc(s) {
    return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;')
                                     .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
  function fmtNum(v) { return (Math.round(v * 100) / 100).toLocaleString('en-GB'); }
  function fmt(v, suffix) {
    if (v === null || v === undefined || v === '') return 'No data';
    if (typeof v === 'number') return fmtNum(v) + (suffix || '');
    return esc(v) + (suffix || '');
  }

  var map = L.map('map', { preferCanvas: true, zoomSnap: 0.25, attributionControl: true });

  map.attributionControl.addAttribution('Boundaries: ONS, Scottish Government, NISRA; contains OS and OSNI data, Crown copyright and database rights. Lakes: Natural Earth.');
  var layers = new Array(N);
  var tip = document.createElement('div');
  tip.className = 'tip';
  map.getContainer().appendChild(tip);

  function placeTip(p) {
    var sz = map.getSize(), w = tip.offsetWidth, h = tip.offsetHeight;
    var x = p.x + 16, y = p.y + 16;
    if (x + w > sz.x - 4) x = p.x - w - 16;
    if (y + h > sz.y - 4) y = p.y - h - 16;
    tip.style.left = Math.max(4, x) + 'px';
    tip.style.top  = Math.max(4, y) + 'px';
  }
  map.on('mousemove', function (e) { if (tip.style.display === 'block') placeTip(e.containerPoint); });

  var popupOpen = false;
  map.on('popupopen',  function () { popupOpen = true;  tip.style.display = 'none'; });
  map.on('popupclose', function () { popupOpen = false; });

  var S = { poll: null, ind: null, indLabel: '', vul: '', vulLabel: '' };

  var UNIT_UG = '\u00a0\u03bcg/m\u00b3';
  function unitFor(poll, ind) {
    return (poll !== 'O3' && (ind === 'area_weighted_mean_indicator' || ind === 'PWE_indicator')) ? UNIT_UG : '';
  }

  function infoHtml(i) {
    var d = DATA[S.poll];
    var h = '<div class="info"><b>' + esc(META.name[i]) + '</b> (' + esc(META.code[i]) + ')<br>' +
            ((META.country[i] === 'England' && META.region[i]) ? esc(META.region[i]) + ', ' : '') + esc(META.country[i]) + '<hr>' +
            '<b>Air Pollutant:</b> ' + esc(S.poll) + '<br>' +
            '<b>Indicator:</b> ' + esc(S.indLabel) + '<br>' +
            '<b>Value:</b> ' + fmt(d[S.ind][i], unitFor(S.poll, S.ind));
    if (S.vul) {
      h += '<br><br><b>Vulnerability Measure:</b> ' +
           esc(S.vulLabel) +
           '<br><b>Value:</b> ' + fmt(d[S.vul][i], '%');
    }
    return h + '</div>';
  }

  var geoLayer = L.geoJSON(GEOJSON, {smoothFactor: 0,
    style: function () {
      return { stroke: true, color: NODATA, weight: CONFIG.strokeWeight, opacity: 1, lineJoin: 'round', lineCap: 'round',
               fillColor: NODATA, fillOpacity: FILL_OP };
    },
    onEachFeature: function (f, layer) {
      var i = f.properties.idx - 1;
      layers[i] = layer;
      layer.bindTooltip(function () {
        return '<strong>' + esc(META.name[i]) + '</strong><br>' + esc(META.code[i]) + ' · ' + esc(META.country[i]);
      }, {sticky: true, direction: 'top', opacity: 1, className: 'area-tooltip'});
      layer.on('click', function (e) {
        tip.style.display = 'none';
        layer.setStyle({ fillOpacity: FILL_OP });
        L.popup({ maxWidth: 500 }).setLatLng(e.latlng).setContent(infoHtml(i)).openOn(map);
      });
    }
  }).addTo(map);

  map.createPane('water'); map.getPane('water').style.zIndex = 450;
  map.getPane('water').style.pointerEvents = 'none';
  L.geoJSON(WATER, {pane: 'water', interactive: false, style: {stroke: false, fillColor: '#9ecae1', fillOpacity: 1}}).addTo(map);
  map.createPane('country-outlines'); map.getPane('country-outlines').style.zIndex = 460;
  map.getPane('country-outlines').style.pointerEvents = 'none';
  L.geoJSON(OUTLINES, {pane: 'country-outlines',
    interactive: false,
    style: function () { return { fill: false, color: '#24226f', weight: CONFIG.outlineWeight, opacity: 1 }; }
  }).addTo(map);

  var northArrow = L.control({ position: 'bottomright' });
  northArrow.onAdd = function () {
    var div = document.createElement('div');
    div.className = 'north-arrow';
    div.innerHTML =
      '<svg width="30" height="44" viewBox="0 0 30 44" xmlns="http://www.w3.org/2000/svg" aria-label="North arrow">' +
      '<text x="15" y="11" text-anchor="middle" font-size="13" font-weight="700" fill="#24226f" ' +
      'font-family="\'Figtree Variable\', sans-serif">N</text>' +
      '<polygon points="15,15 24,41 15,34 6,41" fill="#ffffff" stroke="#24226f" stroke-width="1.2" stroke-linejoin="round"/>' +
      '<polygon points="15,15 15,34 6,41" fill="#24226f"/></svg>';
    return div;
  };
  northArrow.addTo(map);

  map.fitBounds(geoLayer.getBounds(), { padding: [10, 10] });
  setTimeout(function () { map.invalidateSize(); }, 0);

  var selPoll = document.getElementById('pollutant');
  var selInd  = document.getElementById('indicator');
  var selVul  = document.getElementById('vulnerability');
  var legendEl = document.getElementById('legend');

  function fillSelect(sel, items, emptyLabel) {
    sel.innerHTML = '';
    if (emptyLabel) {
      var o0 = document.createElement('option'); o0.value = ''; o0.textContent = emptyLabel; sel.appendChild(o0);
    }
    items.forEach(function (it) {
      var o = document.createElement('option'); o.value = it.value; o.textContent = it.label; sel.appendChild(o);
    });
  }

  function makeDropdown(sel) {
    var wrap = document.createElement('div'); wrap.className = 'dd';
    var btn  = document.createElement('button'); btn.type = 'button'; btn.className = 'dd-btn'; btn.id = sel.id + '-btn';
    btn.setAttribute('aria-haspopup', 'listbox'); btn.setAttribute('aria-expanded', 'false');
    var list = document.createElement('ul'); list.className = 'dd-list'; list.setAttribute('role', 'listbox');
    sel.parentNode.insertBefore(wrap, sel);
    wrap.appendChild(btn); wrap.appendChild(list); wrap.appendChild(sel);
    sel.className = 'native-hidden';
    var lab = document.querySelector('label[for="' + sel.id + '"]');
    if (lab) lab.setAttribute('for', btn.id);

    var active = -1;
    function setActive(n) {
      active = n;
      Array.prototype.forEach.call(list.children, function (li, k) { li.classList.toggle('active', k === n); });
      if (list.children[n]) list.children[n].scrollIntoView({ block: 'nearest' });
    }
    function open()  { wrap.classList.add('open');  btn.setAttribute('aria-expanded', 'true');  setActive(sel.selectedIndex); }
    function close() { wrap.classList.remove('open'); btn.setAttribute('aria-expanded', 'false'); }
    function choose(n) {
      var changed = sel.selectedIndex !== n;
      sel.selectedIndex = n; refresh(); close();
      if (changed) sel.dispatchEvent(new Event('change'));
    }
    function refresh() {
      list.innerHTML = '';
      Array.prototype.forEach.call(sel.options, function (o, n) {
        var li = document.createElement('li');
        li.setAttribute('role', 'option');
        li.textContent = o.textContent;
        if (n === sel.selectedIndex) li.className = 'selected';
        li.addEventListener('mousedown', function (e) { e.preventDefault(); choose(n); });
        list.appendChild(li);
      });
      var o = sel.options[sel.selectedIndex];
      btn.textContent = o ? o.textContent : '';
    }

    btn.addEventListener('click', function () { wrap.classList.contains('open') ? close() : open(); });
    btn.addEventListener('keydown', function (e) {
      var isOpen = wrap.classList.contains('open');
      if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
        e.preventDefault();
        if (!isOpen) { open(); return; }
        setActive(Math.min(sel.options.length - 1, Math.max(0, active + (e.key === 'ArrowDown' ? 1 : -1))));
      } else if (e.key === 'Enter' && isOpen) { e.preventDefault(); choose(active); }
      else if (e.key === 'Escape' || e.key === 'Tab') { close(); }
    });
    document.addEventListener('mousedown', function (e) { if (!wrap.contains(e.target)) close(); });

    return { refresh: refresh };
  }

  var dds = [];
  function refreshAll() { dds.forEach(function (d) { d.refresh(); }); }

  function populate(poll) {
    fillSelect(selInd, SPEC[poll].indicators);
    var unavailable = SPEC[poll].vulnerabilities.length === 0;
    fillSelect(selVul, SPEC[poll].vulnerabilities, unavailable ? 'Unavailable: awaiting supplied data' : 'None (Color By Static Exposure Indicator)');
    selVul.disabled = unavailable;
    document.getElementById('vulnerability-btn').disabled = unavailable;
    selVul.value = '';
    refreshAll();
  }

  function contColour(pal, v, lo, hi) {
    if (v === null || v === undefined || isNaN(v)) return NODATA;
    var t = hi > lo ? (v - lo) / (hi - lo) : 0;
    t = Math.min(1, Math.max(0, t));
    return pal[Math.round(t * (pal.length - 1))];
  }

  function renderLegend(lg) {
    var h = '<div class="lg-title">' + lg.title + '</div>';
    if (lg.type === 'cont') {
      var stops = [];
      for (var k = 0; k <= 10; k++) stops.push(lg.pal[Math.round(k / 10 * (lg.pal.length - 1))]);
      var sfx = lg.suffix || '';
      h += '<div class="lg-bar" style="background:linear-gradient(to right,' + stops.join(',') + ')"></div>' +
           '<div class="lg-scale"><span>' + fmtNum(lg.lo) + sfx + '</span><span>' + fmtNum((lg.lo + lg.hi) / 2) + sfx +
           '</span><span>' + fmtNum(lg.hi) + sfx + '</span></div>';
    } else {
      lg.items.forEach(function (it) {
        h += '<div class="lg-row"><span class="lg-sw" style="background:' + it.color + '"></span><span>' + esc(it.label) + '</span></div>';
      });
    }
    legendEl.innerHTML = h;
  }

  function update() {
    var poll = selPoll.value, ind = selInd.value, vul = selVul.value;
    var sp = SPEC[poll], dat = DATA[poll];
    var indObj = sp.indicators.filter(function (x) { return x.value === ind; })[0];
    if (!indObj) return;
    S = { poll: poll, ind: ind, indLabel: indObj.label, vul: vul, vulLabel: '' };

    var colours = new Array(N), lg, arr, i;

    if (vul) {
      var vo = sp.vulnerabilities.filter(function (x) { return x.value === vul; })[0];
      S.vulLabel = vo.label;
      var rng = sp.ranges[vul]; arr = dat[vul];
      for (i = 0; i < N; i++) colours[i] = contColour(PALETTES.vulnerability, arr[i], rng[0], rng[1]);
      lg = { type: 'cont', title: '<b>' + esc(poll) + '</b><br>' + vo.short, pal: PALETTES.vulnerability, lo: rng[0], hi: rng[1], suffix: '%' };

    } else if (CAT_VARS.indexOf(ind) >= 0) {
      arr = dat[ind];
      for (i = 0; i < N; i++) colours[i] = CAT_COLOURS[arr[i]] || NODATA;
      lg = { type: 'cat', title: '<b>' + esc(poll) + '</b><br>' + esc(indObj.label),
             items: [{ label: 'Yes', color: CAT_COLOURS.Yes }, { label: 'No', color: CAT_COLOURS.No }] };

    } else if (ind === 'quantile_rank') {
      var cmap = {};
      sp.rank_levels.forEach(function (l) { cmap[l.key] = l.color; });
      arr = dat[ind];
      for (i = 0; i < N; i++) colours[i] = (arr[i] === null || arr[i] === undefined) ? NODATA : (cmap[String(arr[i])] || NODATA);
      lg = { type: 'cat', title: '<b>' + esc(poll) + '</b><br>' + esc(indObj.label),
             items: sp.rank_levels.map(function (l) { return { label: l.label, color: l.color }; }) };

    } else {
      var pal = PALETTES[PAL_BY_IND[ind] || 'cividis'];
      var r = sp.ranges[ind]; arr = dat[ind];
      for (i = 0; i < N; i++) colours[i] = contColour(pal, arr[i], r[0], r[1]);
      lg = { type: 'cont', title: '<b>' + esc(poll) + '</b><br>' + esc(indObj.label), pal: pal, lo: r[0], hi: r[1],
             suffix: unitFor(poll, ind) };
    }

    for (i = 0; i < N; i++) {
      var L_ = layers[i];
      if (L_ && L_.options.fillColor !== colours[i]) L_.setStyle({ fillColor: colours[i], color: colours[i] });
    }
    selInd.title = S.indLabel;
    selVul.title = S.vulLabel;
    renderLegend(lg);
  }

  fillSelect(selPoll, POLLUTANTS.map(function (p) { return { value: p, label: p }; }));
  selPoll.value = 'PM2.5';
  dds = [makeDropdown(selPoll), makeDropdown(selInd), makeDropdown(selVul)];
  populate(selPoll.value);

  selPoll.addEventListener('change', function () { populate(selPoll.value); update(); });
  selInd.addEventListener('change', update);
  selVul.addEventListener('change', update);
  update();
})();
)---"

# ---------------------------------------------------------------------
# 7. WRITE THE HTML FILE (Including Figtree Variable & Space Grotesk Variable @font-face)
# ---------------------------------------------------------------------
message("Writing HTML...")
html <- paste0(
  "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n",
  "<meta charset=\"utf-8\">\n",
  "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n",
  "<title>Exposure to Hazards using Activity, Location and Environment (EXHALE) indicators: Static population exposure to air pollution across the United Kingdom, 2021-22</title>\n",
  lib_css_tag, "\n",
  '<script type="application/json" id="embedded-asset-licenses">', to_json(asset_licenses), "</script>\n",
  # Figtree & Space Grotesk @font-face definitions from theme.scss
  "<style>\n",
  "@font-face {\n",
  "  font-family: \"Figtree Variable\";\n",
  "  font-style: normal;\n",
  "  font-display: swap;\n",
  "  font-weight: 300 900;\n",
  "  src: url(\"", embedded_asset("figtree.woff2", "font/woff2"), "\") format(\"woff2-variations\");\n",
  "  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;\n",
  "}\n",
  "@font-face {\n",
  "  font-family: \"Space Grotesk Variable\";\n",
  "  font-style: normal;\n",
  "  font-display: swap;\n",
  "  font-weight: 300 700;\n",
  "  src: url(\"", embedded_asset("space-grotesk.woff2", "font/woff2"), "\") format(\"woff2-variations\");\n",
  "  unicode-range: U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD;\n",
  "}\n",
  "</style>\n",
  "<style>", page_css, "</style>\n",
  "<style>html, body, select, option, button, .leaflet-container, .leaflet-popup-content, .leaflet-control, .tip, .info, .dd-btn, .dd-list li {",
  " font-family: ", FONT_FAMILY_CSS, " !important; }</style>\n",
  "</head>\n<body>\n",
  page_body, "\n",
  lib_js_tag, "\n",
  "<script>\n", data_js, "</script>\n",
  "<script>", app_js, "</script>\n",
  "</body>\n</html>\n"
)
writeLines(enc2utf8(html), output_html, useBytes = TRUE)

message("Done! Saved to: ", output_html,
        " (", round(file.size(output_html) / 1e6, 1), " MB)")
utils::browseURL(output_html)
