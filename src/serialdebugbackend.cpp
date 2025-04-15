#include "serialdebugbackend.h"
#include "blemanager.h"
#include <QDebug>

SerialDebugBackend::SerialDebugBackend(QObject *parent) : QObject(parent)
{
    connect(&serial, &QSerialPort::readyRead, this, &SerialDebugBackend::onReadyRead);
}

void SerialDebugBackend::start(const QString &portName, int baudRate)
{
    if (serial.isOpen()) serial.close();

    serial.setPortName(portName);
    serial.setBaudRate(baudRate);
    if (!serial.open(QIODevice::ReadWrite)) {
        qWarning() << "串口打开失败:" << serial.errorString();
    } else {
        qDebug() << "串口已连接:" << portName;
    }
}

void SerialDebugBackend::stop()
{
    if (serial.isOpen())
        serial.close();
}

void SerialDebugBackend::sendMessage(const QString &msg)
{
    if (serial.isOpen()) {
        serial.write(msg.toUtf8());
    }
}

void SerialDebugBackend::onReadyRead()
{
    QByteArray data = serial.readAll();
    emit messageReceived(QString::fromUtf8(data));

    qDebug() << "[虚拟串口] 收到数据:" << data;
    BLEManager::instance()->handleRawData(data);
}
