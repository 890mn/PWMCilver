#include "blemanager.h"
#include <QDebug>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QRegularExpressionMatchIterator>
#include <QMap>

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

void BLEManager::stopScan()
{
    discoveryAgent->stop();
}

void BLEManager::connectToDevice(const QBluetoothDeviceInfo &info)
{
    if (controller)
        controller->deleteLater();

    controller = QLowEnergyController::createCentral(info, this);

    connect(controller, &QLowEnergyController::connected, this, [=]() {
        qDebug() << "已连接设备：" << info.name();
        controller->discoverServices();
    });

    connect(controller, &QLowEnergyController::serviceDiscovered, this, [=](const QBluetoothUuid &uuid) {
        qDebug() << "发现服务：" << uuid.toString();
    });

    connect(controller, &QLowEnergyController::discoveryFinished, this, [=]() {
        service = controller->createServiceObject(serviceUuid, this);
        if (!service) {
            qWarning() << "无法创建服务对象";
            return;
        }

        connect(service, &QLowEnergyService::stateChanged, this, [=](QLowEnergyService::ServiceState s) {
            if (s == QLowEnergyService::RemoteServiceDiscovered) {
                qDebug() << "服务详情发现完毕，可以开始通信";
                emit readyToWrite();

                for (const QLowEnergyCharacteristic &ch : service->characteristics()) {
                    if (ch.uuid().toString().contains("ffe1", Qt::CaseInsensitive)) {
                        qDebug() << "找到 FFE1 特征，设置通知监听";
                        QBluetoothUuid notifyUuid(QStringLiteral("00002902-0000-1000-8000-00805f9b34fb")); // CCCD UUID
                        QLowEnergyDescriptor notifyDesc = ch.descriptor(notifyUuid);
                        if (notifyDesc.isValid()) {
                            service->writeDescriptor(notifyDesc, QByteArray::fromHex("0100")); // 开启通知
                        }

                        connect(service, &QLowEnergyService::characteristicChanged, this,
                            [=](const QLowEnergyCharacteristic &c, const QByteArray &value) {
                            if (c.uuid() == ch.uuid()) {
                                QString rawData = QString::fromUtf8(value);
                                qDebug() << "收到数据:" << rawData;
                                emit messageReceived(rawData); // 原始数据依然传出去

                                if (rawData.contains("UTime")) {
                                    // 解析超声波数据
                                    QMap<int, int> parsed;
                                    QRegularExpression regex(R"(\[(\d+)\]UTime=(\d+))");
                                    QRegularExpressionMatchIterator it = regex.globalMatch(rawData);
                                    while (it.hasNext()) {
                                        QRegularExpressionMatch match = it.next();
                                        int index = match.captured(1).toInt(); // 1~4
                                        int value = match.captured(2).toInt();
                                        parsed[index] = value;
                                    }

                                    // 顺序：1=左，2=前，3=右，4=后
                                    emit ultrasonicDataUpdated(
                                        parsed.value(1, -1), // Left
                                        parsed.value(2, -1), // Front
                                        parsed.value(3, -1), // Right
                                        parsed.value(4, -1)  // Back
                                    );
                                } else {
                                    QString trimmed = rawData.trimmed();
                                    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
                                        trimmed = trimmed.mid(1, trimmed.length() - 2); // 去掉花括号
                                    }

                                    QRegularExpression motorRegex(R"(#(\d{3})P(\d{4})T(\d{4})!)");
                                    QRegularExpressionMatchIterator motorIt = motorRegex.globalMatch(trimmed);

                                    while (motorIt.hasNext()) {
                                        QRegularExpressionMatch match = motorIt.next();
                                        QString id = match.captured(1);
                                        int pwm = match.captured(2).toInt();
                                        int time = match.captured(3).toInt();

                                        emit motorCommandReceived(id, pwm, time);
                                    }

                                }
                            }
                        });
                        break; // 找到后就退出循环
                    }
                }
            }
        });

        service->discoverDetails();
    });

    controller->connectToDevice();
}

