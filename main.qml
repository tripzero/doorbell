import QtQuick 2.0
import QtQuick.Window 2.0

import MqttClient 1.0

Window {
    id: root
    visible: true
    width: 800 //1080
    height: 400 //1920
    title: qsTr("Doorbell")
    color: "black"

    property variant currentPage: blank
    property variant pages: [doorBell, notifyingHost, blank, no_soliciting_page, unavailable]

    property string camera_name: "FrontDoor"
    property string topic_motion: camera_name + "/Motion"
    property string topic_reject_not_available: "doorbell/reject/not_available"
    property string topic_reject_no_soliciting: "doorbell/reject/no_soliciting"
    property string topic_doorbell_ring: "doorbell/ring"

    property variant motion_subscription: null
    property variant not_available_subscription: null
    property variant no_soliciting_subscription: null

    MqttClient {
        id: client
        hostname: "192.168.1.40"
        port: 1883

        Component.onCompleted: {
            client.connectToHost()
            text_msg.text = "connecting"
        }

        onConnected: {
            text_msg.text = "connected!"
            //do subscriptions

            motion_subscription = client.subscribe(topic_motion)
            motion_subscription.messageReceived.connect(motion_detected)

            not_available_subscription = client.subscribe(topic_reject_not_available)
            not_available_subscription.messageReceived.connect(not_available)

            no_soliciting_subscription = client.subscribe(topic_reject_no_soliciting)
            no_soliciting_subscription.messageReceived.connect(no_soliciting)
        }

        onDisconnected: {
            text_msg.text = "Disconnected!!!"
        }
    }

    function motion_detected(val) {
        text_msg.text = "motion " + val
        if (val === "True")
        {
            show_ringer()
        }
    }

    function not_available() {
        root.show(unavailable)
    }

    function no_soliciting() {
        root.show(no_soliciting_page)
        //text_msg.text = "No soliciting"
    }

    function show(page)
    {
        if (page === root.currentPage)
        {
            return
        }

        for (var p=0; p<pages.length; p++)
        {
            if (pages[p] !== page)
                pages[p].close();
        }

        console.log("Displaying: " + page.objectName);

        page.open()
        root.currentPage = page

        reset_blank()
    }

    function showStr(page)
    {
        for (var p=0; p<pages.length; p++)
        {
            if (pages[p].objectName === page)
            {
                show(pages[p])
                return;
            }
        }

        console.error("Failed to find page called: '" + page + "'")
    }

    Page {
        id: blank
        objectName: "blank"
        anchors.fill: parent
        opened: false

        MouseArea {
            anchors.fill: parent
            onPressed: {
                root.show(doorBell)
            }
        }

        onClosing: {
            console.log("should be closed...")
        }
    }

    Text {
        id: text_msg
        color: "white"
        width: parent.width
        height: 50
        font.pixelSize: height/2
        anchors.bottom: parent.bottom
        horizontalAlignment: Text.Center
        verticalAlignment: Text.Center

        onTextChanged: {
            if (text_msg.text !== "")
                text_msg_timeout.start()
        }

        Timer {
            id: text_msg_timeout
            interval: 60000

            onTriggered: {
                text_msg.text = ""
            }
        }
    }

    function show_ringer() {
        if (root.currentPage == blank)
        {
            root.show(doorBell)
        }
    }

    function show_ringer_waiting() {
        root.show(notifyingHost)
    }

    function ring_bell() {
        var publish_ret  = client.publish(topic_doorbell_ring, "ringing", 1);
        console.log("publish result" + publish_ret)
    }

    function reset_blank() {
        multiring_timer.stop()
        ringer_timeout.stop()

        blank_timeout.restart()
    }

    function show_blank() {
        root.show(blank)
        blank_timeout.stop()
    }

    DoorBell {
        id: doorBell
        objectName: "doorBell"
        anchors.fill: parent
        onPressed: {
            ring_bell()
            show_ringer_waiting()
            blank_timeout.stop()
            multiring_timer.start()
            ringer_timeout.start()
        }
    }

    LoadingScreen {
        id: notifyingHost
        objectName: "notifyingHost"

        property string hostName: "host"

        anchors.fill: parent
        title: "Notifying " + hostName + "..."

        onOpenedChanged: {
            if (opened)
            {
                //tts.speak("Please wait while I notify the host")
            }
        }
    }

    Page {
        id: unavailable
        objectName: "unavailable"
        anchors.fill: parent
        title: "Host is not available"

        onOpenedChanged: {
            if (opened)
            {
                //tts.speak("I am sorry, this host is not available for your call")
            }
        }

        Text {
            anchors.centerIn: parent
            width: parent.width
            height: 40
            font.pixelSize: 50
            text: "Please call again"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "white"
        }
    }

    Page {
        id: no_soliciting_page
        objectName: "no_soliciting"
        anchors.fill: parent
        title: "No soliciting"

        onOpenedChanged: {
            if (opened)
            {
                //tts.speak("I am sorry, this host is not available for your call")
            }
        }

        Text {
            anchors.centerIn: parent
            width: parent.width
            height: 40
            font.pixelSize: 50
            text: "The host does not accept solicitors"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "white"
        }
    }

    Timer {
        id: multiring_timer
        repeat: true
        running: false
        interval: 10000

        property int run_count: 0
        property int run_max: 3

        onTriggered: {
            ring_bell()
            run_count++;

            if (run_count >= run_max)
            {
                multiring_timer.stop()
            }
        }
    }

    Timer {
        id: ringer_timeout
        running: false
        interval: 60000

        onTriggered: {
            console.log("ringer timeout")
            not_available()
        }
    }

    Timer {
        id: blank_timeout
        running: false
        interval: 60000

        onTriggered: {
            console.log("blank timeout!")
            show_blank()
        }
    }
}
