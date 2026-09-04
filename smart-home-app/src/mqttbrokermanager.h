#ifndef MQTTBROKERMANAGER_H
#define MQTTBROKERMANAGER_H

#include <QObject>
#include <QThread>
#include <QProcess>
#include <QFile>
#include <QDir>

class MqttBrokerManager : public QObject
{
    Q_OBJECT
public:
    explicit MqttBrokerManager(QObject *parent = nullptr);
    ~MqttBrokerManager();

    Q_INVOKABLE bool startBroker();
    Q_INVOKABLE void stopBroker();
    Q_INVOKABLE bool isRunning() const;

signals:
    void brokerStarted();
    void brokerStopped();
    void brokerError(const QString &error);

private:
    QProcess *m_brokerProcess;
    bool m_isRunning;
    QString m_configPath;
    
    bool createBrokerConfig();
};

#endif // MQTTBROKERMANAGER_H
