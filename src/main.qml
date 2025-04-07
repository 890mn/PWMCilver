import QtQuick 2.15
import QtQuick.Window 2.15
import FluentUI 1.0
import "layout"

FluWindow {
    id: mainWindow
    width: 1081
    height: 627
    minimumWidth: 900
    minimumHeight: 422
    title: qsTr("PWMCilver")

    property color globalTextColor: "white"
    property color cosFTextColor: Qt.rgba(87/255,151/255,180/255,255/255)
    property color cosSTextColor: Qt.rgba(43/255,186/255,180/255,255/255)
    property color cosTTextColor: Qt.rgba(200/255,166/255,166/255,255/255)

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
