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
    Q_INVOKABLE void sendMessage(const QString &message);

signals:
    void deviceDiscovered(const QString &name, const QBluetoothDeviceInfo &info);
    void connected();
    void readyToWrite();
    void messageReceived(const QString &message);

    void ultrasonicSingleUpdated(int direction, int value); // 1=左，2=前，3=右，4=后
    void motorCommandReceived(const QString &id, int pwm, int time);

private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent = nullptr;
    QLowEnergyController *controller = nullptr;
    QLowEnergyService *service = nullptr;
    QLowEnergyCharacteristic writeCharacteristic;

    QBluetoothUuid serviceUuid = QBluetoothUuid(QStringLiteral("0000FFE0-0000-1000-8000-00805F9B34FB"));
    QBluetoothUuid charUuid = QBluetoothUuid(QStringLiteral("0000FFE1-0000-1000-8000-00805F9B34FB"));

    QMap<int, int> ultrasonicCache; // 1=Left, 2=Front, 3=Right, 4=Back

    void parseUltrasonicData(const QString &data);
    void parseMotorCommand(const QString &data);
};
