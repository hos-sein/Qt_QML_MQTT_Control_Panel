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
        spacing: Theme.spacingL
        
        // Header
        Text {
            text: "Settings"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeTitle
            font.bold: true
            color: Theme.textPrimary
        }
        
        // Broker Status Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: brokerStatusColumn.implicitHeight + Theme.spacingL * 2
            color: Theme.backgroundCard
            radius: Theme.cardCornerRadius
            border.color: mqttController.connected ? Theme.successColor : Theme.errorColor
            border.width: 2
            
            ColumnLayout {
                id: brokerStatusColumn
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingM
                    
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 24
                        color: mqttController.connected ? Theme.successColor : Theme.errorColor
                        
                        Text {
                            anchors.centerIn: parent
                            text: mqttController.connected ? "✓" : "✕"
                            font.pixelSize: Theme.fontSizeLarge
                            font.bold: true
                            color: Theme.textPrimary
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS
                        
                        Text {
                            text: "MQTT Broker Status"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeMedium
                            font.bold: true
                            color: Theme.textPrimary
                        }
                        
                        Text {
                            text: mqttController.connected ? "Connected and operational" : "Disconnected - attempting to reconnect"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.textSecondary
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.dividerColor
                }
                
                // Connection details
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingL
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS
                        
                        Text {
                            text: "Broker Address"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textDisabled
                        }
                        
                        Text {
                            text: mqttController.brokerHost + ":" + mqttController.brokerPort
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.accentPrimary
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS
                        
                        Text {
                            text: "Protocol"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textDisabled
                        }
                        
                        Text {
                            text: "MQTT 3.1.1 / TCP"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.textPrimary
                        }
                    }
                }
            }
        }
        
        // Database Info Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: dbInfoColumn.implicitHeight + Theme.spacingL * 2
            color: Theme.backgroundCard
            radius: Theme.cardCornerRadius
            
            ColumnLayout {
                id: dbInfoColumn
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM
                
                Text {
                    text: "Database"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingL
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS
                        
                        Text {
                            text: "Storage Engine"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textDisabled
                        }
                        
                        Text {
                            text: "SQLite"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.textPrimary
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS
                        
                        Text {
                            text: "Total Devices"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textDisabled
                        }
                        
                        Text {
                            text: deviceModel.count.toString()
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.accentPrimary
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingXS
                        
                        Text {
                            text: "Rooms"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textDisabled
                        }
                        
                        Text {
                            text: deviceModel.getAllRooms().length.toString()
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.textPrimary
                        }
                    }
                }
            }
        }
        
        // Topic Patterns Card
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.backgroundCard
            radius: Theme.cardCornerRadius
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingL
                spacing: Theme.spacingM
                
                Text {
                    text: "MQTT Topic Patterns"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeMedium
                    font.bold: true
                    color: Theme.textPrimary
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Control Topic (publish to toggle devices):"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: controlTopicText.implicitHeight + Theme.spacingM
                    color: Theme.backgroundSecondary
                    radius: Theme.cardCornerRadius
                    
                    Text {
                        id: controlTopicText
                        anchors.centerIn: parent
                        text: "switch/{device_id}/ch/{channel_id}/control"
                        font.family: "monospace"
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.accentPrimary
                    }
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "State Topic (subscribe for updates):"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: stateTopicText.implicitHeight + Theme.spacingM
                    color: Theme.backgroundSecondary
                    radius: Theme.cardCornerRadius
                    
                    Text {
                        id: stateTopicText
                        anchors.centerIn: parent
                        text: "switch/{device_id}/ch/{channel_id}/state"
                        font.family: "monospace"
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.accentPrimary
                    }
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "Auto-Discovery Topic:"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.textSecondary
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: discoveryTopicText.implicitHeight + Theme.spacingM
                    color: Theme.backgroundSecondary
                    radius: Theme.cardCornerRadius
                    
                    Text {
                        id: discoveryTopicText
                        anchors.centerIn: parent
                        text: "home/discovery/{device_id}/config"
                        font.family: "monospace"
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.accentPrimary
                    }
                }
                
                Item {
                    Layout.fillHeight: true
                }
                
                // Payload format info
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: payloadInfo.implicitHeight + Theme.spacingM * 2
                    color: Theme.backgroundSecondary
                    radius: Theme.cardCornerRadius
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS
                        
                        Text {
                            text: "Payload Format:"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: Theme.textSecondary
                        }
                        
                        Text {
                            id: payloadInfo
                            Layout.fillWidth: true
                            text: "• Control: \"ON\" or \"OFF\"\n• State: \"ON\" or \"OFF\"\n• Discovery: JSON with device_id, device_type, channel_count, room_name"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textDisabled
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
        
        // App Info
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM
            
            Text {
                Layout.fillWidth: true
                text: "Smart Home Management Panel v1.0"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textDisabled
            }
            
            Text {
                text: "Qt 6 | QML | MQTT"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textDisabled
            }
        }
    }
}
