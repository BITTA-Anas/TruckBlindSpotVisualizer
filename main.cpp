#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "ArduinoController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    // 🔌 Arduino exposé à QML
    ArduinoController arduino;
    engine.rootContext()->setContextProperty("arduino", &arduino);

    engine.load(url);

    return app.exec();
}
