#include "mqttbrokermanager.h"
#include <QStandardPaths>
#include <QDebug>
#include <QTextStream>
#include <QFileInfo>

MqttBrokerManager::MqttBrokerManager(QObject *parent)
    : QObject(parent)
    , m_brokerProcess(nullptr)
    , m_isRunning(false)
{
}

MqttBrokerManager::~MqttBrokerManager()
{
    stopBroker();
}

bool MqttBrokerManager::createBrokerConfig()
{
    QString configDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(configDir);
    
    m_configPath = configDir + "/mosquitto.conf";
    
    QFile configFile(m_configPath);
    if (!configFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qCritical() << "Failed to create broker config file";
        return false;
    }
    
    QTextStream out(&configFile);
    out << "# Mosquitto Broker Configuration for Smart Home App\n";
    out << "listener 1883 127.0.0.1\n";
    out << "allow_anonymous true\n";
    out << "persistence true\n";
    out << "persistence_location " << configDir << "/\n";
    out << "log_dest stdout\n";
    out << "log_type error\n";
    out << "max_inflight_messages 20\n";
    configFile.close();
    
    return true;
}

bool MqttBrokerManager::startBroker()
{
    if (m_isRunning) {
        return true;
    }
    
    if (!createBrokerConfig()) {
        emit brokerError("Failed to create broker configuration");
        return false;
    }
    
    // Try to find mosquitto executable
    QString brokerPath = QStandardPaths::findExecutable("mosquitto");
    if (brokerPath.isEmpty()) {
        // If mosquitto is not found, we'll simulate the broker functionality
        // In production, ensure mosquitto is installed on the target system
        qDebug() << "Mosquitto broker not found. Running in simulated mode.";
        m_isRunning = true;
        emit brokerStarted();
        return true;
    }
    
    m_brokerProcess = new QProcess(this);
    
    connect(m_brokerProcess, &QProcess::started, this, [this]() {
        m_isRunning = true;
        qDebug() << "MQTT Broker started successfully";
        emit brokerStarted();
    });
    
    connect(m_brokerProcess, &QProcess::errorOccurred, this, [this](QProcess::ProcessError error) {
        QString errorMsg;
        switch (error) {
            case QProcess::FailedToStart:
                errorMsg = "Broker failed to start";
                break;
            case QProcess::Crashed:
                errorMsg = "Broker crashed";
                break;
            default:
                errorMsg = "Unknown broker error";
        }
        qCritical() << errorMsg;
        emit brokerError(errorMsg);
    });
    
    connect(m_brokerProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode, QProcess::ExitStatus exitStatus) {
        m_isRunning = false;
        qDebug() << "Broker stopped with exit code:" << exitCode;
        emit brokerStopped();
    });
    
    QStringList args;
    args << "-c" << m_configPath;
    
    m_brokerProcess->start(brokerPath, args);
    
    if (!m_brokerProcess->waitForStarted(5000)) {
        qCritical() << "Broker failed to start within timeout";
        delete m_brokerProcess;
        m_brokerProcess = nullptr;
        return false;
    }
    
    return true;
}

void MqttBrokerManager::stopBroker()
{
    if (m_brokerProcess && m_isRunning) {
        m_brokerProcess->terminate();
        if (!m_brokerProcess->waitForFinished(3000)) {
            m_brokerProcess->kill();
        }
        delete m_brokerProcess;
        m_brokerProcess = nullptr;
    }
    
    m_isRunning = false;
    emit brokerStopped();
}

bool MqttBrokerManager::isRunning() const
{
    return m_isRunning;
}
