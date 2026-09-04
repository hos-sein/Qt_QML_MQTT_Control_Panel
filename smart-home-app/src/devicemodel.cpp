#include "devicemodel.h"
#include <QDebug>

DeviceModel::DeviceModel(DatabaseManager *dbManager, MqttClientController *mqttController, QObject *parent)
    : QAbstractListModel(parent)
    , m_dbManager(dbManager)
    , m_mqttController(mqttController)
{
}

int DeviceModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_devices.size();
}

QVariant DeviceModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= m_devices.size()) {
        return QVariant();
    }

    const DeviceInfo &device = m_devices.at(index.row());

    switch (role) {
        case DeviceIdRole:
            return device.deviceId;
        case DeviceTypeRole:
            return device.deviceType;
        case ChannelCountRole:
            return device.channelCount;
        case RoomNameRole:
            return device.roomName;
        case DeviceNameRole:
            return device.deviceName;
        case ChannelStatesRole:
            return device.channelStates;
        default:
            return QVariant();
    }
}

QHash<int, QByteArray> DeviceModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[DeviceIdRole] = "deviceId";
    roles[DeviceTypeRole] = "deviceType";
    roles[ChannelCountRole] = "channelCount";
    roles[RoomNameRole] = "roomName";
    roles[DeviceNameRole] = "deviceName";
    roles[ChannelStatesRole] = "channelStates";
    return roles;
}

void DeviceModel::loadDevices()
{
    beginResetModel();
    refreshDevices();
    endResetModel();
    emit devicesChanged();
}

void DeviceModel::loadDevicesByRoom(const QString &roomName)
{
    beginResetModel();
    m_devices.clear();
    
    QVariantList devicesData = m_dbManager->getDevicesByRoom(roomName);
    
    for (const QVariant &deviceVar : devicesData) {
        QVariantMap deviceMap = deviceVar.toMap();
        
        DeviceInfo info;
        info.deviceId = deviceMap["deviceId"].toString();
        info.deviceType = deviceMap["deviceType"].toString();
        info.channelCount = deviceMap["channelCount"].toInt();
        info.roomName = deviceMap["roomName"].toString();
        info.deviceName = deviceMap["deviceName"].toString();
        
        // Load channel states
        QVariantList states;
        for (int i = 1; i <= info.channelCount; ++i) {
            states.append(m_dbManager->getChannelState(info.deviceId, i));
        }
        info.channelStates = states;
        
        m_devices.append(info);
    }
    
    endResetModel();
    emit devicesChanged();
}

void DeviceModel::toggleChannel(const QString &deviceId, int channelId)
{
    QString currentState = getChannelState(deviceId, channelId);
    QString newState = (currentState == "ON") ? "OFF" : "ON";
    
    // Publish via MQTT
    m_mqttController->controlSwitch(deviceId, channelId, newState);
    
    // Update local state
    updateChannelState(deviceId, channelId, newState);
}

QString DeviceModel::getChannelState(const QString &deviceId, int channelId)
{
    for (const DeviceInfo &device : m_devices) {
        if (device.deviceId == deviceId) {
            if (channelId > 0 && channelId <= device.channelStates.size()) {
                return device.channelStates[channelId - 1].toString();
            }
        }
    }
    
    return m_dbManager->getChannelState(deviceId, channelId);
}

void DeviceModel::updateChannelState(const QString &deviceId, int channelId, const QString &state)
{
    for (int i = 0; i < m_devices.size(); ++i) {
        if (m_devices[i].deviceId == deviceId) {
            if (channelId > 0 && channelId <= m_devices[i].channelStates.size()) {
                m_devices[i].channelStates[channelId - 1] = state;
                emit dataChanged(index(i), index(i), {ChannelStatesRole});
                return;
            }
        }
    }
}

bool DeviceModel::removeDevice(const QString &deviceId)
{
    bool result = m_dbManager->removeDevice(deviceId);
    if (result) {
        loadDevices();
    }
    return result;
}

bool DeviceModel::updateDeviceRoom(const QString &deviceId, const QString &newRoom)
{
    bool result = m_dbManager->updateDeviceRoom(deviceId, newRoom);
    if (result) {
        loadDevices();
    }
    return result;
}

bool DeviceModel::updateDeviceName(const QString &deviceId, const QString &newName)
{
    bool result = m_dbManager->updateDeviceName(deviceId, newName);
    if (result) {
        loadDevices();
    }
    return result;
}

QVariantList DeviceModel::getAllRooms()
{
    return m_dbManager->getAllRooms();
}

void DeviceModel::addDevice(const QString &deviceId, const QString &deviceType,
                            int channelCount, const QString &roomName, const QString &deviceName)
{
    m_mqttController->addDeviceManually(deviceId, deviceType, channelCount, roomName, deviceName);
    loadDevices();
}

void DeviceModel::refreshDevices()
{
    m_devices.clear();
    
    QVariantList devicesData = m_dbManager->getAllDevices();
    
    for (const QVariant &deviceVar : devicesData) {
        QVariantMap deviceMap = deviceVar.toMap();
        
        DeviceInfo info;
        info.deviceId = deviceMap["deviceId"].toString();
        info.deviceType = deviceMap["deviceType"].toString();
        info.channelCount = deviceMap["channelCount"].toInt();
        info.roomName = deviceMap["roomName"].toString();
        info.deviceName = deviceMap["deviceName"].toString();
        
        // Load channel states
        QVariantList states;
        for (int i = 1; i <= info.channelCount; ++i) {
            states.append(m_dbManager->getChannelState(info.deviceId, i));
        }
        info.channelStates = states;
        
        m_devices.append(info);
    }
}
