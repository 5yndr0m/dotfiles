import QtQuick
import QtQuick.Layouts
import "../../core" // Ensures we can access WeatherService

Rectangle {
    id: controlWeather

    // Adjusted height since we removed the extra details row
    implicitWidth: parent.width
    implicitHeight: 80
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.values.paddingL
        spacing: Theme.values.paddingL

        // --- 1. Weather Icon ---
        Item {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignVCenter

            Text {
                id: weatherIcon
                anchors.centerIn: parent
                // Bind directly to WeatherService properties
                text: WeatherService.hasError ? "error" : (WeatherService.isLoading ? "progress_activity" : WeatherService.icon)
                color: WeatherService.hasError ? Colors.colors.error : Colors.colors.primary
                font {
                    family: Theme.values.fontFamilyMaterial
                    pixelSize: 44
                }

                // Spin animation when loading
                RotationAnimation {
                    target: weatherIcon
                    property: "rotation"
                    duration: 1200
                    loops: Animation.Infinite
                    running: WeatherService.isLoading
                    from: 0
                    to: 360
                }
            }

            // Click to force refresh
            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: WeatherService.refreshWeather(true) // Pass true to force refresh
            }
        }

        // --- 2. Weather Info (Location, Temp, Desc) ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            // Location Name
            Text {
                text: WeatherService.location
                color: Colors.colors.on_surface
                font {
                    family: Theme.values.fontFamily
                    pixelSize: Theme.values.fontSize
                    bold: true
                }
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Temperature & Description Row
            RowLayout {
                spacing: Theme.values.spacingS

                Text {
                    text: WeatherService.temperature
                    color: Colors.colors.secondary
                    font {
                        family: "Monospace"
                        pixelSize: 24
                        bold: true
                    }
                    visible: !WeatherService.hasError && !WeatherService.isLoading
                }

                Text {
                    text: WeatherService.description
                    color: Colors.colors.on_surface_variant
                    font {
                        family: Theme.values.fontFamily
                        pixelSize: Theme.values.fontSize - 2
                        capitalization: Font.Capitalize
                    }
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: !WeatherService.hasError && !WeatherService.isLoading
                }
            }
        }
    }
}
