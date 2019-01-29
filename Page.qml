import QtQuick 2.0

Rectangle {
    id: displayPane

    property bool opened: false
    property alias title: label.text

    signal openning()
    signal closing()

    color: "black"
    opacity: opened ? 1.0:0
    visible: opened

    function close()
    {
        displayPane.closing();
        disappear.start()
    }

    function open()
    {
        displayPane.openning();
        show.start();
    }

    focus: true

    Keys.onPressed: {
        if (event.key === 16777216) {
            Qt.quit();
        }
        else {
            console.log("Key pressed: " + event.key)
        }
    }

    Text {
        id: label
        width: parent.width
        height: 50
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 50
    }

    SequentialAnimation{
        id: disappear
        PropertyAnimation {
            target: displayPane
            properties: "width,height,opacity"
            to: 0
            duration: 250
        }
        PropertyAction {
            target: displayPane
            property: "visible"
            value: false
        }
        PropertyAction {
            target: displayPane
            property: "opened"
            value: false
        }
    }

    SequentialAnimation{
        id: show
        PropertyAction {
            target: displayPane
            property: "visible"
            value: true
        }
        ParallelAnimation {
            PropertyAnimation {
                target: displayPane
                properties: "opacity"
                from: 0
                to: 1.0
                duration: 1000
            }
        }
        PropertyAction {
            target: displayPane
            property: "opened"
            value: true
        }
    }

}
