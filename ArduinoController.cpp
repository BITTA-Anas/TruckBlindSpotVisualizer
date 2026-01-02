#include "ArduinoController.h"
#include <QDebug>

ArduinoController::ArduinoController(QObject *parent)
    : QObject(parent)
{
    serial.setPortName("COM3");   // ✅ correct
    serial.setBaudRate(QSerialPort::Baud115200);

    if (!serial.open(QIODevice::ReadOnly)) {
        qWarning() << "Impossible d'ouvrir le port série";
        return;
    }

    connect(&serial, &QSerialPort::readyRead,
            this, &ArduinoController::readSerial);
}

void ArduinoController::readSerial()
{
    while (serial.canReadLine()) {
        QString line = QString::fromUtf8(serial.readLine()).trimmed();
        qDebug() << "Arduino:" << line;

        // ---------- BOUTONS ----------
        bool ok = false;
        int value = line.toInt(&ok);
        if (ok) {
            emit buttonReceived(value);
            continue;
        }

        // ---------- ALERTES ----------
        if (line == "DANGER LEFT")
            emit dangerLeft();
        else if (line == "DANGER RIGHT")
            emit dangerRight();
        else if (line == "CLEAR LEFT")
            emit clearLeft();
        else if (line == "CLEAR RIGHT")
            emit clearRight();
    }
}
