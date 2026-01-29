pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: weatherService

    property string location: "Loading..."
    property string temperature: "--°"
    property string description: "Loading..."
    property string icon: "partly_cloudy_day"
    property bool isLoading: false
    property bool hasError: false

    property var lastFetchTime: 0

    readonly property string apiKey: "59ff08f9d98a8acb443c488c9ef0a995"
    readonly property string city: "Kegalle"
    readonly property real updateThreshold: 3600000

    function refreshWeather(force = false) {
        let currentTime = Date.now();

        if (force || (currentTime - lastFetchTime > updateThreshold)) {
            console.log("WeatherService: Fetching new data...");
            isLoading = true;
            hasError = false;
            weatherProc.running = true;
        } else {
            console.log("WeatherService: Using cached data. Next update in " + Math.round((updateThreshold - (currentTime - lastFetchTime)) / 60000) + " mins");
        }
    }

    property Process weatherProc: Process {
        command: ["curl", "-s", "https://api.openweathermap.org/data/2.5/weather?q=" + weatherService.city + "&appid=" + weatherService.apiKey + "&units=metric"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                try {
                    var weather = JSON.parse(data);
                    if (weather.cod === 200) {
                        weatherService.location = weather.name;
                        weatherService.temperature = Math.round(weather.main.temp) + "°C";
                        weatherService.description = weather.weather[0].description;
                        weatherService.icon = getWeatherIcon(weather.weather[0].icon);

                        weatherService.lastFetchTime = Date.now();
                        weatherService.isLoading = false;
                    } else {
                        weatherService.hasError = true;
                        weatherService.isLoading = false;
                    }
                } catch (e) {
                    weatherService.hasError = true;
                    weatherService.isLoading = false;
                }
            }
        }
    }

    function getWeatherIcon(iconCode) {
        switch (iconCode) {
        case "01d":
            return "wb_sunny";
        case "01n":
            return "nights_stay";
        case "02d":
            return "partly_cloudy_day";
        case "02n":
            return "partly_cloudy_night";
        case "03d":
        case "03n":
        case "04d":
        case "04n":
            return "cloud";
        case "09d":
        case "09n":
            return "grain";
        case "10d":
        case "10n":
            return "rainy";
        case "11d":
        case "11n":
            return "thunderstorm";
        case "13d":
        case "13n":
            return "ac_unit";
        case "50d":
        case "50n":
            return "foggy";
        default:
            return "partly_cloudy_day";
        }
    }

    property Timer refreshTimer: Timer {
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: weatherService.refreshWeather(false)
    }
}
