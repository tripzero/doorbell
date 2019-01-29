import QtQuick 2.0
import "settings.js" as Settings

Page {

    CircularProgressBar {
        width: parent.width / Settings.eye_size_factor
        height: parent.width / Settings.eye_size_factor
        anchors.centerIn: parent
        indeterminate: true
    }
}
