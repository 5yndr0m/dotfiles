pragma Singleton
import QtQuick

QtObject {
    // --- Dynamic "Default" Palette (The one Matugen picks based on wallpaper) ---
    readonly property color primary: "{{colors.primary.default.hex}}"
    readonly property color on_Primary: "{{colors.on_primary.default.hex}}"
    readonly property color surface: "{{colors.surface.default.hex}}"
    readonly property color on_Surface: "{{colors.on_surface.default.hex}}"
    readonly property color surfaceContainer: "{{colors.surface_container.default.hex}}"
    readonly property color outline: "{{colors.outline.default.hex}}"

    // --- Explicit Light Palette (Opposite variants) ---
    readonly property color lightOnSurface: "{{colors.on_surface.light.hex}}"
    readonly property color lightPrimary: "{{colors.primary.light.hex}}"
    readonly property color lightOnSurfaceVariant: "{{colors.on_surface_variant.light.hex}}"

    // --- Explicit Dark Palette (Opposite variants) ---
    readonly property color darkOnSurface: "{{colors.on_surface.dark.hex}}"
    readonly property color darkPrimary: "{{colors.primary.dark.hex}}"
    readonly property color darkOnSurfaceVariant: "{{colors.on_surface_variant.dark.hex}}"

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
    readonly property color accent: isDarkTheme ? darkPrimary : "{{colors.primary_container.light.hex}}"

    // Surface Levels
    readonly property color bgContainer: isDarkTheme ? "{{colors.surface_container.dark.hex}}" : "{{colors.surface_container.light.hex}}"
    readonly property color bgSurface: isDarkTheme ? "{{colors.surface.dark.hex}}" : "{{colors.surface.light.hex}}"

    // Decorative
    readonly property color shadowColor: isDarkTheme ? "#000000" : Qt.rgba(0,0,0, 0.2)

    // LOGGING
    onIsDarkThemeChanged: console.log(">>> [MATUGEN] Theme Flip. Dark Mode:", isDarkTheme)
}
