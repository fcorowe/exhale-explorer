# Imago repository handover

Prepared on 1 November 2026 using [Imago-SDRUK/Template](https://github.com/Imago-SDRUK/Template), commit `f77f97c4a4ee05c73b3f3d4e1d62fd641246e277`. [Source checksums](imago-template-source_01-11-2026.json) distinguish unchanged template files from repository-specific adaptations.

## Current arrangement

- Repository: https://github.com/fcorowe/exhale-explorer
- Website: https://fcorowe.github.io/exhale-explorer/
- Quarto homepage: `index.qmd`; configuration: `_quarto.yml`.
- Deployment: `.github/workflows/deploy-pages.yml` renders Quarto and publishes `_site` to GitHub Pages.
- Standalone explorer: `preview/hasp-static-exposure.html`; its embedded data and third-party licences are retained.
- Scientific rendering source: `source/dashboard.R`; local input wrapper: `build-explorer.R`.
- Community files: Imago logo, Code of Conduct, contributing guide, issue and PR templates, and All Contributors configuration.
- Licence: the template's MIT licence for software and CC BY 4.0 for documentation, data and other non-code content.

This preparation does not transfer repository ownership or change organisation access. The current repository and website URLs remain in use until Imago accepts a transfer.

## Transfer steps for the owner and Imago administrators

1. Agree the receiving Imago team and maintainers, confirm that `Imago-SDRUK/exhale-explorer` is available, and arrange for an authorised administrator to accept the repository transfer.
2. After the transfer, update Git remotes to `git@github.com:Imago-SDRUK/exhale-explorer.git`.
3. Update `website.site-url` in `_quarto.yml` and the website link in `readme.md` to the confirmed Imago Pages URL, expected to be `https://imago-sdruk.github.io/exhale-explorer/` if the repository name is retained.
4. Update `.all-contributorsrc`: set `projectOwner` to `Imago-SDRUK` and `repo` to the transferred repository URL. Keep `files` set to `readme.md` to match its actual filename.
5. Assign the receiving team, confirm maintainer access, and review branch review settings under Imago's access practices.
6. Confirm that GitHub Actions and Pages are enabled in the receiving organisation. Pages should use **GitHub Actions** as its publishing source; check the `github-pages` environment and run the deployment workflow.
7. Enable or approve the All Contributors app if Imago uses the bot for this repository. The configuration is prepared; app installation is not asserted by these files.
8. Verify the new homepage, logo/favicon, explorer controls and standalone download. Compare the published standalone HTML checksum with the repository file before sharing the new URL.

## Build and source-data notes

Publishing the existing explorer needs Quarto, not R or the source CSVs. Rebuilding its scientific content also requires R, the packages listed in the readme, local display resources and the six approved pollutant input tables under `EXHALE_DATA_ROOT`. Large input data and caches remain outside Git.

The supplied explorer contains six pollutants, 9,448 geographic areas and four original vulnerability percentage formulas. Existing validation records accompany the HTML. A future scientific update should regenerate the output and its provenance rather than alter only the compiled page.
