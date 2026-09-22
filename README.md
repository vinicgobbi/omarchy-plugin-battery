# omarchy-plugin-battery

A battery service for the [Omarchy](https://omarchy.org/) shell, cloned
from the built-in `omarchy.battery`. Watches the battery level, warns you
when it's low, and switches power profiles when you plug/unplug.

## Install

```bash
omarchy plugin add https://github.com/vinicgobbi/omarchy-plugin-battery.git --enable
```

Disable the built-in `omarchy.battery` service to avoid running two
battery services at once.

## Uninstall

```bash
omarchy plugin remove vinicgobbi.battery
```

## Contributing

See [DEVELOPMENT.md](DEVELOPMENT.md) for local setup, the plugin's file
structure, and the commit/release process.

## License

[MIT](LICENSE)
