import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    
    modal: true
    padding: Theme.spacingL
    width: 400
    background: Rectangle {
        color: Theme.backgroundSecondary
        radius: Theme.cardCornerRadius
        border.color: Theme.borderColor
    }
    
    title: Text {
        text: "Add New Device"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeXLarge
        font.bold: true
        color: Theme.textPrimary
    }
    
    contentItem: ColumnLayout {
        spacing: Theme.spacingM
        
        // Step indicator
        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingS
            
            Repeater {
                model: 3
                
                RowLayout {
                    spacing: Theme.spacingXS
                    
                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: index < wizard.currentIndex ? Theme.accentPrimary : 
                               index === wizard.currentIndex ? Theme.accentPrimary : Theme.backgroundCard
                        border.color: Theme.accentPrimary
                        border.width: 2
                        
                        Text {
                            anchors.centerIn: parent
                            text: (index + 1)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: index <= wizard.currentIndex ? Theme.textPrimary : Theme.textSecondary
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 2
                        color: index < wizard.currentIndex ? Theme.accentPrimary : Theme.backgroundCard
                        visible: index < 2
                    }
                }
            }
        }
        
        Text {
            text: wizard.currentStepTitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textSecondary
        }
        
        // Wizard content
        StackLayout {
            id: wizard
            Layout.fillWidth: true
            currentIndex: currentStep
            
            property int currentStep: 0
            property string currentStepTitle: "Device Type"
            
            function nextStep() {
                if (currentStep < count - 1) {
                    currentStep++
                    updateStepTitle()
                }
            }
            
            function prevStep() {
                if (currentStep > 0) {
                    currentStep--
                    updateStepTitle()
                }
            }
            
            function updateStepTitle() {
                switch(currentStep) {
                    case 0: currentStepTitle = "Select Device Type"; break;
                    case 1: currentStepTitle = "Configure Device"; break;
                    case 2: currentStepTitle = "Assign to Room"; break;
                }
            }
            
            // Step 1: Device Type
            Item {
                id: step1
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacingM
                    
                    Text {
                        Layout.fillWidth: true
                        text: "Choose the type of device you want to add:"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }
                    
                    GridView {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        cellWidth: 100
                        cellHeight: 80
                        model: ["Switch", "Light", "Outlet", "Fan"]
                        
                        delegate: Rectangle {
                            width: 100
                            height: 80
                            radius: Theme.cardCornerRadius
                            color: deviceTypeSelector.selected === modelData ? Theme.accentPrimary : Theme.backgroundCard
                            border.color: Theme.borderColor
                            
                            Behavior on color {
                                ColorAnimation { duration: Theme.animationFast }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                font.bold: true
                                color: Theme.textPrimary
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: deviceTypeSelector.selected = modelData
                            }
                        }
                    }
                }
            }
            
            // Step 2: Configure Device
            Item {
                id: step2
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacingM
                    
                    // Device ID
                    Text {
                        text: "Device ID:"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }
                    
                    TextField {
                        id: deviceIdField
                        Layout.fillWidth: true
                        placeholderText: "e.g., 03"
                        text: "0" + Math.floor(Math.random() * 9 + 1)
                        
                        background: Rectangle {
                            color: Theme.backgroundCard
                            radius: Theme.cardCornerRadius
                            border.color: deviceIdField.activeFocus ? Theme.accentPrimary : Theme.borderColor
                        }
                        
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        leftPadding: Theme.spacingM
                    }
                    
                    // Number of Channels
                    Text {
                        text: "Number of Channels:"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }
                    
                    SpinBox {
                        id: channelCountBox
                        Layout.fillWidth: true
                        from: 1
                        to: 8
                        value: 1
                        
                        background: Rectangle {
                            color: Theme.backgroundCard
                            radius: Theme.cardCornerRadius
                            border.color: Theme.borderColor
                        }
                        
                        contentItem: TextInput {
                            text: channelCountBox.value
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.textPrimary
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            readOnly: !channelCountBox.editable
                            validator: channelCountBox.validator
                        }
                    }
                    
                    // Device Name
                    Text {
                        text: "Device Name (optional):"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }
                    
                    TextField {
                        id: deviceNameField
                        Layout.fillWidth: true
                        placeholderText: "e.g., Living Room Lights"
                        
                        background: Rectangle {
                            color: Theme.backgroundCard
                            radius: Theme.cardCornerRadius
                            border.color: deviceNameField.activeFocus ? Theme.accentPrimary : Theme.borderColor
                        }
                        
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        leftPadding: Theme.spacingM
                    }
                }
            }
            
            // Step 3: Assign to Room
            Item {
                id: step3
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: Theme.spacingM
                    
                    Text {
                        Layout.fillWidth: true
                        text: "Select or create a room for this device:"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        color: Theme.textSecondary
                    }
                    
                    ComboBox {
                        id: roomSelector
                        Layout.fillWidth: true
                        model: ["Living Room", "Bedroom", "Kitchen", "Bathroom", "Garage", "Office"]
                        
                        background: Rectangle {
                            color: Theme.backgroundCard
                            radius: Theme.cardCornerRadius
                            border.color: Theme.borderColor
                        }
                        
                        contentItem: Text {
                            leftPadding: Theme.spacingM
                            text: roomSelector.displayText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            color: Theme.textPrimary
                            verticalAlignment: Text.AlignVCenter
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
                    }
                    
                    // Summary
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: summaryColumn.implicitHeight + Theme.spacingM * 2
                        color: Theme.backgroundCard
                        radius: Theme.cardCornerRadius
                        
                        ColumnLayout {
                            id: summaryColumn
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingXS
                            
                            Text {
                                Layout.fillWidth: true
                                text: "<b>Summary:</b>"
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                color: Theme.accentPrimary
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: "Type: " + deviceTypeSelector.selected
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textSecondary
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: "ID: " + deviceIdField.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textSecondary
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: "Channels: " + channelCountBox.value
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textSecondary
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: "Room: " + roomSelector.currentText
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textSecondary
                            }
                        }
                    }
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
            text: wizard.currentStep > 0 ? "Back" : "Cancel"
            visible: true
            
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
                if (wizard.currentStep > 0) {
                    wizard.prevStep()
                } else {
                    root.close()
                }
            }
        }
        
        Button {
            Layout.fillWidth: true
            text: wizard.currentStep < 2 ? "Next" : "Add Device"
            
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
                if (wizard.currentStep < 2) {
                    wizard.nextStep()
                } else {
                    // Add the device
                    mqttController.addDeviceManually(
                        deviceIdField.text,
                        deviceTypeSelector.selected,
                        channelCountBox.value,
                        roomSelector.currentText,
                        deviceNameField.text || ("Device " + deviceIdField.text)
                    )
                    deviceModel.loadDevices()
                    root.close()
                    
                    // Reset form
                    wizard.currentStep = 0
                    wizard.updateStepTitle()
                }
            }
        }
    }
}

// Helper item for device type selection
Item {
    id: deviceTypeSelector
    property string selected: "Switch"
}
