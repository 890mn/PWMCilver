#include "blecontroller.h"
#include <QTimer>

BLEController::BLEController(QObject *parent) : QObject(parent)
{
    manager = new BLEManager(this);

    connect(manager, &BLEManager::readyToWrite, this, [=]() {
        m_connected = true;
        emit connectedChanged(m_connected);
    });
}

void BLEController::connectToTargetDevice()
{
    manager->startScan();

    connect(manager, &BLEManager::deviceDiscovered, this, [=](const QString &name, const QBluetoothDeviceInfo &info) {
        if (name.contains("PWMC-BT24", Qt::CaseInsensitive)) {
            manager->connectToDevice(info);
        }
    });
}
