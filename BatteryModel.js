function batteryPercentage(device) {
  if (!device || !device.isPresent) return -1
  return Math.round(Number(device.percentage || 0) * 100)
}

function isDischarging(device, onBattery, dischargingState) {
  return !!(device && device.isPresent && onBattery && device.state === dischargingState)
}

function shouldWarnLowBattery(device, onBattery, dischargingState, threshold, alreadyNotified) {
  var level = batteryPercentage(device)
  if (level < 0) return { level: level, notify: false, notifiedLowBattery: false }

  var low = isDischarging(device, onBattery, dischargingState) && level <= threshold
  return {
    level: level,
    notify: low && !alreadyNotified,
    notifiedLowBattery: low
  }
}

// Other UPower devices besides the laptop's own battery/AC: Bluetooth/USB
// mice, keyboards, headsets, controllers, etc. that report a charge level.
function isPeripheral(device) {
  return !!(device && device.isPresent && !device.isLaptopBattery && !device.powerSupply)
}

// UPower reports whatever a Bluetooth/HID peripheral itself advertises as
// its name, so d.model is untrusted input — clip it before it goes into the
// low-battery notification's headline.
function peripheralName(device) {
  var d = device || {}
  // The model name comes from the device itself (any Bluetooth device
  // nearby picks its own): no control characters, so it can't break lines
  // or carry escape sequences into the notification.
  var model = String(d.model || "").replace(/[\u0000-\u001f\u007f]/g, " ").trim()
  var name = model !== "" ? model : "Device"
  return name.length > 60 ? name.slice(0, 59) + "…" : name
}

// Peripherals have no "on battery" concept (they always run off their own
// battery), so this only compares the level, unlike shouldWarnLowBattery.
function shouldWarnPeripheralLowBattery(device, threshold, alreadyNotified) {
  var level = batteryPercentage(device)
  if (level < 0) return { level: level, notify: false, notifiedLowBattery: false }

  var low = level <= threshold
  return {
    level: level,
    notify: low && !alreadyNotified,
    notifiedLowBattery: low
  }
}

if (typeof module !== "undefined") {
  module.exports = {
    batteryPercentage: batteryPercentage,
    isDischarging: isDischarging,
    shouldWarnLowBattery: shouldWarnLowBattery,
    isPeripheral: isPeripheral,
    peripheralName: peripheralName,
    shouldWarnPeripheralLowBattery: shouldWarnPeripheralLowBattery
  }
}
