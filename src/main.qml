import QtQuick 2.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "layout"

FluWindow {
    id: mainWindow
    width: 1150
    height: 627
    minimumWidth: 920
    minimumHeight: 422
    title: qsTr("PWMCilver")

    property color globalTextColor: Qt.rgba(245/255,245/255,245/255,255/255)

    property color colorBlue: Qt.rgba(87/255,151/255,180/255,255/255)
    property color colorBlueHover: Qt.rgba(77/255,141/255,170/255,255/255)

    property color colorGreen: Qt.rgba(43/255,186/255,180/255,255/255)
    property color colorGreenHover: Qt.rgba(33/255,176/255,170/255,255/255)

    property color colorPink: Qt.rgba(200/255,166/255,166/255,255/255)
    property color colorPinkHover: Qt.rgba(190/255,156/255,156/255,255/255)

    property color colorWhiteHover: Qt.rgba(255/255,255/255,255/255,255/255)
    property color colorWhite: Qt.rgba(245/255,245/255,245/255,255/255)

    property color colorGrayHover: Qt.rgba(98/255, 90/255, 96/255, 255/255)
    property color colorGray: Qt.rgba(88/255, 80/255, 86/255, 255/255)

    FontLoader {
        id: brushFont
        source: "qrc:/asset/BrushGrunge.ttf"
    }

    FontLoader {
        id: smileFont
        source: "qrc:/asset/SmileySans-Oblique.ttf"
    }

    // 背景换成白色纯色背景
    Rectangle {
        anchors.fill: parent

        Image{
            source: "qrc:/asset/back.jpg"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            opacity: 0.95
        }

        InitialLayout {
            id: initialLayout
            anchors.fill: parent
            onStartSimulation: {
                startAnimation.start()
            }
        }

        SimulationLayout {
            id: simulationLayout
            anchors.fill: parent
            visible: false
            onReturnToHome: {
                returnAnimation.start()
        }
        }

        SequentialAnimation {
            id: startAnimation
            ParallelAnimation {
                NumberAnimation { target: initialLayout; property: "opacity"; to: 0; duration: 400 }
                NumberAnimation { target: simulationLayout; property: "opacity"; to: 1; duration: 400 }
            }
            ScriptAction {
                script: {
                    initialLayout.visible = false
                    initialLayout.opacity = 0
                    simulationLayout.visible = true
                    simulationLayout.opacity = 1
                }
            }
        }

        SequentialAnimation {
            id: returnAnimation
            ParallelAnimation {
                NumberAnimation { target: initialLayout; property: "opacity"; to: 1; duration: 400 }
                NumberAnimation { target: simulationLayout; property: "opacity"; to: 0; duration: 400 }
            }
            ScriptAction {
                script: {
                    simulationLayout.visible = false
                    simulationLayout.opacity = 0
                    initialLayout.visible = true
                    initialLayout.opacity = 1
                }
            }
        }
    }
}
