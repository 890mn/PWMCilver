#pragma once

#include <QObject>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothDeviceInfo>

class BLEManager : public QObject
{
    Q_OBJECT
public:
    explicit BLEManager(QObject *parent = nullptr);
    void startScan();
    void connectToDevice(const QBluetoothDeviceInfo &info);

signals:
    void deviceDiscovered(const QString &name, const QBluetoothDeviceInfo &info);
    void connected();
    void readyToWrite();
    void messageReceived(const QString &message);

private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent = nullptr;
    QLowEnergyController *controller = nullptr;
    QLowEnergyService *service = nullptr;

    QBluetoothUuid serviceUuid = QBluetoothUuid(QStringLiteral("0000FFE0-0000-1000-8000-00805F9B34FB"));
    QBluetoothUuid charUuid = QBluetoothUuid(QStringLiteral("0000FFE1-0000-1000-8000-00805F9B34FB"));
};
