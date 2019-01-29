import QtQuick 2.0
import QtGraphicalEffects 1.0
import "settings.js" as Settings

Page {
    id: doorBell

    signal pressed()

    Text {
        anchors.right: button.left
        anchors.rightMargin: 20
        anchors.left: doorBell.left
        height: parent.height
        text: "Door"
        font.pixelSize: 50
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: "white"
    }

    Text {
        anchors.right: doorBell.right
        anchors.left: button.right
        anchors.leftMargin: 20
        height: parent.height
        text: "Bell"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pixelSize: 50
        color: "white"
    }

    RectangularGlow {
        spread: 0.5
        glowRadius: 10
        cornerRadius: button.radius + glowRadius
        color: button.color
        anchors.fill: button

        SequentialAnimation on glowRadius {
            loops: Animation.Infinite
            running: true
            PropertyAnimation { to: 40; duration: 1000 }
            PropertyAnimation { to: 10; duration: 1000 }
        }
    }


    Rectangle {
        id: button
        anchors.centerIn: parent
        radius: width / 2
        width: parent.width / Settings.eye_size_factor
        height: width
        color: "red"

        MouseArea {
            anchors.fill:parent

            onClicked: {
                doorBell.pressed()
            }

            onPressed: {
                button.color = "green"
            }

            onReleased: {
                button.color = "red"
            }
        }
    }
}
