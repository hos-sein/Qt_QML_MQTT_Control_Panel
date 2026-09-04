# Smart Home Management Application

A complete, ready-to-compile Smart Home Management Application built for Touch Panel displays using Qt 6 (C++) and QML.

## Features

### Core Functionality
- **Embedded MQTT Broker**: Integrates with Mosquitto broker (or runs in simulated mode if not available)
- **MQTT Client**: Uses Qt MQTT (`QMqttClient`) to connect internally to `127.0.0.1:1883`
- **SQLite Persistence**: Stores devices, channels, room assignments, and states across reboots

### MQTT Topic Hierarchy
- **Control Topic**: `switch/{device_id}/ch/{channel_id}/control` (Payloads: `ON` / `OFF`)
- **State Topic**: `switch/{device_id}/ch/{channel_id}/state` (Payloads: `ON` / `OFF`)
- **Auto-Discovery**: `home/discovery/{device_id}/config` (JSON payload)

### UI Features
- Modern Dark Theme optimized for wall-mounted touch panels
- Touch-friendly controls (minimum 48dp touch targets)
- Glassmorphism-inspired card design
- Smooth animations and transitions
- High-contrast elements for visibility

### Device Management
1. **Auto-Discovery**: Listen on `home/discovery/#` for new devices
2. **Manual Wizard**: Multi-step dialog for adding devices manually
3. **Dashboard View**: Grid of interactive device cards by room
4. **Device Management**: List view with edit/delete capabilities
5. **Settings View**: Broker status, connection info, topic patterns

## Prerequisites

### Required Packages
```bash
# Ubuntu/Debian
sudo apt-get install qt6-base-dev qt6-quick-dev libqt6mqtt6 libqt6sql6-sqlite cmake build-essential

# Optional: MQTT Broker
sudo apt-get install mosquitto
```

### Qt Modules Required
- Qt6::Core
- Qt6::Quick
- Qt6::Mqtt
- Qt6::Sql

## Building the Project

### Step 1: Create Build Directory
```bash
cd smart-home-app
mkdir build && cd build
```

### Step 2: Configure with CMake
```bash
cmake .. -DCMAKE_BUILD_TYPE=Release
```

### Step 3: Build
```bash
cmake --build . -j$(nproc)
```

### Step 4: Run
```bash
./SmartHomeApp
```

## Project Structure

```
smart-home-app/
├── CMakeLists.txt              # Build configuration
├── src/
│   ├── main.cpp                # Application entry point
│   ├── databasemanager.h/.cpp  # SQLite database operations
│   ├── mqttbrokermanager.h/.cpp # Embedded broker management
│   ├── mqttclientcontroller.h/.cpp # MQTT pub/sub handling
│   └── devicemodel.h/.cpp      # QML device model
├── qml/
│   ├── main.qml                # Main application window
│   ├── Theme.qml               # Design tokens (colors, fonts)
│   ├── SwitchCard.qml          # Interactive device card
│   ├── AddDeviceWizard.qml     # Manual device addition
│   ├── DiscoveryPopup.qml      # Auto-discovery notification
│   ├── DashboardView.qml       # Room/device grid view
│   ├── DeviceManagementView.qml # Device list management
│   └── SettingsView.qml        # Configuration view
└── resources/
    └── resources.qrc           # Qt resource file
```

## Usage Guide

### Adding Devices

#### Method 1: Auto-Discovery
When a device publishes its configuration to `home/discovery/{device_id}/config`, a popup notification appears allowing you to add the device and assign it to a room.

Example discovery payload:
```json
{
  "device_id": "03",
  "device_type": "Switch",
  "channel_count": 2,
  "room_name": "Living Room",
  "device_name": "Living Room Lights"
}
```

#### Method 2: Manual Addition
1. Click the "+" button in the Dashboard
2. Select device type (Switch, Light, Outlet, Fan)
3. Configure device ID and channel count
4. Assign to a room
5. Click "Add Device"

### Controlling Devices
- Tap any device card to toggle its state
- Channel indicators show individual channel states
- State changes are published immediately via MQTT
- All changes persist to SQLite database

### Room Filtering
- Use the room selector dropdown in the Dashboard
- View devices by specific room or all rooms

## MQTT Integration

### Publishing Control Commands
```cpp
// Toggle a switch ON
mqttController->controlSwitch("03", 1, "ON");

// Toggle a switch OFF
mqttController->controlSwitch("03", 1, "OFF");
```

### Subscribing to State Updates
The application automatically subscribes to:
- `home/discovery/#` - For auto-discovery
- `switch/+/ch/+/state` - For state updates

### Simulating External Devices
```bash
# Publish a discovery message
mosquitto_pub -t "home/discovery/04/config" \
  -m '{"device_id":"04","device_type":"Light","channel_count":1,"room_name":"Kitchen","device_name":"Kitchen Light"}'

# Control a device
mosquitto_pub -t "switch/03/ch/1/state" -m "ON"
```

## Customization

### Theme Colors
Edit `qml/Theme.qml` to customize:
- Color palette
- Typography
- Spacing values
- Animation durations
- Card dimensions

### Adding New Views
1. Create new QML file in `qml/`
2. Import in `main.qml`
3. Add navigation button in sidebar

## Troubleshooting

### MQTT Broker Not Starting
- Ensure Mosquitto is installed: `sudo apt-get install mosquitto`
- Check if port 1883 is available: `sudo netstat -tlnp | grep 1883`
- The app runs in simulated mode if broker is unavailable

### Database Issues
- Database is stored in: `~/.local/share/SmartHomeApp/smarthome.db`
- Delete to reset: `rm ~/.local/share/SmartHomeApp/smarthome.db`

### Qt MQTT Module Missing
```bash
# Install Qt MQTT module
git clone https://code.qt.io/qt/qtmqtt.git
cd qtmqtt
qmake6
make
sudo make install
```

## License

This project is provided as-is for educational and commercial use.

## Support

For issues or feature requests, please check the documentation or submit a bug report.
