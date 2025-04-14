#pragma once

#include <QObject>
#include <QQueue>
#include <QMap>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothDeviceInfo>
#include <QBluetoothUuid>
#include "MotorInfo.h"

class BLEManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)
    Q_PROPERTY(QString currentMotion READ currentMotion NOTIFY currentMotionChanged)

public:
    explicit BLEManager(QObject *parent = nullptr);

    Q_INVOKABLE void connectToTargetDevice();
    Q_INVOKABLE void sendMessage(const QString &message);
    Q_INVOKABLE void handleMotorCommand(const QString &id, int pwm, int time);

    bool isConnected() const { return m_connected; }
    QString currentMotion() const;

signals:
    void deviceDiscovered(const QString &name, const QBluetoothDeviceInfo &info);
    void connectedChanged(bool connected);
    void deviceConnected();
    void readyToWrite();
    void messageReceived(const QString &message);
    void ultrasonicSingleUpdated(int direction, int value);
    void motorCommandReceived(const QString &id, int pwm, int time);
    void currentMotionChanged();

private:
    void startScan();
    void stopScan();
    void connectToDevice(const QBluetoothDeviceInfo &info);
    void trySendNext();
    void parseUltrasonicData(const QString &data);
    void parseMotorCommand(const QString &data);
    QString computeMotionState();

private:
    QBluetoothDeviceDiscoveryAgent *discoveryAgent = nullptr;
    QLowEnergyController *controller = nullptr;
    QLowEnergyService *service = nullptr;
    QLowEnergyCharacteristic writeCharacteristic;

    QBluetoothUuid serviceUuid = QBluetoothUuid(QStringLiteral("0000FFE0-0000-1000-8000-00805F9B34FB"));
    QBluetoothUuid charUuid = QBluetoothUuid(QStringLiteral("0000FFE1-0000-1000-8000-00805F9B34FB"));

    QMap<int, int> ultrasonicCache;
    QMap<QString, MotorInfo*> m_motorMap;
    QQueue<QString> messageQueue;

    QString m_currentMotion;
    bool sending = false;
    bool m_connected = false;
};
