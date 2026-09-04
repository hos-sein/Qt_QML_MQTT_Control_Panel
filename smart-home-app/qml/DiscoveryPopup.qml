import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Dialog {
    id: root
    
    property var deviceConfig: ({})
    
    modal: true
    padding: Theme.spacingL
    background: Rectangle {
        color: Theme.backgroundSecondary
        radius: Theme.cardCornerRadius
        border.color: Theme.borderColor
    }
    
    title: Text {
        text: "New Device Discovered"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLarge
        font.bold: true
        color: Theme.textPrimary
    }
    
    contentItem: ColumnLayout {
        spacing: Theme.spacingM
        
        // Device info card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: deviceInfoColumn.implicitHeight + Theme.spacingM * 2
            color: Theme.backgroundCard
            radius: Theme.cardCornerRadius
            
            ColumnLayout {
                id: deviceInfoColumn
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS
                
                Text {
                    Layout.fillWidth: true
                    text: "Device ID: " + (deviceConfig.deviceId || "Unknown")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.textPrimary
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Type: " + (deviceConfig.deviceType || "Switch")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.textSecondary
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Channels: " + (deviceConfig.channelCount || 1)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.textSecondary
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Suggested Room: " + (deviceConfig.roomName || "Unassigned")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.accentPrimary
                }
            }
        }
        
        // Room selection
        Text {
            text: "Assign to Room:"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textSecondary
        }
        
        ComboBox {
            id: roomComboBox
            Layout.fillWidth: true
            model: deviceModel.getAllRooms()
            currentIndex: 0
            
            background: Rectangle {
                color: Theme.backgroundCard
                radius: Theme.cardCornerRadius
                border.color: Theme.borderColor
                border.width: 1
            }
            
            contentItem: Text {
                leftPadding: Theme.spacingM
                rightPadding: Theme.spacingM
                text: roomComboBox.displayText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                color: Theme.textPrimary
                verticalAlignment: Text.AlignVCenter
            }
            
            popup: Popup {
                y: roomComboBox.height
                width: roomComboBox.width
                implicitHeight: contentItem.implicitHeight
                padding: Theme.spacingXS
                
                background: Rectangle {
                    color: Theme.backgroundSecondary
                    radius: Theme.cardCornerRadius
                    border.color: Theme.borderColor
                }
                
                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: roomComboBox.popup.visible ? roomComboBox.delegateModel : null
                    ScrollIndicator.vertical: ScrollIndicator {}
                }
            }
            
            delegate: ItemDelegate {
                width: roomComboBox.width
                height: Theme.touchTargetComfortable
                
                contentItem: Text {
                    text: modelData
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: Theme.spacingM
                }
                
                background: Rectangle {
                    color: highlighted ? Theme.backgroundCardHover : "transparent"
                    radius: Theme.cardCornerRadius
                }
            }
        }
        
        Item {
            Layout.fillHeight: true
        }
    }
    
    footer: RowLayout {
        spacing: Theme.spacingM
        
        Button {
            Layout.fillWidth: true
            text: "Ignore"
            
            background: Rectangle {
                color: parent.pressed ? Theme.backgroundCardHover : Theme.backgroundCard
                radius: Theme.cardCornerRadius
                border.color: Theme.borderColor
            }
            
            contentItem: Text {
                text: parent.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                root.close()
                root.deviceConfig = {}
            }
        }
        
        Button {
            Layout.fillWidth: true
            text: "Add Device"
            
            background: Rectangle {
                color: parent.pressed ? Theme.accentSecondary : Theme.accentPrimary
                radius: Theme.cardCornerRadius
            }
            
            contentItem: Text {
                text: parent.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            onClicked: {
                if (root.deviceConfig.deviceId) {
                    mqttController.addDeviceManually(
                        root.deviceConfig.deviceId,
                        root.deviceConfig.deviceType || "Switch",
                        root.deviceConfig.channelCount || 1,
                        roomComboBox.currentText || root.deviceConfig.roomName || "Living Room",
                        root.deviceConfig.deviceName || ("Device " + root.deviceConfig.deviceId)
                    )
                    deviceModel.loadDevices()
                }
                root.close()
                root.deviceConfig = {}
            }
        }
    }
    
    onOpened: {
        // Populate room combo box
        roomComboBox.model = deviceModel.getAllRooms()
        if (roomComboBox.model.length === 0) {
            roomComboBox.model = ["Living Room", "Bedroom", "Kitchen", "Bathroom"]
        }
    }
}
