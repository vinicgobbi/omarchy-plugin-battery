import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "BatteryModel.js" as BatteryModel

Item {
  id: root

  property var shell: null
  property string omarchyPath: Quickshell.env("OMARCHY_PATH")

  readonly property int batteryThreshold: 10
  property string pendingPowerSource: ""

  PersistentProperties {
    id: persisted
    reloadableId: "omarchy-battery"
    property bool notifiedLowBattery: false
  }

  // Per-device "already notified" state for peripherals (mouse, keyboard,
  // headset, ...), keyed by nativePath. Not persisted like notifiedLowBattery
  // above — peripherals come and go, so re-warning once per shell run if one
  // is still low after a restart is fine.
  property var notifiedLowDevices: ({})
  property var pendingPeripheralWarnings: []

  function batteryPercentage() {
    return BatteryModel.batteryPercentage(UPower.displayDevice)
  }

  function isDischarging() {
    return BatteryModel.isDischarging(UPower.displayDevice, UPower.onBattery, UPowerDeviceState.Discharging)
  }

  function checkBattery() {
    var state = BatteryModel.shouldWarnLowBattery(UPower.displayDevice, UPower.onBattery, UPowerDeviceState.Discharging, batteryThreshold, persisted.notifiedLowBattery)
    persisted.notifiedLowBattery = state.notifiedLowBattery
    if (state.notify) sendLowBatteryWarning(state.level)
  }

  function sendLowBatteryWarning(level) {
    if (warningProcess.running) return
    warningProcess.command = [
      "omarchy-battery-low",
      String(level)
    ]
    warningProcess.running = true
  }

  function checkPeripherals() {
    var values = UPower.devices.values
    var nextNotified = {}
    for (var i = 0; i < values.length; i++) {
      var device = values[i]
      if (!BatteryModel.isPeripheral(device)) continue

      var key = device.nativePath
      var state = BatteryModel.shouldWarnPeripheralLowBattery(device, batteryThreshold, !!notifiedLowDevices[key])
      nextNotified[key] = state.notifiedLowBattery
      if (state.notify) queuePeripheralWarning(BatteryModel.peripheralName(device), state.level)
    }
    notifiedLowDevices = nextNotified
  }

  function queuePeripheralWarning(name, level) {
    pendingPeripheralWarnings = pendingPeripheralWarnings.concat([{ name: name, level: level }])
    if (!peripheralWarningProcess.running) runNextPeripheralWarning()
  }

  function runNextPeripheralWarning() {
    if (pendingPeripheralWarnings.length === 0) return
    var next = pendingPeripheralWarnings[0]
    pendingPeripheralWarnings = pendingPeripheralWarnings.slice(1)
    peripheralWarningProcess.command = [
      "omarchy-notification-send", "-g", "󰂑", "-u", "critical", "-i", "battery-caution", "-t", "30000",
      next.name + " battery low", "Down to " + next.level + "%"
    ]
    peripheralWarningProcess.running = true
  }

  function applyPowerProfile() {
    pendingPowerSource = UPower.onBattery ? "battery" : "ac"
    if (!powerProfileProcess.running) runPendingPowerProfile()
  }

  function runPendingPowerProfile() {
    powerProfileProcess.command = ["omarchy-powerprofiles-set", pendingPowerSource]
    pendingPowerSource = ""
    powerProfileProcess.running = true
  }

  Process { id: warningProcess }

  Process {
    id: peripheralWarningProcess
    onExited: root.runNextPeripheralWarning()
  }

  Process {
    id: powerProfileProcess
    onExited: if (root.pendingPowerSource !== "") root.runPendingPowerProfile()
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      root.checkBattery()
      root.checkPeripherals()
    }
  }

  Connections {
    target: UPower
    function onOnBatteryChanged() {
      root.checkBattery()
      root.applyPowerProfile()
    }
  }
}
