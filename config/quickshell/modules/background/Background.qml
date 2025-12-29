import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import qs.Components
import qs.config

PanelWindow {
    id: bg
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background

    property date currentTime: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: bg.currentTime = new Date()
    }

    component ShadowText: Item {
        property alias text: label.text
        property alias color: label.color
        property alias font: label.font
        property alias horizontalAlignment: label.horizontalAlignment
        property alias letterSpacing: label.font.letterSpacing

        width: label.implicitWidth
        height: label.implicitHeight

        Text {
            id: label
            anchors.fill: parent
            visible: false
        }

        DropShadow {
            anchors.fill: label
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 17
            color: ThemeAuto.shadowColor
            source: label
            visible: label.text !== ""
        }
    }

    ColumnLayout {
        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 25
        }
        spacing: -30

        // 1. TIME BLOCK
        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 12

            ShadowText {
                text: Qt.formatDateTime(bg.currentTime, "HH")
                color: ThemeAuto.accent
                font {
                    pixelSize: 160
                    weight: Font.Black
                    family: "Google Sans Display"
                }
                letterSpacing: -8
            }

            ColumnLayout {
                spacing: -5
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 32

                ShadowText {
                    text: Qt.formatDateTime(bg.currentTime, "ss")
                    color: ThemeAuto.textSecondary
                    font {
                        pixelSize: 32
                        weight: Font.Bold
                        family: "Google Sans"
                    }
                }

                ShadowText {
                    text: Qt.formatDateTime(bg.currentTime, "mm")
                    color: ThemeAuto.textMain
                    font {
                        pixelSize: 72
                        weight: Font.Light
                        family: "Google Sans"
                    }
                    letterSpacing: -2
                }
            }
        }

        // 2. DATE BLOCK
        ColumnLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 4

            ShadowText {
                text: Qt.formatDateTime(bg.currentTime, "dddd").toUpperCase()
                color: ThemeAuto.textSecondary
                Layout.alignment: Qt.AlignRight
                font {
                    pixelSize: 18
                    weight: Font.Black
                    family: "Google Sans"
                }
                letterSpacing: 4
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 12

                ShadowText {
                    text: Qt.formatDateTime(bg.currentTime, "d")
                    color: ThemeAuto.textMain
                    font {
                        pixelSize: 48
                        weight: Font.ExtraLight
                        family: "Google Sans"
                    }
                }

                ColumnLayout {
                    spacing: 0
                    ShadowText {
                        text: Qt.formatDateTime(bg.currentTime, "MMMM")
                        color: ThemeAuto.accent
                        font {
                            pixelSize: 22
                            weight: Font.Bold
                            family: "Google Sans"
                        }
                    }
                    ShadowText {
                        text: Qt.formatDateTime(bg.currentTime, "yyyy")
                        color: ThemeAuto.accent
                        font {
                            pixelSize: 16
                            weight: Font.Bold
                            family: "Google Sans"
                        }
                    }
                }
            }
        }
    }
}
