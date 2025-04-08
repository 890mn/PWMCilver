#include "BluetoothSerial.h"
#include <QBluetoothUuid>

BluetoothSerial::BluetoothSerial(QObject *parent)
    : QObject(parent)
{
    socket = new QBluetoothSocket(QBluetoothServiceInfo::RfcommProtocol, this);
    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    connect(socket, &QBluetoothSocket::readyRead, this, &BluetoothSerial::onReadyRead);
    connect(socket, &QBluetoothSocket::connected, this, &BluetoothSerial::onConnected);
    connect(socket, &QBluetoothSocket::disconnected, this, &BluetoothSerial::onDisconnected);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
            this, &BluetoothSerial::onDeviceDiscovered);
}

void BluetoothSerial::connectToDevice(const QString &address)
{
    if (socket->state() == QBluetoothSocket::SocketState::ConnectingState ||
        socket->state() == QBluetoothSocket::SocketState::ConnectedState) {
        emit statusChanged("连接正在进行中或已连接！");
        return;
    }

    QBluetoothAddress btAddress("48:87:2D:71:44:90"); // MAC地址
    QBluetoothUuid uuid(QStringLiteral("0000FFE0-0000-1000-8000-00805F9B34FB"));

    socket->connectToService(btAddress, uuid);
    emit statusChanged("正在连接...");
}

void BluetoothSerial::disconnectDevice()
{
    socket->disconnectFromService();
}

void BluetoothSerial::startDiscovery()
{
    emit statusChanged("正在扫描设备...");
    discoveryAgent->start();
}

void BluetoothSerial::onConnected()
{
    emit statusChanged("已连接");
}

void BluetoothSerial::onDisconnected()
{
    emit statusChanged("已断开连接");
}

void BluetoothSerial::onReadyRead()
{
    while (socket->canReadLine()) {
        QString line = QString::fromUtf8(socket->readLine().trimmed());
        emit dataReceived(line);
    }
}

void BluetoothSerial::onDeviceDiscovered(const QBluetoothDeviceInfo &info)
{
    emit serviceFound(info.name(), info.address().toString());
}
