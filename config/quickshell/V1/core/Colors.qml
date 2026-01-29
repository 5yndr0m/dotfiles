pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property alias colors: colorAdapter

    FileView {
        id: colorFile
        path: Qt.resolvedUrl("./colors.json").toString().replace("file://", "")
        watchChanges: true
        blockLoading: true

        onFileChanged: reload()

        JsonAdapter {
            id: colorAdapter

            property string primary: "#e0c46d"
            property string on_primary: "#3c2f00"
            property string primary_container: "#564500"
            property string on_primary_container: "#fee086"
            property string primary_fixed: "#fee086"
            property string on_primary_fixed: "#231b00"
            property string primary_fixed_dim: "#e0c46d"
            property string on_primary_fixed_variant: "#564500"

            property string secondary: "#d4c6a1"
            property string on_secondary: "#383016"
            property string secondary_container: "#4f462a"
            property string on_secondary_container: "#f0e1bb"
            property string secondary_fixed: "#f0e1bb"
            property string on_secondary_fixed: "#221b04"
            property string secondary_fixed_dim: "#d4c6a1"
            property string on_secondary_fixed_variant: "#4f462a"

            property string tertiary: "#accfaf"
            property string on_tertiary: "#183720"
            property string tertiary_container: "#2e4e35"
            property string on_tertiary_container: "#c7ecca"
            property string tertiary_fixed: "#c7ecca"
            property string on_tertiary_fixed: "#02210d"
            property string tertiary_fixed_dim: "#accfaf"
            property string on_tertiary_fixed_variant: "#2e4e35"

            property string background: "#16130b"
            property string on_background: "#e9e2d4"
            property string surface: "#16130b"
            property string on_surface: "#e9e2d4"
            property string surface_variant: "#4c4639"
            property string on_surface_variant: "#cec6b4"
            property string surface_tint: "#e0c46d"

            property string surface_bright: "#3d392f"
            property string surface_dim: "#16130b"
            property string surface_container: "#231f17"
            property string surface_container_low: "#1e1b13"
            property string surface_container_lowest: "#110e07"
            property string surface_container_high: "#2d2a21"
            property string surface_container_highest: "#38342b"

            property string inverse_surface: "#e9e2d4"
            property string inverse_on_surface: "#343027"
            property string inverse_primary: "#715c0c"

            property string error: "#ffb4ab"
            property string on_error: "#690005"
            property string error_container: "#93000a"
            property string on_error_container: "#ffdad6"

            property string outline: "#979080"
            property string outline_variant: "#4c4639"
            property string shadow: "#000000"
            property string scrim: "#000000"
        }
    }
}
