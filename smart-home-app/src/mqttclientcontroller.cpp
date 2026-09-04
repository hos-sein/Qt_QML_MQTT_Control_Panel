#include "mqttclientcontroller.h"
#include <QDebug>
#include <QRegularExpression>

MqttClientController::MqttClientController(DatabaseManager *dbManager, QObject *parent)
    : QObject(parent)
    , m_client(new QMqttClient(this))
    , m_dbManager(dbManager)
    , m_brokerHost("127.0.0.1")
    , m_brokerPort(1883)
{
    connect(m_client, &QMqttClient::connected, this, &MqttClientController::onConnected);
    connect(m_client, &QMqttClient::disconnected, this, &MqttClientController::onDisconnected);
    connect(m_client, &QMqttClient::errorOccurred, this, &MqttClientController::onError);
    connect(m_client, &QMqttClient::messageReceived, this, &MqttClientController::onMessageReceived);
}

MqttClientController::~MqttClientController()
{
    disconnectFromBroker();
}

bool MqttClientController::connectToBroker()
{
    m_client->setHostname(m_brokerHost);
    m_client->setPort(m_brokerPort);
    
    qDebug() << "Connecting to MQTT broker at" << m_brokerHost << ":" << m_brokerPort;
    m_client->connectToHost();
    
    return true;
}

void MqttClientController::disconnectFromBroker()
{
    if (m_client) {
        for (QMqttSubscription *sub : m_subscriptions) {
            if (sub) {
                sub->unsubscribe();
            }
        }
        m_subscriptions.clear();
        
        m_client->disconnectFromHost();
    }
}

bool MqttClientController::publishMessage(const QString &topic, const QString &payload)
{
    if (!isConnected()) {
        qWarning() << "Cannot publish: not connected to broker";
        return false;
    }
    
    qint64 result = m_client->publish(topic, payload.toUtf8());
    if (result == -1) {
        qWarning() << "Failed to publish message to topic:" << topic;
        return false;
    }
    
    qDebug() << "Published to" << topic << ":" << payload;
    return true;
}

bool MqttClientController::subscribeToTopic(const QString &topic)
{
    if (!isConnected()) {
        qWarning() << "Cannot subscribe: not connected to broker";
        return false;
    }
    
    QMqttSubscription *subscription = m_client->subscribe(topic);
    if (subscription) {
        m_subscriptions.append(subscription);
        qDebug() << "Subscribed to topic:" << topic;
        return true;
    }
    
    qWarning() << "Failed to subscribe to topic:" << topic;
    return false;
}

void MqttClientController::controlSwitch(const QString &deviceId, int channelId, const QString &state)
{
    QString topic = QString("switch/%1/ch/%2/control").arg(deviceId).arg(channelId);
    publishMessage(topic, state);
    
    // Also update local database
    m_dbManager->addChannelState(deviceId, channelId, state);
}

void MqttClientController::addDeviceManually(const QString &deviceId, const QString &deviceType,
                                              int channelCount, const QString &roomName, const QString &deviceName)
{
    if (m_dbManager->addDevice(deviceId, deviceType, channelCount, roomName, deviceName)) {
        qDebug() << "Device added manually:" << deviceId;
        
        // Publish discovery config for consistency
        QJsonObject config;
        config["device_id"] = deviceId;
        config["device_type"] = deviceType;
        config["channel_count"] = channelCount;
        config["room_name"] = roomName;
        config["device_name"] = deviceName;
        
        QJsonArray channels;
        for (int i = 1; i <= channelCount; ++i) {
            QJsonObject ch;
            ch["channel_id"] = i;
            ch["name"] = QString("Channel %1").arg(i);
            channels.append(ch);
        }
        config["channels"] = channels;
        
        QString discoveryTopic = QString("home/discovery/%1/config").arg(deviceId);
        publishMessage(discoveryTopic, QJsonDocument(config).toJson(QJsonDocument::Compact));
    } else {
        qWarning() << "Failed to add device manually:" << deviceId;
    }
}

void MqttClientController::onConnected()
{
    qDebug() << "Connected to MQTT broker";
    emit connectionStateChanged(true);
    setupSubscriptions();
}

void MqttClientController::onDisconnected()
{
    qDebug() << "Disconnected from MQTT broker";
    emit connectionStateChanged(false);
}

void MqttClientController::onError(QMqttClient::ClientError error)
{
    QString errorMsg;
    switch (error) {
        case QMqttClient::SocketError:
            errorMsg = "Socket error: " + m_client->errorString();
            break;
        case QMqttClient::ProtocolViolation:
            errorMsg = "Protocol violation";
            break;
        case QMqttClient::ClientInvalid:
            errorMsg = "Client invalid";
            break;
        default:
            errorMsg = "Unknown error: " + m_client->errorString();
    }
    
    qCritical() << "MQTT Client Error:" << errorMsg;
    emit errorOccurred(errorMsg);
}

void MqttClientController::onMessageReceived(const QByteArray &message, const QMqttTopicName &topic)
{
    QString topicName = topic.name();
    QString payload = QString::fromUtf8(message);
    
    qDebug() << "Received on" << topicName << ":" << payload;
    emit messageReceived(topicName, payload);
    
    // Handle auto-discovery messages
    if (topicName.startsWith("home/discovery/")) {
        QJsonParseError parseError;
        QJsonDocument doc = QJsonDocument::fromJson(message, &parseError);
        
        if (parseError.error == QJsonParseError::NoError && doc.isObject()) {
            parseDiscoveryMessage(doc.object());
        }
    }
    
    // Handle state messages
    QRegularExpression stateRegex(R"(switch/([^/]+)/ch/(\d+)/state)");
    QRegularExpressionMatch match = stateRegex.match(topicName);
    
    if (match.hasMatch()) {
        QString deviceId = match.captured(1);
        int channelId = match.captured(2).toInt();
        QString state = payload.trimmed().toUpper();
        
        // Update database
        m_dbManager->addChannelState(deviceId, channelId, state);
        
        emit stateReceived(deviceId, channelId, state);
    }
}

void MqttClientController::setupSubscriptions()
{
    // Subscribe to auto-discovery topics
    subscribeToTopic("home/discovery/#");
    
    // Subscribe to all state topics
    subscribeToTopic("switch/+/ch/+/state");
}

void MqttClientController::parseDiscoveryMessage(const QJsonObject &config)
{
    if (!config.contains("device_id") || !config.contains("device_type") || 
        !config.contains("channel_count") || !config.contains("room_name")) {
        qWarning() << "Invalid discovery message format";
        return;
    }
    
    QVariantMap deviceConfig;
    deviceConfig["deviceId"] = config["device_id"].toString();
    deviceConfig["deviceType"] = config["device_type"].toString();
    deviceConfig["channelCount"] = config["channel_count"].toInt();
    deviceConfig["roomName"] = config["room_name"].toString();
    deviceConfig["deviceName"] = config.value("device_name").toString();
    
    // Check if device already exists in database
    if (m_dbManager->deviceExists(deviceConfig["deviceId"].toString())) {
        qDebug() << "Device already exists, ignoring discovery:" << deviceConfig["deviceId"].toString();
        return;
    }
    
    qDebug() << "New device discovered:" << deviceConfig["deviceId"].toString();
    emit deviceDiscovered(deviceConfig);
}
