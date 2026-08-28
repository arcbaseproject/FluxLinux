import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    anchors.fill: parent

    property color accent: config.AccentColor || "#8fcaa3"
    property color surface: "#161a20"
    property color border: "#2c2f38"
    property color muted: "#8b949e"
    property color textColor: "#e8edf2"

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#0c0e12" }
        GradientStop { position: 0.55; color: "#12151b" }
        GradientStop { position: 1.0; color: "#0c0e12" }
    }

    Text {
        id: errorText
        anchors.bottom: passwordBar.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 14
        color: "#f87171"
        font.pixelSize: 13
        opacity: text.length > 0 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Connections {
        target: sddm
        function onLoginFailed() { errorText.text = "Login failed" }
    }

    Column {
        anchors.centerIn: parent
        spacing: 40

        Image {
            source: "logo-text.png"
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            sourceSize.width: 340
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            ComboBox {
                id: userBox
                anchors.horizontalCenter: parent.horizontalCenter
                model: userModel
                textRole: "name"
                currentIndex: userModel.lastIndex
                flat: true
                visible: userModel.count > 1
                background: Item {}
                contentItem: Text {
                    text: userBox.displayText
                    color: root.muted
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                id: passwordBar
                width: 360
                height: 48
                radius: 10
                color: root.surface
                border.width: 1
                border.color: passwordField.activeFocus ? root.accent : root.border

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: ""
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: root.accent
                    }

                    TextField {
                        id: passwordField
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 30
                        echoMode: TextInput.Password
                        placeholderText: "Password"
                        placeholderTextColor: root.muted
                        color: root.textColor
                        focus: true
                        background: Item {}
                        onAccepted: sddm.login(userBox.currentText, passwordField.text, sessionBox.currentIndex)
                    }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 16

        ComboBox {
            id: sessionBox
            anchors.verticalCenter: parent.verticalCenter
            width: contentItem.implicitWidth + 24
            model: sessionModel
            textRole: "name"
            currentIndex: sessionModel.lastIndex
            flat: true
            background: Item {}
            indicator: Item {}
            contentItem: Text {
                text: "  " + sessionBox.displayText + "  ⌄"
                font.family: "JetBrainsMono Nerd Font"
                color: root.muted
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
            }
        }

        Button {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            flat: true
            visible: sddm.canReboot
            contentItem: Text { text: parent.text; color: root.muted; font.pixelSize: 16; verticalAlignment: Text.AlignVCenter }
            onClicked: sddm.reboot()
        }
        Button {
            anchors.verticalCenter: parent.verticalCenter
            text: ""
            flat: true
            visible: sddm.canPowerOff
            contentItem: Text { text: parent.text; color: root.muted; font.pixelSize: 16; verticalAlignment: Text.AlignVCenter }
            onClicked: sddm.powerOff()
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
        property var now: new Date()
        Timer { interval: 30000; running: true; repeat: true; onTriggered: parent.now = new Date() }
        text: Qt.formatDateTime(now, "dddd, MMMM d — hh:mm")
        color: root.muted
        font.pixelSize: 13
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
