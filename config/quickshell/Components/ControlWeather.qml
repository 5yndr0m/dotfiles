import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config

Rectangle {
    id: controlWeather

    implicitWidth: parent.width - 10
    implicitHeight: 100

    border.width: 2
    border.color: ThemeAuto.outline // Changed from Theme.surface2
    radius: 8
    color: ThemeAuto.bgSurface    // Changed from Theme.crust

    // Weather data properties
    property string location: "Loading..."
    property string temperature: "--°"
    property string description: "Loading weather..."
    property string icon: "partly_cloudy_day"
    property string humidity: "--%"
    property string windSpeed: "-- km/h"
    property bool isLoading: true
    property bool hasError: false

    property string apiKey: "59ff08f9d98a8acb443c488c9ef0a995"
    property string city: "Kegalle"

    // Weather API call
    Process {
        id: weatherProc
        command: ["curl", "-s", "https://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=" + apiKey + "&units=metric"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;

                try {
                    var weather = JSON.parse(data);

                    if (weather.cod === 200) {
                        location = weather.name + ", " + weather.sys.country;
                        temperature = Math.round(weather.main.temp) + "°C";
                        description = weather.weather[0].description;
                        humidity = weather.main.humidity + "%";
                        windSpeed = Math.round(weather.wind.speed * 3.6) + " km/h";
                        icon = getWeatherIcon(weather.weather[0].icon);
                        isLoading = false;
                        hasError = false;
                    } else {
                        hasError = true;
                        description = "Error: " + (weather.message || "Unable to fetch weather");
                        isLoading = false;
                    }
                } catch (e) {
                    hasError = true;
                    description = "Failed to parse weather data";
                    isLoading = false;
                }
            }
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                hasError = true;
                description = "Network error - check connection";
                isLoading = false;
            }
        }
    }

    function getWeatherIcon(iconCode) {
        switch (iconCode) {
        case "01d": return "wb_sunny";
        case "01n": return "nights_stay";
        case "02d": return "partly_cloudy_day";
        case "02n": return "partly_cloudy_night";
        case "03d":
        case "03n":
        case "04d":
        case "04n": return "cloud";
        case "09d":
        case "09n": return "grain";
        case "10d":
        case "10n": return "rainy";
        case "11d":
        case "11n": return "thunderstorm";
        case "13d":
        case "13n": return "ac_unit";
        case "50d":
        case "50n": return "foggy";
        default: return "partly_cloudy_day";
        }
    }

    Timer {
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (apiKey !== "YOUR_API_KEY") {
                isLoading = true;
                hasError = false;
                weatherProc.running = true;
            } else {
                hasError = true;
                description = "Please set your API key";
                isLoading = false;
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Weather icon container
        Rectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            Layout.alignment: Qt.AlignVCenter
            radius: 8
            color: ThemeAuto.bgContainer // Changed from Theme.surface0
            border.width: 1
            border.color: hasError ? ThemeAuto.accent : ThemeAuto.accent // Standardized to accent

            Text {
                id: weatherIcon
                anchors.centerIn: parent
                text: hasError ? "error" : (isLoading ? "hourglass_empty" : icon)
                color: ThemeAuto.accent // Changed from Theme.blue/red
                font {
                    family: "Material Symbols Rounded"
                    pixelSize: 32
                }

                RotationAnimation {
                    target: weatherIcon
                    property: "rotation"
                    duration: 2000
                    loops: Animation.Infinite
                    running: isLoading
                    from: 0
                    to: 360
                }
            }
        }

        // Weather info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            Text {
                text: location
                color: ThemeAuto.textMain // Changed from Theme.text
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize
                    bold: true
                }
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: temperature
                color: ThemeAuto.accent // Changed from Theme.flamingo
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize + 4
                    bold: true
                }
                visible: !hasError && !isLoading
            }

            Text {
                text: description
                color: ThemeAuto.outline // Changed from Theme.subtext1
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize - 2
                }
                elide: Text.ElideRight
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }
        }

        // Weather details
        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 4
            visible: !hasError && !isLoading

            RowLayout {
                spacing: 4
                Text {
                    text: "water_drop"
                    color: ThemeAuto.accent // Changed from Theme.blue
                    font { family: "Material Symbols Rounded"; pixelSize: 16 }
                }
                Text {
                    text: humidity
                    color: ThemeAuto.textMain // Changed from Theme.text
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 2 }
                }
            }

            RowLayout {
                spacing: 4
                Text {
                    text: "air"
                    color: ThemeAuto.accent // Changed from Theme.green
                    font { family: "Material Symbols Rounded"; pixelSize: 16 }
                }
                Text {
                    text: windSpeed
                    color: ThemeAuto.textMain // Changed from Theme.text
                    font { family: Theme.fontFamily; pixelSize: Theme.fontSize - 2 }
                }
            }
        }

        // Refresh button
        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            radius: 16
            color: refreshMouseArea.containsMouse ? ThemeAuto.outline : ThemeAuto.bgContainer // Changed from Theme.surface1/0
            border.width: 1
            border.color: ThemeAuto.accent // Changed from Theme.mauve

            Text {
                anchors.centerIn: parent
                text: "refresh"
                color: ThemeAuto.accent // Changed from Theme.mauve
                font {
                    family: "Material Symbols Rounded"
                    pixelSize: 18
                }
            }

            MouseArea {
                id: refreshMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (apiKey !== "YOUR_API_KEY") {
                        isLoading = true;
                        hasError = false;
                        weatherProc.running = true;
                    }
                }
            }

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}
