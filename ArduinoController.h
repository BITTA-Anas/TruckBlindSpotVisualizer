#pragma once

#include <QObject>
#include <QSerialPort>

class ArduinoController : public QObject
{
    Q_OBJECT
public:
    explicit ArduinoController(QObject *parent = nullptr);

signals:
    // Boutons Arduino : 1, 2, 3
    void buttonReceived(int value);

    // Alertes ADAS
    void dangerLeft();
    void dangerRight();
    void clearLeft();
    void clearRight();

private slots:
    void readSerial();

private:
    QSerialPort serial;
};
