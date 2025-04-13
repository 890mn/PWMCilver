#include "blecontroller.h"
#include <QTimer>

BLEController::BLEController(QObject *parent) : QObject(parent)
{
    manager = new BLEManager(this);

    connect(manager, &BLEManager::messageReceived,
            this, &BLEController::messageReceived);

    connect(manager, &BLEManager::ultrasonicSingleUpdated,
            this, &BLEController::ultrasonicSingleUpdated);


    connect(manager, &BLEManager::motorCommandReceived,
            this, &BLEController::motorCommandReceived);

    connect(manager, &BLEManager::readyToWrite, this, [=]() {
        m_connected = true;
        emit connectedChanged(m_connected);
    });

    connect(manager, &BLEManager::readyToWrite, this, [=]() {
        qDebug() << "准备写入，连接完成";
        emit deviceConnected(); // ✅ 额外添加一个 signal
    });
}

void BLEController::connectToTargetDevice()
{
    manager->startScan();

    connect(manager, &BLEManager::deviceDiscovered, this, [=](const QString &name, const QBluetoothDeviceInfo &info) {
        if (name.contains("PWMC-BT24", Qt::CaseInsensitive)) {
            manager->stopScan(); // 发现目标立即停止扫描
            manager->connectToDevice(info);
        }
    });
}

void BLEController::sendMessage(const QString &message)
{
    if (manager) {
        manager->sendMessage(message);
    }
}
