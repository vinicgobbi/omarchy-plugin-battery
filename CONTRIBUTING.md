# Contributing

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
- `Service.qml` — polls `UPower`, sends the low-battery warning for the
  laptop and for other devices, and applies the power profile on
  AC/battery transitions
- `BatteryModel.js` — pure helpers for `Service.qml`: percentage,
  discharging state, the low-battery warning decision (laptop and
  peripherals), and the peripheral filter/name helpers
- `BarWidget.qml` — cloned from `omarchy.power`'s `Panel.qml`: the bar
  icon, hero, stats, power profile picker (current source only, like
  native), the On AC/On battery picker (either source, added here),
  plus the DEVICES section built from `UPower.devices`
  (red-highlighted below the low-battery threshold)
- `Model.js` — cloned from `omarchy.power`'s `Model.js` (icon glyph,
  profile parsing, charge-threshold detection), plus the other-devices
  list/icon/name helpers for the DEVICES section

Peripheral low-battery notifications use `omarchy-notification-send`
directly rather than `omarchy-battery-low` (which also runs the
`battery-low` hooks meant for the laptop's own battery — running those
for a mouse would be wrong).

`omarchy-powerprofiles-set <ac|battery> [profile]` always applies the
given profile live, with no "just remember it" mode — it doesn't check
whether that source is actually the active one. So setting the
inactive source's profile (e.g. picking the battery profile while
plugged in) briefly flips the live profile; `setSourceProfile()` in
`BarWidget.qml` corrects this by reasserting whichever source is truly
active right after (`reapplyCurrentProfile()`). The remembered value
per source lives in `$XDG_STATE_HOME/omarchy/powerprofiles/{ac,battery}`
(overridable via `OMARCHY_POWERPROFILES_STATE_DIR`) — there's no CLI
getter for it, so `BarWidget.qml` reads those two files directly.

## CI

`.github/workflows/ci.yml` runs on every push to `main` (and on pull
requests) and validates `manifest.json` and every `.qml` file with
`qmllint`, so a syntax error can't land on `main`.

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
