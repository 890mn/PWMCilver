#pragma once
#ifndef SERIALDEBUGBACKEND_H
#define SERIALDEBUGBACKEND_H

#include <QObject>
#include <QtSerialPort/QSerialPort>

class SerialDebugBackend : public QObject
{
    Q_OBJECT
public:
    explicit SerialDebugBackend(QObject *parent = nullptr);
    void start(const QString &portName, int baudRate = 9600);
    void stop();
    void sendMessage(const QString &msg);

signals:
    void messageReceived(const QString &msg);

private slots:
    void onReadyRead();

private:
    QSerialPort serial;
};

#endif // SERIALDEBUGBACKEND_H
