pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property alias settings: themeAdapter

    FileView {
        id: themeFile
        path: Qt.resolvedUrl("./theme.json").toString().replace("file://", "")
        blockLoading: true
        watchChanges: true

        onFileChanged: reload()

        JsonAdapter {
            id: themeAdapter

            property string fontFamily: "Google Sans"
            property string fontFamilyMaterial: "Material Symbols Rounded"
            property int fontSize: 14

            property int spacingNone: 0
            property int spacingXS: 4
            property int spacingS: 8
            property int spacingM: 12
            property int spacingL: 16
            property int spacingXL: 24

            property int paddingS: 8
            property int paddingL: 16
            property int elementSpacingXS: 4
            property int elementSpacingS: 8
            property int windowMarginM: 12
            property int windowMarginXL: 24

            property int roundNone: 0
            property int roundS: 8
            property int roundM: 12
            property int roundL: 16
            property int roundXL: 28
            property int roundFull: 9999

            property int barHeightS: 32
            property int barHeightM: 48
            property int iconSizeS: 18
            property int iconSizeM: 24
            property int iconSizeL: 32
        }
    }
}
