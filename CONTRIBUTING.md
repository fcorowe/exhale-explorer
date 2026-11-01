# Contributing to the EXHALE exposure explorer

We welcome contributions to the code, documentation, design, accessibility and interpretation of the explorer. These practices adapt the [Imago contributing guidelines](https://github.com/Imago-SDRUK/Template/blob/main/CONTRIBUTING.md). All interactions are covered by the [Imago Code of Conduct](CODE_OF_CONDUCT.md).

## Discuss and report changes

Search existing issues before opening a new one. Use the bug-report or feature-request template, with a clear description and relevant screenshots. For map issues, include the selected pollutant, measure and geographic area, and say whether you used the website or the downloaded HTML.

Discuss proposed changes to indicator definitions, denominators, age groups or thresholds with maintainers before implementation. Report conduct concerns privately as described in the Code of Conduct, rather than in a public issue.

## Fork, branch and submit a pull request

1. Fork the repository on GitHub and clone your fork:

   ```sh
   git clone https://github.com/YOUR-USERNAME/exhale-explorer.git
   cd exhale-explorer
   ```

2. Create a descriptive branch:

   ```sh
   git switch -c improve-map-labels
   ```

3. Make a focused change and complete the relevant checks below. Commit only the intended files, with a message explaining the change.
4. Push the branch to your fork and open a pull request against this repository's `main` branch. Complete the PR template, link related issues and request review.
5. A maintainer reviews the change, applies appropriate labels and merges it after the checks pass. Changes merged into `main` are deployed automatically by GitHub Actions.

## Work on the correct source files

- Edit `index.qmd`, `_quarto.yml` and `styles.css` for the Quarto website shell.
- Edit `source/dashboard.R` for the map application and its explanatory text. `build-explorer.R` supplies local input paths and generates `preview/hasp-static-exposure.html`.
- Keep changes to the rendering source and its generated HTML together. Update the corresponding build and validation records when rebuilding the explorer.
- Keep downloaded resources, `node_modules`, `.quarto` and `_site` out of Git. The existing `.gitignore` covers these local files. Do not add input datasets that are not approved for public redistribution.
- Preserve source attribution, embedded third-party licences, geographic identifiers and meaningful missing values.

## Check your changes

For website and documentation changes, run:

```sh
quarto render
git diff --check
```

Check relative links and images in the rendered site. Confirm that the explorer loads and its layout works at wide and narrow browser widths. A website-shell change should leave the standalone HTML unchanged.

Rebuilding the map also requires the six source pollutant CSVs and local display resources; the [readme](readme.md#optional-local-rebuild) explains setup. Check all six pollutants and four vulnerability choices, hover names, popups, legends and the self-contained download. If calculations change, compare results with the supplied source counts and record the validation. Document changes to formulas explicitly for scientific review.

## Resolve conflicts carefully

Fetch upstream changes, update your working branch and resolve conflicts in the affected source files. Rebuild generated outputs from the resolved source, rerun the relevant checks and push the result. Ask a maintainer before reconciling a rewritten upstream history; do not force-push the shared `main` branch.

## Contributor recognition

The repository includes the Imago template's [All Contributors](https://allcontributors.org/) configuration and a readme section ready for its contributor table. Once a maintainer has enabled the All Contributors app for this repository, request recognition after a PR is merged with:

```text
@all-contributors please add @YOUR-USERNAME for code, doc
```

Use the relevant [contribution types](https://allcontributors.org/docs/en/emoji-key). Review and merge the bot's pull request. If the app is not enabled, ask a maintainer to update the configuration and contributor table manually. Template contributors are not automatically listed as contributors to this explorer.

## Imago access and handover

Imago organisation administrators manage team membership, repository access and offboarding under the [Imago practices](https://github.com/Imago-SDRUK/Template/blob/main/CONTRIBUTING.md#github-access-and-team-setup). The [handover checklist](docs/imago-handover_01-11-2026.md) records the repository-specific steps that remain when transferring this repository to Imago.

## Licensing contributions

Contributions follow the [repository licence](LICENSE): MIT for software, and CC BY 4.0 for documentation, data and other non-code content. Existing third-party assets retain their own licences and attribution, including those embedded in the explorer HTML.
