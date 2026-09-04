#ifndef DEVICEMODEL_H
#define DEVICEMODEL_H

#include <QAbstractListModel>
#include <QQmlEngine>
#include "databasemanager.h"
#include "mqttclientcontroller.h"

struct DeviceInfo {
    QString deviceId;
    QString deviceType;
    int channelCount;
    QString roomName;
    QString deviceName;
    QVariantList channelStates;
};

class DeviceModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    
public:
    enum DeviceRoles {
        DeviceIdRole = Qt::UserRole + 1,
        DeviceTypeRole,
        ChannelCountRole,
        RoomNameRole,
        DeviceNameRole,
        ChannelStatesRole
    };

    explicit DeviceModel(DatabaseManager *dbManager, MqttClientController *mqttController, QObject *parent = nullptr);
    
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void loadDevices();
    Q_INVOKABLE void loadDevicesByRoom(const QString &roomName);
    Q_INVOKABLE void toggleChannel(const QString &deviceId, int channelId);
    Q_INVOKABLE QString getChannelState(const QString &deviceId, int channelId);
    Q_INVOKABLE void updateChannelState(const QString &deviceId, int channelId, const QString &state);
    Q_INVOKABLE bool removeDevice(const QString &deviceId);
    Q_INVOKABLE bool updateDeviceRoom(const QString &deviceId, const QString &newRoom);
    Q_INVOKABLE bool updateDeviceName(const QString &deviceId, const QString &newName);
    Q_INVOKABLE QVariantList getAllRooms();
    Q_INVOKABLE void addDevice(const QString &deviceId, const QString &deviceType,
                               int channelCount, const QString &roomName, const QString &deviceName);

signals:
    void devicesChanged();

private:
    DatabaseManager *m_dbManager;
    MqttClientController *m_mqttController;
    QList<DeviceInfo> m_devices;
    
    void refreshDevices();
};

#endif // DEVICEMODEL_H
