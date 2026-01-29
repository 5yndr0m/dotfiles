import QtQuick
import QtQuick.Layouts
import "../../../core"

RowLayout {
    spacing: tokens.spacingM
    Layout.fillWidth: true

    property var colors
    property var tokens
    property var weatherData

    Rectangle {
        Layout.preferredWidth: 80
        Layout.preferredHeight: 80
        radius: 28
        color: colors.surface_container_low
        border.color: colors.outline_variant
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2
            Text {
                text: weatherData.hasError ? "error" : (weatherData.isLoading ? "progress_activity" : weatherData.icon)
                font {
                    family: "Material Symbols Rounded"
                    pixelSize: 32
                }
                color: weatherData.hasError ? colors.error : colors.primary
                Layout.alignment: Qt.AlignHCenter
                RotationAnimation on rotation {
                    running: weatherData.isLoading
                    from: 0
                    to: 360
                    duration: 1200
                    loops: Animation.Infinite
                }
            }
            Text {
                text: weatherData.temperature
                color: colors.on_surface
                font {
                    family: tokens.fontFamily
                    pixelSize: 12
                    bold: true
                }
                Layout.alignment: Qt.AlignHCenter
                visible: !weatherData.isLoading && !weatherData.hasError
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: weatherData.refreshWeather()
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        radius: 28
        color: colors.surface_container_low
        border.color: colors.outline_variant
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: -4
            Text {
                text: Qt.formatDateTime(new Date(), "ddd, MMM dd")
                color: colors.on_surface_variant
                font {
                    family: tokens.fontFamily
                    pixelSize: 14
                    weight: Font.Medium
                    letterSpacing: 1
                }
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.8
            }
            Text {
                text: Qt.formatDateTime(new Date(), "HH:mm")
                color: colors.on_surface
                font {
                    family: tokens.fontFamily
                    pixelSize: 36
                    bold: true
                }
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
