# omarchy-plugin-battery

A battery service and bar widget for the [Omarchy](https://omarchy.org/)
shell. The service is cloned from the built-in `omarchy.battery`
(low-battery warning, power-profile switching on plug/unplug); the bar
widget is cloned from `omarchy.power` (battery icon, hero, stats, power
profile picker), with a **DEVICES** section added.

## Features

- Everything the native `omarchy.power` widget has: battery icon and
  percentage, charge/discharge status, battery size and cycle count,
  time left/to full, and the power profile picker.
- Its popup adds a **DEVICES** section listing every other UPower
  device reporting a charge level — Bluetooth/USB mouse, keyboard,
  headset, game controller, etc. One at or below the low-battery
  threshold (10%) is highlighted in red.
- The `omarchy.battery` low-battery notification and AC/battery power
  profile switching, running as a background service — extended to
  also warn when one of those other devices gets low, not just the
  laptop.

## Install

```bash
omarchy plugin add https://github.com/vinicgobbi/omarchy-plugin-battery.git --enable
```

Disable the built-in `omarchy.battery` service and the `omarchy.power`
bar icon to avoid duplicate battery services/icons.

## Uninstall

```bash
omarchy plugin remove vinicgobbi.battery
```

## Contributing

See [DEVELOPMENT.md](DEVELOPMENT.md) for local setup, the plugin's file
structure, and the commit/release process.

## License

[MIT](LICENSE)
