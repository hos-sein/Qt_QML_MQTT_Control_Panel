#ifndef MQTTCLIENTCONTROLLER_H
#define MQTTCLIENTCONTROLLER_H

#include <QObject>
#include <QMqttClient>
#include <QMqttSubscription>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>
#include "databasemanager.h"

class MqttClientController : public QObject
{
    Q_OBJECT
public:
    explicit MqttClientController(DatabaseManager *dbManager, QObject *parent = nullptr);
    ~MqttClientController();

    Q_INVOKABLE bool connectToBroker();
    Q_INVOKABLE void disconnectFromBroker();
    Q_INVOKABLE bool publishMessage(const QString &topic, const QString &payload);
    Q_INVOKABLE bool subscribeToTopic(const QString &topic);
    Q_INVOKABLE void controlSwitch(const QString &deviceId, int channelId, const QString &state);
    Q_INVOKABLE void addDeviceManually(const QString &deviceId, const QString &deviceType,
                                        int channelCount, const QString &roomName, const QString &deviceName);
    
    bool isConnected() const { return m_client && m_client->state() == QMqttClient::Connected; }
    QString brokerHost() const { return m_brokerHost; }
    int brokerPort() const { return m_brokerPort; }

signals:
    void connectionStateChanged(bool connected);
    void deviceDiscovered(const QVariantMap &deviceConfig);
    void stateReceived(const QString &deviceId, int channelId, const QString &state);
    void messageReceived(const QString &topic, const QString &payload);
    void errorOccurred(const QString &error);

private slots:
    void onConnected();
    void onDisconnected();
    void onError(QMqttClient::ClientError error);
    void onMessageReceived(const QByteArray &message, const QMqttTopicName &topic);

private:
    QMqttClient *m_client;
    DatabaseManager *m_dbManager;
    QString m_brokerHost;
    int m_brokerPort;
    QList<QMqttSubscription*> m_subscriptions;
    
    void setupSubscriptions();
    void parseDiscoveryMessage(const QJsonObject &config);
};

#endif // MQTTCLIENTCONTROLLER_H
