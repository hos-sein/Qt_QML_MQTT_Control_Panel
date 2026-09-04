#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include "databasemanager.h"
#include "mqttbrokermanager.h"
#include "mqttclientcontroller.h"
#include "devicemodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("SmartHomeApp");
    app.setApplicationName("SmartHomePanel");

    // Initialize Database Manager
    DatabaseManager dbManager;
    if (!dbManager.initialize()) {
        qCritical() << "Failed to initialize database";
        return -1;
    }

    // Initialize MQTT Broker Manager
    MqttBrokerManager brokerManager;
    if (!brokerManager.startBroker()) {
        qWarning() << "Failed to start embedded MQTT broker";
    }

    // Initialize MQTT Client Controller
    MqttClientController mqttController(&dbManager);
    mqttController.connectToBroker();

    // Initialize Device Model
    DeviceModel deviceModel(&dbManager, &mqttController);
    deviceModel.loadDevices();

    // Setup QML Engine
    QQmlApplicationEngine engine;

    // Register types
    qmlRegisterType<MqttBrokerManager>("SmartHomeApp", 1, 0, "MqttBrokerManager");
    
    // Expose objects to QML
    engine.rootContext()->setContextProperty("dbManager", &dbManager);
    engine.rootContext()->setContextProperty("mqttController", &mqttController);
    engine.rootContext()->setContextProperty("deviceModel", &deviceModel);
    engine.rootContext()->setContextProperty("brokerManager", &brokerManager);

    const QUrl url(QStringLiteral("qrc:/SmartHomeApp/qml/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    
    engine.load(url);

    return app.exec();
}
