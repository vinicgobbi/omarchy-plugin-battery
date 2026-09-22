# Development

## Local setup

Symlink this repo into your Omarchy plugins directory so edits hot-reload
without reinstalling:

```bash
ln -s "$(pwd)" ~/.config/omarchy/plugins/vinicgobbi.battery
omarchy plugin enable vinicgobbi.battery
```

This plugin's service is a clone of the built-in `omarchy.battery`, and
its bar widget is a clone of `omarchy.power` (own id, so it doesn't
collide with the built-in's IPC target). Disable both `omarchy.battery`
and `omarchy.power` to avoid duplicate services/icons.

`BarWidget.qml` (the plugin's entry point) hot-reloads on its own.
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

- `manifest.json` — plugin metadata (id, kinds, entry points)
- `Service.qml` — polls `UPower`, sends the low-battery warning, and
  applies the power profile on AC/battery transitions
- `BatteryModel.js` — pure helpers for `Service.qml`: percentage,
  discharging state, and the low-battery warning decision
- `BarWidget.qml` — cloned from `omarchy.power`'s `Panel.qml`: the bar
  icon, hero, stats, power profile picker, plus the DEVICES section
  built from `UPower.devices`
- `Model.js` — cloned from `omarchy.power`'s `Model.js` (icon glyph,
  profile parsing, charge-threshold detection), plus the other-devices
  list/icon/name helpers for the DEVICES section

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
