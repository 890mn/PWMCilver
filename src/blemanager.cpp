#include "blemanager.h"
#include <QDebug>

BLEManager::BLEManager(QObject *parent) : QObject(parent)
{
    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);

    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this, [=](const QBluetoothDeviceInfo &info){
        emit deviceDiscovered(info.name(), info);
    });

    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, [](){
        qDebug() << "扫描完成";
    });
}

void BLEManager::startScan()
{
    discoveryAgent->start();
}

void BLEManager::connectToDevice(const QBluetoothDeviceInfo &info)
{
    if (controller)
        controller->deleteLater();

    controller = QLowEnergyController::createCentral(info, this);

    connect(controller, &QLowEnergyController::connected, this, [=](){
        qDebug() << "已连接设备：" << info.name();
        controller->discoverServices();
    });

    connect(controller, &QLowEnergyController::serviceDiscovered, this, [=](const QBluetoothUuid &uuid){
        qDebug() << "发现服务：" << uuid.toString();
    });

    connect(controller, &QLowEnergyController::discoveryFinished, this, [=](){
        service = controller->createServiceObject(serviceUuid, this);
        if (!service) {
            qWarning() << "无法创建服务对象";
            return;
        }

        connect(service, &QLowEnergyService::stateChanged, this, [=](QLowEnergyService::ServiceState s){
            if (s == QLowEnergyService::ServiceDiscovered) {
                qDebug() << "服务详情发现完毕，可以开始通信";
                emit readyToWrite();
            }
        });

        service->discoverDetails();
    });

    controller->connectToDevice();
}
