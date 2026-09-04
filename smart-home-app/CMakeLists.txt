cmake_minimum_required(VERSION 3.16)
project(SmartHomeApp VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Quick Mqtt Sql)

qt_standard_project_setup()

# Source files
set(SOURCES
    src/main.cpp
    src/mqttbrokermanager.cpp
    src/mqttclientcontroller.cpp
    src/devicemodel.cpp
    src/databasemanager.cpp
)

set(HEADERS
    src/mqttbrokermanager.h
    src/mqttclientcontroller.h
    src/devicemodel.h
    src/databasemanager.h
)

set(QML_SOURCES
    qml/main.qml
    qml/Theme.qml
    qml/SwitchCard.qml
    qml/AddDeviceWizard.qml
    qml/DiscoveryPopup.qml
    qml/DashboardView.qml
    qml/DeviceManagementView.qml
    qml/SettingsView.qml
)

# Create executable
qt_add_executable(SmartHomeApp
    ${SOURCES}
    ${HEADERS}
)

# Link libraries
target_link_libraries(SmartHomeApp PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Mqtt
    Qt6::Sql
)

# QML module
qt_add_qml_module(SmartHomeApp
    URI SmartHomeApp
    VERSION 1.0
    QML_FILES ${QML_SOURCES}
    RESOURCES resources/resources.qrc
)

# Copy database file to build directory
file(COPY ${CMAKE_SOURCE_DIR}/resources/smarthome.db DESTINATION ${CMAKE_BINARY_DIR} ERROR_QUIET)

target_compile_definitions(SmartHomeApp PRIVATE
    $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
)
