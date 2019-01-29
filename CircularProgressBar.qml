import QtQml 2.2
import QtQuick 2.0

// draws two arcs (portion of a circle)
// fills the circle with a lighter secondary color
// when pressed

import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0



Rectangle {
    id: circularProgressBar
    width: 240
    height: 240
    color: "black"

    property alias progressBar: canvas
    property alias indeterminate: canvas.indeterminate
    property alias primaryColor: canvas.primaryColor
    property alias secondaryColor: canvas.secondaryColor

    RectangularGlow {
        spread: 0.5
        glowRadius: 5
        cornerRadius: progressBar.width / 2 + glowRadius
        color: progressBar.secondaryColor
        anchors.fill: progressBar
        opacity: ( progressBar.value / 100.0 )
    }

    RectangularGlow {
        spread: 0.5
        glowRadius: 5
        cornerRadius: progressBar.width / 2 + glowRadius
        color: progressBar.primaryColor
        anchors.fill: progressBar

        opacity: 1.0 - (progressBar.value/100)
    }

    Rectangle {
        anchors.fill: progressBar
        color: parent.color
        radius: Math.min(progressBar.width / 2, progressBar.height / 2)
    }

    Canvas {
        id: canvas

        anchors.fill:parent
        anchors.margins: 10

        antialiasing: true

        property bool indeterminate: false

        property color primaryColor: "orange"
        property color secondaryColor: "lightblue"

        property real centerWidth: width / 2
        property real centerHeight: height / 2
        property real radius: Math.min(canvas.width, canvas.height) / 2 - (strokeWidth / 2)

        property real minimumValue: 0
        property real maximumValue: 100
        property real value: 0

        // this is the angle that splits the circle in two arcs
        // first arc is drawn from 0 radians to angle radians
        // second arc is angle radians to 2*PI radians
        property real angle: (value - minimumValue) / (maximumValue - minimumValue) * 2 * Math.PI

        // we want both circle to start / end at 12 o'clock
        // without this offset we would start / end at 9 o'clock
        property real angleOffset: -Math.PI / 2

        property string text: ""

        property real strokeWidth: 4

        signal clicked()

        onPrimaryColorChanged: requestPaint()
        onSecondaryColorChanged: requestPaint()
        onMinimumValueChanged: requestPaint()
        onMaximumValueChanged: requestPaint()
        onValueChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.save();

            ctx.clearRect(0, 0, canvas.width, canvas.height);

            // fills the mouse area when pressed
            // the fill color is a lighter version of the
            // secondary color

            if (mouseArea.pressed) {
                ctx.beginPath();
                ctx.lineWidth = width;
                ctx.fillStyle = Qt.lighter(canvas.secondaryColor, 1.25);
                ctx.arc(canvas.centerWidth,
                        canvas.centerHeight,
                        canvas.radius,
                        0,
                        2*Math.PI);
                ctx.fill();
            }

            // First, thinner arc
            // From angle to 2*PI

            ctx.beginPath();
            ctx.lineWidth = strokeWidth;
            ctx.strokeStyle = primaryColor;
            ctx.arc(canvas.centerWidth,
                    canvas.centerHeight,
                    canvas.radius,
                    angleOffset + canvas.angle,
                    angleOffset + 2*Math.PI);
            ctx.stroke();


            // Second, thicker arc
            // From 0 to angle

            ctx.beginPath();
            ctx.lineWidth = strokeWidth;
            ctx.strokeStyle = canvas.secondaryColor;
            ctx.arc(canvas.centerWidth,
                    canvas.centerHeight,
                    canvas.radius,
                    canvas.angleOffset,
                    canvas.angleOffset + canvas.angle);
            ctx.stroke();

            ctx.restore();
        }

        Text {
            anchors.centerIn: parent

            text: canvas.text
            color: canvas.primaryColor
        }

        MouseArea {
            id: mouseArea

            anchors.fill: parent
            onClicked: canvas.clicked()
            onPressedChanged: canvas.requestPaint()
        }

        PropertyAnimation {
            target: canvas
            running: canvas.indeterminate
            loops: Animation.Infinite
            properties: "value"
            //easing.type: Easing.OutInSine
            from: 0
            to: 100
            duration: 2000
        }
    }

    RotationAnimation {
        target: circularProgressBar
        from: 0
        to: 360
        duration: 5000
        running: true
        easing.type: Easing.OutInExpo
        loops: Animation.Infinite
    }
}

