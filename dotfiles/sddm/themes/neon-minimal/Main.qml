import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: container

    property color bg: "#0A0A10"
    property color accent: "#008B8B"
    property color accentBright: "#00A3A6"
    property color fg: "#E0E0E0"
    property color selection: "#1E1E2F"
    property color urgent: "#C71585"

    width: 640
    height: 480
    anchors.fill: parent
    color: bg

    Clock {
        id: clock
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 40
        color: fg
        timeFont.family: "FiraCode Nerd Font"
        timeFont.pointSize: 28
        dateFont.family: "FiraCode Nerd Font"
        dateFont.pointSize: 10
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: 280

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "\u2693"
                font.family: "FiraCode Nerd Font"
                font.pointSize: 24
                color: accent
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "KALI LINUX"
            font.family: "FiraCode Nerd Font"
            font.pointSize: 11
            font.bold: true
            color: accent
            letterSpacing: 4
        }

        Item { Layout.preferredHeight: 8 }

        TextBox {
            id: username
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            font.family: "FiraCode Nerd Font"
            font.pointSize: 11
            color: fg
            borderColor: selection
            focusColor: accent
            hoverColor: accentBright
            placeholderText: "user"
            placeholderColor: Qt.rgba(fg.r, fg.g, fg.b, 0.3)
        }

        TextBox {
            id: password
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            font.family: "FiraCode Nerd Font"
            font.pointSize: 11
            color: fg
            borderColor: selection
            focusColor: accent
            hoverColor: accentBright
            placeholderText: "password"
            placeholderColor: Qt.rgba(fg.r, fg.g, fg.b, 0.3)
            echoMode: TextInput.Password
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ComboBox {
                id: session
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                font.family: "FiraCode Nerd Font"
                font.pointSize: 10
                model: model.sessions
                textRole: "name"
                currentIndex: 0
            }

            ComboBox {
                id: lang
                Layout.preferredWidth: 60
                Layout.preferredHeight: 32
                font.family: "FiraCode Nerd Font"
                font.pointSize: 10
                model: ["en", "es"]
                currentIndex: 0
            }
        }

        Button {
            id: loginButton
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            text: "LOGIN"
            font.family: "FiraCode Nerd Font"
            font.pointSize: 11
            font.bold: true

            contentItem: Text {
                text: loginButton.text
                font: loginButton.font
                color: bg
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: loginButton.hovered ? accentBright : accent
                radius: 0
            }

            onClicked: sddm.login(username.text, password.text, session.currentIndex)
        }

        Connections {
            target: password
            function onAccepted() {
                sddm.login(username.text, password.text, session.currentIndex)
            }
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 16
        text: "\u2693 NEON MINIMAL"
        font.family: "FiraCode Nerd Font"
        font.pointSize: 8
        color: Qt.rgba(fg.r, fg.g, fg.b, 0.3)
    }
}
