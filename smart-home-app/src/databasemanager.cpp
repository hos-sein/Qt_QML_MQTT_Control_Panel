#include "databasemanager.h"
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
}

DatabaseManager::~DatabaseManager()
{
    if (m_db.isOpen()) {
        m_db.close();
    }
}

bool DatabaseManager::initialize()
{
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dbPath);
    dbPath += "/smarthome.db";

    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dbPath);

    if (!m_db.open()) {
        qCritical() << "Failed to open database:" << m_db.lastError().text();
        return false;
    }

    return createTables();
}

bool DatabaseManager::createTables()
{
    QSqlQuery query;

    QString devicesTable = R"(
        CREATE TABLE IF NOT EXISTS devices (
            device_id TEXT PRIMARY KEY,
            device_type TEXT NOT NULL,
            channel_count INTEGER NOT NULL,
            room_name TEXT NOT NULL,
            device_name TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    QString channelsTable = R"(
        CREATE TABLE IF NOT EXISTS channels (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT NOT NULL,
            channel_id INTEGER NOT NULL,
            state TEXT DEFAULT 'OFF',
            FOREIGN KEY(device_id) REFERENCES devices(device_id),
            UNIQUE(device_id, channel_id)
        )
    )";

    QString roomsTable = R"(
        CREATE TABLE IF NOT EXISTS rooms (
            room_name TEXT PRIMARY KEY,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    )";

    if (!query.exec(devicesTable)) {
        qCritical() << "Failed to create devices table:" << query.lastError().text();
        return false;
    }

    if (!query.exec(channelsTable)) {
        qCritical() << "Failed to create channels table:" << query.lastError().text();
        return false;
    }

    if (!query.exec(roomsTable)) {
        qCritical() << "Failed to create rooms table:" << query.lastError().text();
        return false;
    }

    return true;
}

bool DatabaseManager::addDevice(const QString &deviceId, const QString &deviceType,
                                 int channelCount, const QString &roomName, const QString &deviceName)
{
    if (deviceExists(deviceId)) {
        return false;
    }

    QSqlQuery query;
    query.prepare("INSERT INTO devices (device_id, device_type, channel_count, room_name, device_name) "
                  "VALUES (:device_id, :device_type, :channel_count, :room_name, :device_name)");
    query.bindValue(":device_id", deviceId);
    query.bindValue(":device_type", deviceType);
    query.bindValue(":channel_count", channelCount);
    query.bindValue(":room_name", roomName);
    query.bindValue(":device_name", deviceName);

    if (!query.exec()) {
        qCritical() << "Failed to add device:" << query.lastError().text();
        return false;
    }

    // Add room if not exists
    query.prepare("INSERT OR IGNORE INTO rooms (room_name) VALUES (:room_name)");
    query.bindValue(":room_name", roomName);
    query.exec();

    // Initialize channel states
    for (int i = 1; i <= channelCount; ++i) {
        addChannelState(deviceId, i, "OFF");
    }

    return true;
}

bool DatabaseManager::removeDevice(const QString &deviceId)
{
    QSqlQuery query;
    query.prepare("DELETE FROM devices WHERE device_id = :device_id");
    query.bindValue(":device_id", deviceId);

    if (!query.exec()) {
        qCritical() << "Failed to remove device:" << query.lastError().text();
        return false;
    }

    // Remove associated channels
    query.prepare("DELETE FROM channels WHERE device_id = :device_id");
    query.bindValue(":device_id", deviceId);
    query.exec();

    return true;
}

bool DatabaseManager::updateDeviceRoom(const QString &deviceId, const QString &newRoom)
{
    QSqlQuery query;
    query.prepare("UPDATE devices SET room_name = :room_name WHERE device_id = :device_id");
    query.bindValue(":room_name", newRoom);
    query.bindValue(":device_id", deviceId);

    if (!query.exec()) {
        qCritical() << "Failed to update device room:" << query.lastError().text();
        return false;
    }

    // Add room if not exists
    query.prepare("INSERT OR IGNORE INTO rooms (room_name) VALUES (:room_name)");
    query.bindValue(":room_name", newRoom);
    query.exec();

    return true;
}

bool DatabaseManager::updateDeviceName(const QString &deviceId, const QString &newName)
{
    QSqlQuery query;
    query.prepare("UPDATE devices SET device_name = :device_name WHERE device_id = :device_id");
    query.bindValue(":device_name", newName);
    query.bindValue(":device_id", deviceId);

    if (!query.exec()) {
        qCritical() << "Failed to update device name:" << query.lastError().text();
        return false;
    }

    return true;
}

QVariantList DatabaseManager::getAllDevices()
{
    QVariantList devices;
    QSqlQuery query("SELECT device_id, device_type, channel_count, room_name, device_name FROM devices");

    while (query.next()) {
        QVariantMap device;
        device["deviceId"] = query.value(0).toString();
        device["deviceType"] = query.value(1).toString();
        device["channelCount"] = query.value(2).toInt();
        device["roomName"] = query.value(3).toString();
        device["deviceName"] = query.value(4).toString();
        devices.append(device);
    }

    return devices;
}

QVariantList DatabaseManager::getDevicesByRoom(const QString &roomName)
{
    QVariantList devices;
    QSqlQuery query;
    query.prepare("SELECT device_id, device_type, channel_count, room_name, device_name FROM devices WHERE room_name = :room_name");
    query.bindValue(":room_name", roomName);
    query.exec();

    while (query.next()) {
        QVariantMap device;
        device["deviceId"] = query.value(0).toString();
        device["deviceType"] = query.value(1).toString();
        device["channelCount"] = query.value(2).toInt();
        device["roomName"] = query.value(3).toString();
        device["deviceName"] = query.value(4).toString();
        devices.append(device);
    }

    return devices;
}

QVariantList DatabaseManager::getAllRooms()
{
    QVariantList rooms;
    QSqlQuery query("SELECT room_name FROM rooms");

    while (query.next()) {
        rooms.append(query.value(0).toString());
    }

    return rooms;
}

bool DatabaseManager::deviceExists(const QString &deviceId)
{
    QSqlQuery query;
    query.prepare("SELECT COUNT(*) FROM devices WHERE device_id = :device_id");
    query.bindValue(":device_id", deviceId);
    query.exec();

    if (query.next()) {
        return query.value(0).toInt() > 0;
    }

    return false;
}

bool DatabaseManager::addChannelState(const QString &deviceId, int channelId, const QString &state)
{
    QSqlQuery query;
    query.prepare("INSERT OR REPLACE INTO channels (device_id, channel_id, state) "
                  "VALUES (:device_id, :channel_id, :state)");
    query.bindValue(":device_id", deviceId);
    query.bindValue(":channel_id", channelId);
    query.bindValue(":state", state);

    if (!query.exec()) {
        qCritical() << "Failed to add channel state:" << query.lastError().text();
        return false;
    }

    return true;
}

QString DatabaseManager::getChannelState(const QString &deviceId, int channelId)
{
    QSqlQuery query;
    query.prepare("SELECT state FROM channels WHERE device_id = :device_id AND channel_id = :channel_id");
    query.bindValue(":device_id", deviceId);
    query.bindValue(":channel_id", channelId);
    query.exec();

    if (query.next()) {
        return query.value(0).toString();
    }

    return "OFF";
}
