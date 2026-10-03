## v0.1.2 (2026-10-03)

### Fix

- **security**: aviso de bateria baixa de periférico começa com texto fixo (um dispositivo Bluetooth chamado --replace-id=1 fazia o aviso falhar, --image=… o trocava) e o nome do dispositivo perde caracteres de controle

## v0.1.1 (2026-10-03)

### Fix

- adiciona keepLoaded (Service.qml não pode ser derrubado pelo hot-reload do bar-widget, igual ao omarchy.media)
- disable qmllint's alias category too

### Refactor

- usa Util.alpha() em vez de Qt.rgba(x.r,x.g,x.b,N) na mão

## v0.1.0 (2026-09-22)

### Feat

- let AC and battery power profiles be set independently
- add a mini charge meter and amber caution tier to DEVICES rows
- warn and highlight low-battery peripherals
- add bar widget cloned from omarchy.power with a devices section
- initial Battery plugin cloned from omarchy.battery

### Fix

- clip untrusted peripheral device names
- remove redundant power-profile picker
- show other UPower devices in the DEVICES section

### Refactor

- align DEVICES styling and notifications with native Omarchy patterns
