#pragma once

#include <QObject>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothDeviceInfo>
#include <QRegularExpression>  // ✅ 用于解析数据

class BLEManager : public QObject
{
    Q_OBJECT
public:
    explicit BLEManager(QObject *parent = nullptr);
    void startScan();
    void stopScan();
    void connectToDevice(const QBluetoothDeviceInfo &info);

signals:
    void deviceDiscovered(const QString &name, const QBluetoothDeviceInfo &info);
    void connected();
    void readyToWrite();
    void messageReceived(const QString &message);

    void ultrasonicDataUpdated(int left, int front, int right, int back);
    void motorCommandReceived(const QString &id, int pwm, int time);

private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent = nullptr;
    QLowEnergyController *controller = nullptr;
    QLowEnergyService *service = nullptr;

    QBluetoothUuid serviceUuid = QBluetoothUuid(QStringLiteral("0000FFE0-0000-1000-8000-00805F9B34FB"));
    QBluetoothUuid charUuid = QBluetoothUuid(QStringLiteral("0000FFE1-0000-1000-8000-00805F9B34FB"));

    void parseUltrasonicData(const QString &data);
    void parseMotorCommand(const QString &data);
};
