#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QVariantList>
#include <QVariantMap>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    ~DatabaseManager();

    Q_INVOKABLE bool initialize();
    Q_INVOKABLE bool addDevice(const QString &deviceId, const QString &deviceType, 
                               int channelCount, const QString &roomName, const QString &deviceName);
    Q_INVOKABLE bool removeDevice(const QString &deviceId);
    Q_INVOKABLE bool updateDeviceRoom(const QString &deviceId, const QString &newRoom);
    Q_INVOKABLE bool updateDeviceName(const QString &deviceId, const QString &newName);
    Q_INVOKABLE QVariantList getAllDevices();
    Q_INVOKABLE QVariantList getDevicesByRoom(const QString &roomName);
    Q_INVOKABLE QVariantList getAllRooms();
    Q_INVOKABLE bool deviceExists(const QString &deviceId);
    Q_INVOKABLE bool addChannelState(const QString &deviceId, int channelId, const QString &state);
    Q_INVOKABLE QString getChannelState(const QString &deviceId, int channelId);

private:
    QSqlDatabase m_db;
    bool createTables();
};

#endif // DATABASEMANAGER_H
