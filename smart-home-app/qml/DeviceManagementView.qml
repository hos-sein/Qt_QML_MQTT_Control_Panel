import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    
    Rectangle {
        anchors.fill: parent
        color: Theme.backgroundPrimary
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingL
        spacing: Theme.spacingM
        
        // Header
        Text {
            text: "Device Management"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTitle
            font.bold: true
            color: Theme.textPrimary
        }
        
        Text {
            text: "Manage all connected devices, test channels, and configure settings"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textSecondary
        }
        
        // Device list header
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM
            
            Text {
                Layout.fillWidth: true
                text: "Device ID"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.textSecondary
            }
            
            Text {
                width: 100
                text: "Type"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.textSecondary
            }
            
            Text {
                width: 80
                text: "Channels"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.textSecondary
            }
            
            Text {
                width: 120
                text: "Room"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.textSecondary
            }
            
            Text {
                width: 150
                text: "Actions"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.textSecondary
            }
            
            Item {
                width: Theme.touchTargetComfortable
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.dividerColor
        }
        
        // Device list
        ListView {
            id: deviceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: deviceModel
            clip: true
            spacing: Theme.spacingS
            
            delegate: Rectangle {
                width: deviceList.width
                height: deviceRow.height + Theme.spacingM * 2
                color: mouseArea.containsMouse ? Theme.backgroundCard : "transparent"
                radius: Theme.cardCornerRadius
                
                Behavior on color {
                    ColorAnimation { duration: Theme.animationFast }
                }
                
                RowLayout {
                    id: deviceRow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Theme.spacingM
                    spacing: Theme.spacingM
                    
                    Text {
                        Layout.fillWidth: true
                        text: model.deviceId
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        width: 100
                        text: model.deviceType
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }
                    
                    Text {
                        width: 80
                        text: model.channelCount.toString()
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }
                    
                    Text {
                        width: 120
                        text: model.roomName
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.accentPrimary
                        elide: Text.ElideRight
                    }
                    
                    RowLayout {
                        width: 150
                        spacing: Theme.spacingS
                        
                        Button {
                            Layout.preferredWidth: Theme.touchTargetMin
                            Layout.preferredHeight: Theme.touchTargetMin
                            
                            background: Rectangle {
                                color: parent.pressed ? Theme.backgroundCardHover : Theme.backgroundCard
                                radius: Theme.cardCornerRadius
                                border.color: Theme.borderColor
                            }
                            
                            contentItem: Text {
                                text: "⚙"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.textSecondary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                // Could open edit dialog
                            }
                        }
                        
                        Button {
                            Layout.preferredWidth: Theme.touchTargetMin
                            Layout.preferredHeight: Theme.touchTargetMin
                            
                            background: Rectangle {
                                color: parent.pressed ? Theme.errorColor + "40" : Theme.errorColor + "20"
                                radius: Theme.cardCornerRadius
                                border.color: Theme.errorColor
                            }
                            
                            contentItem: Text {
                                text: "🗑"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.errorColor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            onClicked: {
                                deleteDialog.deviceId = model.deviceId
                                deleteDialog.deviceName = model.deviceName
                                deleteDialog.open()
                            }
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
            
            // Empty state
            Text {
                anchors.centerIn: parent
                text: "No devices configured.\nUse the Dashboard to add devices."
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                color: Theme.textDisabled
                horizontalAlignment: Text.AlignHCenter
                visible: deviceList.count === 0
            }
        }
    }
    
    // Delete confirmation dialog
    Dialog {
        id: deleteDialog
        property string deviceId: ""
        property string deviceName: ""
        
        modal: true
        padding: Theme.spacingL
        
        background: Rectangle {
            color: Theme.backgroundSecondary
            radius: Theme.cardCornerRadius
            border.color: Theme.borderColor
        }
        
        title: Text {
            text: "Delete Device"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            color: Theme.textPrimary
        }
        
        contentItem: ColumnLayout {
            spacing: Theme.spacingM
            
            Text {
                Layout.fillWidth: true
                text: "Are you sure you want to delete \"" + deleteDialog.deviceName + "\" (ID: " + deleteDialog.deviceId + ")? This action cannot be undone."
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                color: Theme.textSecondary
                wrapMode: Text.WordWrap
            }
        }
        
        footer: RowLayout {
            spacing: Theme.spacingM
            
            Button {
                Layout.fillWidth: true
                text: "Cancel"
                
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
                
                onClicked: deleteDialog.close()
            }
            
            Button {
                Layout.fillWidth: true
                text: "Delete"
                
                background: Rectangle {
                    color: parent.pressed ? Theme.errorColor : Theme.errorColor
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
                    deviceModel.removeDevice(deleteDialog.deviceId)
                    deleteDialog.close()
                }
            }
        }
    }
}
