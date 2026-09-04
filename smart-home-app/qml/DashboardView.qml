import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    
    property string selectedRoom: "All Rooms"
    
    Rectangle {
        anchors.fill: parent
        color: Theme.backgroundPrimary
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM
        
        // Header with room selector
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM
            
            Text {
                text: "Dashboard"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeTitle
                font.bold: true
                color: Theme.textPrimary
            }
            
            Item {
                Layout.fillWidth: true
            }
            
            // Room selector
            ComboBox {
                id: roomSelector
                width: 200
                model: ["All Rooms"] + deviceModel.getAllRooms()
                currentIndex: model.indexOf(selectedRoom) >= 0 ? model.indexOf(selectedRoom) : 0
                
                background: Rectangle {
                    color: Theme.backgroundCard
                    radius: Theme.cardCornerRadius
                    border.color: Theme.borderColor
                }
                
                contentItem: Text {
                    leftPadding: Theme.spacingM
                    rightPadding: Theme.spacingM + roomSelector.indicator.width
                    text: roomSelector.displayText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.textPrimary
                    verticalAlignment: Text.AlignVCenter
                }
                
                indicator: Canvas {
                    x: roomSelector.width - width - Theme.spacingM
                    y: roomSelector.topPadding + (roomSelector.availableHeight - height) / 2
                    width: 12
                    height: 8
                    
                    onPaint: {
                        context.reset()
                        context.moveTo(0, 0)
                        context.lineTo(width, 0)
                        context.lineTo(width / 2, height)
                        context.closePath()
                        context.fillStyle = Theme.textSecondary
                        context.fill()
                    }
                }
                
                popup: Popup {
                    y: roomSelector.height
                    width: roomSelector.width
                    padding: Theme.spacingXS
                    
                    background: Rectangle {
                        color: Theme.backgroundSecondary
                        radius: Theme.cardCornerRadius
                        border.color: Theme.borderColor
                    }
                    
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: roomSelector.popup.visible ? roomSelector.delegateModel : null
                        ScrollIndicator.vertical: ScrollIndicator {}
                    }
                }
                
                delegate: ItemDelegate {
                    width: roomSelector.width
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
                
                onCurrentTextChanged: {
                    selectedRoom = currentText
                    if (currentText === "All Rooms") {
                        deviceModel.loadDevices()
                    } else {
                        deviceModel.loadDevicesByRoom(currentText)
                    }
                }
            }
            
            // Add device button
            Button {
                Layout.preferredWidth: Theme.touchTargetComfortable
                Layout.preferredHeight: Theme.touchTargetComfortable
                
                background: Rectangle {
                    color: parent.pressed ? Theme.accentSecondary : Theme.accentPrimary
                    radius: Theme.cardCornerRadius
                }
                
                contentItem: Text {
                    text: "+"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeXLarge
                    font.bold: true
                    color: Theme.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    addDeviceWizard.open()
                }
            }
        }
        
        // Device count indicator
        Text {
            text: deviceModel.count + " device(s) in " + (selectedRoom === "All Rooms" ? "all rooms" : selectedRoom)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textSecondary
        }
        
        // Devices grid
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            
            GridView {
                id: devicesGrid
                width: Math.max(parent.width, implicitWidth)
                height: Math.max(parent.height, implicitHeight)
                cellWidth: 180
                cellHeight: 140
                model: deviceModel
                spacing: Theme.spacingM
                
                delegate: SwitchCard {
                    width: 160
                    height: 120
                    deviceName: model.deviceName || ("Device " + model.deviceId)
                    deviceId: model.deviceId
                    channelCount: model.channelCount
                    channelStates: model.channelStates
                    
                    onToggled: function(channelId) {
                        deviceModel.toggleChannel(model.deviceId, channelId)
                    }
                    
                    onClicked: {
                        // Could open detailed view here
                    }
                }
                
                // Empty state
                Text {
                    anchors.centerIn: parent
                    text: selectedRoom === "All Rooms" ? 
                          "No devices added yet.\nClick + to add a device." :
                          "No devices in " + selectedRoom
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.textDisabled
                    horizontalAlignment: Text.AlignHCenter
                    visible: devicesGrid.count === 0
                }
            }
        }
    }
    
    // Discovery popup
    DiscoveryPopup {
        id: discoveryPopup
        deviceConfig: mqttController.pendingDiscovery || {}
    }
    
    // Add device wizard
    AddDeviceWizard {
        id: addDeviceWizard
    }
    
    // Connection status indicator
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Theme.spacingM
        width: statusRow.implicitWidth + Theme.spacingM
        height: 32
        radius: 16
        color: Theme.backgroundCard
        border.color: mqttController.connected ? Theme.successColor : Theme.errorColor
        border.width: 1
        
        RowLayout {
            id: statusRow
            anchors.centerIn: parent
            spacing: Theme.spacingS
            
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: mqttController.connected ? Theme.successColor : Theme.errorColor
                
                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast }
                }
            }
            
            Text {
                text: mqttController.connected ? "Connected" : "Disconnected"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
            }
        }
    }
}
