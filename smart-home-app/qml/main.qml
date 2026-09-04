import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SmartHomeApp

ApplicationWindow {
    id: window
    visible: true
    width: 1024
    height: 768
    title: "Smart Home Management Panel"
    color: Theme.backgroundPrimary
    
    // Ensure the window doesn't go below minimum size for touch panel
    minimumWidth: 800
    minimumHeight: 600
    
    // Sidebar navigation
    Rectangle {
        id: sidebar
        width: 220
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: Theme.backgroundSecondary
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingS
            
            // App Logo/Title
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "transparent"
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Theme.spacingXS
                    
                    Text {
                        text: "🏠"
                        font.pixelSize: 32
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Smart Home"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.bold: true
                        color: Theme.textPrimary
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Panel"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.accentPrimary
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.dividerColor
            }
            
            Item {
                Layout.fillHeight: true
            }
            
            // Navigation buttons
            NavigationButton {
                Layout.fillWidth: true
                icon: "📊"
                text: "Dashboard"
                isActive: stackView.currentItem === dashboardView
                onClicked: stackView.push(dashboardView)
            }
            
            NavigationButton {
                Layout.fillWidth: true
                icon: "🔧"
                text: "Devices"
                isActive: stackView.currentItem === deviceManagementView
                onClicked: stackView.push(deviceManagementView)
            }
            
            NavigationButton {
                Layout.fillWidth: true
                icon: "⚙"
                text: "Settings"
                isActive: stackView.currentItem === settingsView
                onClicked: stackView.push(settingsView)
            }
            
            Item {
                Layout.fillHeight: true
            }
            
            // Connection status in sidebar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: Theme.backgroundCard
                radius: Theme.cardCornerRadius
                
                RowLayout {
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
                        text: mqttController.connected ? "Online" : "Offline"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textSecondary
                    }
                }
            }
        }
    }
    
    // Main content area
    StackView {
        id: stackView
        anchors.left: sidebar.right
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        
        initialItem: DashboardView {
            id: dashboardView
        }
        
        property Item deviceManagementView: DeviceManagementView { }
        property Item settingsView: SettingsView { }
        
        function push(item) {
            if (currentItem !== item) {
                replace(item)
            }
        }
    }
    
    // Component for navigation buttons
    component NavigationButton: Rectangle {
        id: navButton
        property string icon: ""
        property string text: ""
        property bool isActive: false
        
        color: mouseArea.containsMouse ? Theme.backgroundCard : 
               isActive ? Theme.backgroundCardHover : "transparent"
        radius: Theme.cardCornerRadius
        
        Behavior on color {
            ColorAnimation { duration: Theme.animationFast }
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacingM
            spacing: Theme.spacingM
            
            Text {
                text: navButton.icon
                font.pixelSize: Theme.fontSizeLarge
            }
            
            Text {
                Layout.fillWidth: true
                text: navButton.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                font.bold: isActive
                color: isActive ? Theme.accentPrimary : Theme.textPrimary
                elide: Text.ElideRight
            }
        }
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                navButton.clicked()
            }
        }
        
        signal clicked()
    }
    
    // Handle device discovery notifications
    Connections {
        target: mqttController
        
        function onDeviceDiscovered(deviceConfig) {
            discoveryPopup.deviceConfig = deviceConfig
            discoveryPopup.open()
        }
    }
    
    DiscoveryPopup {
        id: discoveryPopup
    }
    
    AddDeviceWizard {
        id: addDeviceWizard
    }
}
