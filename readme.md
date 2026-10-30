# EXHALE exposure explorer

Interactive maps of static population exposure to air pollution across the United Kingdom, 2021–22. The explorer covers Benzene, NO2, O3, PM2.5, PM10 and SO2 across 9,448 census areas. It includes the four original age-specific vulnerability percentages, calculated from the supplied exposed and total population counts.

**Website:** https://imago-sdruk.github.io/exhale-explorer/

## View or share the explorer

Open [the self-contained HTML](preview/hasp-static-exposure.html) in a modern browser. This approximately 37 MB file embeds the indicator values, geographic boundaries, water overlay, Leaflet library, icons and fonts. It works offline without sibling files, CSVs, R or Node.js.

This repository is independent of [DataProduct-EXHALE](https://github.com/Imago-SDRUK/DataProduct-EXHALE), which maintains the wider data-product workflows. No changes to that repository are required for deployment here.

## GitHub Pages deployment

The [deployment workflow](.github/workflows/deploy-pages.yml) publishes on pushes to `main` and can also be run manually from the Actions tab. In repository **Settings → Pages**, select **GitHub Actions** as the source.

The workflow copies `preview/hasp-static-exposure.html` into the deployment artifact as `index.html`. Only that standalone page and `.nojekyll` are published. The repository does not store a duplicate of the large HTML at its root. No R build or dataset download runs on GitHub.

To publish a revised explorer, replace `preview/hasp-static-exposure.html`, update the corresponding validation/provenance records, commit and push to `main`.

## Optional local rebuild

Viewing and deploying the existing HTML require no build inputs. Rebuilding requires the original six pollutant CSVs, supplied separately. Set `EXHALE_DATA_ROOT` to their `Consolidated-Datasets` folder, with `<pollutant>/UK-Upper-Geogs/UK-Upper-Geogs-Consolidated-Dataset-<pollutant>-2021-&-2022.csv` beneath it.

Run from this repository root:

```sh
npm ci --prefix tools
python3 fetch-resources.py
export EXHALE_DATA_ROOT="/absolute/path/to/Consolidated-Datasets"
Rscript build-explorer.R
```

R requires `sf`, `dplyr`, `jsonlite`, `viridisLite` and `digest`. Python uses its standard library. Node.js runs the Mapshaper version pinned in `tools/package-lock.json`. Downloads and `node_modules` are local caches excluded from Git. The rendering source is preserved in [source/dashboard.R](source/dashboard.R), with its origin recorded in [source/provenance.json](source/provenance.json).

The four vulnerability formulas retain the original whole-percent rounding. Reversed cividis is used consistently for exposure and vulnerability values. Popup labels, descriptive text and the explicit title break are preserved in the supplied HTML.

## Attribution and validation

Boundary attribution for ONS, Scottish Government and NISRA, Natural Earth lake attribution, and Leaflet/font licences are embedded in the HTML. [Resource provenance](resources/sources.json) records downloaded asset URLs and checksums. Source data-product licensing is retained in [LICENSE](LICENSE).

The [build manifest](preview/build-manifest.json), [standalone checks](preview/self-contained-validation.json) and [vulnerability checks](preview/vulnerability-validation_23-10-2026.json) document the supplied release. Validation includes all 9,448 areas, 24 pollutant/measure combinations and 226,752 vulnerability percentage values. The new Pages deployment publishes these existing results without changing the data or calculating additional measures.
