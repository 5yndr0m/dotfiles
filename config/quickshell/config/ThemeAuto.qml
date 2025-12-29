pragma Singleton
import QtQuick

QtObject {
    // --- Dynamic "Default" Palette (The one Matugen picks based on wallpaper) ---
    readonly property color primary: "#cbbeff"
    readonly property color on_Primary: "#33275e"
    readonly property color surface: "#141318"
    readonly property color on_Surface: "#e6e1e9"
    readonly property color surfaceContainer: "#201f24"
    readonly property color outline: "#938f99"

    // --- Explicit Light Palette (Opposite variants) ---
    readonly property color lightOnSurface: "#1c1b20"
    readonly property color lightPrimary: "#625690"
    readonly property color lightOnSurfaceVariant: "#48454e"

    // --- Explicit Dark Palette (Opposite variants) ---
    readonly property color darkOnSurface: "#e6e1e9"
    readonly property color darkPrimary: "#cbbeff"
    readonly property color darkOnSurfaceVariant: "#cac4cf"

    // --- INTERNAL LOGIC ---
    
    // Standard W3C Luminance formula to detect if 'surface' is dark
    function getIsDark(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) < 0.5
    }

    readonly property bool isDarkTheme: getIsDark(surface)

    // --- THE LEGIBILITY ENGINE (The "Flippers") ---
    
    // High Contrast Text flipping
    readonly property color textMain: isDarkTheme ? darkOnSurface : lightOnSurface
    readonly property color textSecondary: isDarkTheme ? darkOnSurfaceVariant : lightOnSurfaceVariant
    
    // Brand Accent
    readonly property color accent: isDarkTheme ? darkPrimary : "#e7deff"

    // Surface Levels
    readonly property color bgContainer: isDarkTheme ? "#201f24" : "#f1ecf4"
    readonly property color bgSurface: isDarkTheme ? "#141318" : "#fdf7ff"

    // Decorative
    readonly property color shadowColor: isDarkTheme ? "#000000" : Qt.rgba(0,0,0, 0.2)

    // LOGGING
    onIsDarkThemeChanged: console.log(">>> [MATUGEN] Theme Flip. Dark Mode:", isDarkTheme)
}
