pragma Singleton
import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: root

    readonly property var battery: UPower.displayDevice

    readonly property int percentage: {
        if (!battery)
            return 0;

        let val = battery.percentage;
        return (val <= 1.0) ? Math.round(val * 100) : Math.round(val);
    }
    readonly property bool isCharging: battery ? (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged) : false

    readonly property bool isLow: percentage < 20
    readonly property string timeRemaining: battery ? battery.timeToEmpty : ""

    Component.onCompleted: console.log("Raw Battery Data:", battery.percentage * 100)
}
