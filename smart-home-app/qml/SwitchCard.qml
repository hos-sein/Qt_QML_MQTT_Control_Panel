import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    
    property string deviceName: "Device"
    property string deviceId: ""
    property int channelCount: 1
    property var channelStates: ["OFF"]
    property bool isOn: channelStates.length > 0 && channelStates[0] === "ON"
    property real width: 160
    property real height: 120
    
    signal toggled(int channelId)
    signal clicked()
    
    Rectangle {
        id: cardBackground
        anchors.fill: parent
        radius: Theme.cardCornerRadius
        color: isOn ? Theme.backgroundCardHover : Theme.backgroundCard
        border.color: isOn ? Theme.accentPrimary : Theme.borderColor
        border.width: isOn ? 2 : 1
        
        Behavior on color {
            ColorAnimation {
                duration: Theme.animationNormal
            }
        }
        
        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animationNormal
            }
        }
        
        // Glow effect when ON
        Rectangle {
            anchors.fill: parent
            radius: Theme.cardCornerRadius
            color: Theme.accentGlow
            visible: isOn
            opacity: isOn ? 0.3 : 0
            
            Behavior on opacity {
                OpacityAnimator {
                    duration: Theme.animationNormal
                }
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS
            
            // Device name
            Text {
                Layout.fillWidth: true
                text: deviceName
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMedium
                font.bold: true
                color: Theme.textPrimary
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
            
            // Device ID (smaller text)
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: deviceId
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
            }
            
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            // Channel indicators
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.spacingS
                
                Repeater {
                    model: channelCount
                    
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: channelStates[index] === "ON" ? Theme.successColor : Theme.textDisabled
                        
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animationFast
                            }
                        }
                        
                        ToolTip.visible: mouseArea.containsMouse
                        ToolTip.text: "Channel " + (index + 1) + ": " + channelStates[index]
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                root.toggled(index + 1)
                            }
                        }
                    }
                }
            }
            
            // Status indicator
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: statusText.implicitWidth + Theme.spacingM
                height: 24
                radius: 12
                color: isOn ? Theme.successColor + "20" : Theme.textDisabled + "20"
                
                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: isOn ? "ON" : "OFF"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.bold: true
                    color: isOn ? Theme.successColor : Theme.textDisabled
                }
            }
        }
        
        // Touch feedback overlay
        Rectangle {
            id: touchFeedback
            anchors.fill: parent
            radius: Theme.cardCornerRadius
            color: Theme.accentPrimary
            opacity: 0
            
            Behavior on opacity {
                OpacityAnimator {
                    duration: Theme.animationFast
                }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            
            onPressed: {
                touchFeedback.opacity = 0.1
            }
            
            onReleased: {
                touchFeedback.opacity = 0
                root.clicked()
            }
            
            onEntered: {
                if (!isOn) {
                    cardBackground.color = Theme.backgroundCardHover
                }
            }
            
            onExited: {
                if (!isOn) {
                    cardBackground.color = Theme.backgroundCard
                }
            }
        }
    }
}
