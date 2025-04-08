#pragma once

#include <QObject>
#include <QBluetoothSocket>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothServiceInfo>

class BluetoothSerial : public QObject
{
    Q_OBJECT
public:
    explicit BluetoothSerial(QObject *parent = nullptr);

    Q_INVOKABLE void connectToDevice(const QString &address);
    Q_INVOKABLE void disconnectDevice();
    Q_INVOKABLE void startDiscovery();

signals:
    void dataReceived(const QString &data);
    void statusChanged(const QString &status);
    void serviceFound(const QString &name, const QString &address);

private slots:
    void onConnected();
    void onDisconnected();
    void onReadyRead();
    void onDeviceDiscovered(const QBluetoothDeviceInfo &info);

private:
    QBluetoothSocket *socket;
    QBluetoothDeviceDiscoveryAgent *discoveryAgent;
};
