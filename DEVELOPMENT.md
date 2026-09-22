# Development

## Local setup

Symlink this repo into your Omarchy plugins directory so edits hot-reload
without reinstalling:

```bash
ln -s "$(pwd)" ~/.config/omarchy/plugins/vinicgobbi.battery
omarchy plugin enable vinicgobbi.battery
```

This plugin is a clone of the built-in `omarchy.battery`, so disable that
one to avoid two battery services running at once.

`Service.qml` is loaded once and kept alive by the shell, so a change to
it only takes effect after a full shell restart:

```bash
omarchy restart shell
```

Validate the manifest before publishing:

```bash
omarchy plugin validate .
```

## Structure

- `manifest.json` — plugin metadata (id, kind, entry point)
- `Service.qml` — polls `UPower`, sends the low-battery warning, and
  applies the power profile on AC/battery transitions
- `BatteryModel.js` — pure helpers: percentage, discharging state, and
  the low-battery warning decision

## Commits and releases

Commits follow [Conventional Commits](https://www.conventionalcommits.org/)
and are checked with [Commitizen](https://commitizen-tools.github.io/commitizen/):

```bash
pipx install commitizen
cz commit   # interactive, conventional-commits-compliant commit
```

Releases are manual: run `.github/workflows/release.yml` from the
Actions tab (`Run workflow`, on `main`). It only runs when dispatched
against `main`, and uses Commitizen to bump `manifest.json`'s version
and the changelog based on the commit types since the last release,
tags it (`vX.Y.Z`), and publishes a GitHub Release with the changelog
entry. If there's nothing to bump (no `feat`/`fix`/`BREAKING CHANGE`
commits since the last release), it's a no-op — no tag, no release.
