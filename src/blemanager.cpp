#include "blemanager.h"
#include <QTimer>
#include <QDebug>
#include <QRegularExpression>
#include <QRegularExpressionMatchIterator>

BLEManager::BLEManager(QObject *parent) : QObject(parent)
{
    QStringList ids = {"006", "007", "008", "009"};
    for (const QString &id : ids) {
        m_motorMap[id] = new MotorInfo(this);
    }

    discoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered,
            this, [=](const QBluetoothDeviceInfo &info) {
                emit deviceDiscovered(info.name(), info);
            });

    connect(discoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, []() {
        qDebug() << "扫描完成";
    });
}

BLEManager* BLEManager::instance()
{
    static BLEManager* m_instance = new BLEManager(); // 静态唯一实例
    return m_instance;
}

void BLEManager::startScan()
{
    discoveryAgent->start();
}

void BLEManager::stopScan()
{
    discoveryAgent->stop();
}

void BLEManager::setDebugMode(bool enabled)
{
    if (m_debugMode == enabled)
        return;

    m_debugMode = enabled;

    if (enabled) {
        if (!debugBackend) {
            debugBackend = new SerialDebugBackend(this);
            connect(debugBackend, &SerialDebugBackend::messageReceived,
                    this, &BLEManager::messageReceived);
        }
        debugBackend->start("COM66");
        emit connectedChanged(true);
        emit deviceConnected();
        emit readyToWrite();
    } else {
        if (debugBackend)
            debugBackend->stop();
    }

    emit debugModeChanged();
}

bool BLEManager::debugMode() const
{
    return m_debugMode;
}

void BLEManager::sendMessage(const QString &message)
{
    if (m_debugMode && debugBackend) {
        debugBackend->sendMessage(message);
        return;
    }
    // 否则还是 BLE 模式
    messageQueue.enqueue(message);
    trySendNext();
}

void BLEManager::connectToTargetDevice()
{
    if (m_debugMode) {
        qDebug() << "调试模式开启，跳过蓝牙连接";
        return;
    }
    startScan();
    connect(this, &BLEManager::deviceDiscovered, this, [=](const QString &name, const QBluetoothDeviceInfo &info) {
        if (name.contains("PWMC-BT24", Qt::CaseInsensitive)) {
            stopScan();
            connectToDevice(info);
        }
    });
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
                m_connected = true;
                emit readyToWrite();
                emit connectedChanged(true);
                emit deviceConnected();

                for (const QLowEnergyCharacteristic &ch : service->characteristics()) {
                    if (ch.uuid().toString().contains("ffe1", Qt::CaseInsensitive)) {
                        writeCharacteristic = ch;
                        QBluetoothUuid notifyUuid(QStringLiteral("00002902-0000-1000-8000-00805f9b34fb"));
                        QLowEnergyDescriptor notifyDesc = ch.descriptor(notifyUuid);
                        if (notifyDesc.isValid()) {
                            service->writeDescriptor(notifyDesc, QByteArray::fromHex("0100"));
                        }

                        connect(service, &QLowEnergyService::characteristicChanged, this,
                                [=](const QLowEnergyCharacteristic &c, const QByteArray &value) {
                                    if (c.uuid() == ch.uuid()) {
                                        QString rawData = QString::fromUtf8(value);
                                        qDebug() << "[蓝牙] 收到数据:" << rawData;
                                        emit messageReceived(rawData);
                                        handleRawData(rawData);
                                    }
                                });
                        break;
                    }
                }
            }
        });

        service->discoverDetails();
    });

    controller->connectToDevice();
}

void BLEManager::trySendNext()
{
    if (sending || messageQueue.isEmpty() || !writeCharacteristic.isValid())
        return;

    sending = true;
    QString next = messageQueue.dequeue();
    QByteArray data = next.toUtf8();

    service->writeCharacteristic(writeCharacteristic, data, QLowEnergyService::WriteWithoutResponse);

    QTimer::singleShot(50, this, [this]() {
        sending = false;
        trySendNext();
    });
}

void BLEManager::parseUltrasonicData(const QString &data)
{
    QRegularExpression regex(R"(\[(\d+)\]UTime=(\d+))");
    QRegularExpressionMatchIterator it = regex.globalMatch(data);
    while (it.hasNext()) {
        QRegularExpressionMatch match = it.next();
        int index = match.captured(1).toInt();
        int value = match.captured(2).toInt();
        ultrasonicCache[index] = value;
        emit ultrasonicSingleUpdated(index, value);
    }
}

void BLEManager::parseMotorCommand(const QString &data)
{
    QString trimmed = data.trimmed();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        trimmed = trimmed.mid(1, trimmed.length() - 2);
    }

    QRegularExpression regex(R"(#(\d{3})P(\d{4})T(\d{4})!)");
    QRegularExpressionMatchIterator it = regex.globalMatch(trimmed);

    while (it.hasNext()) {
        QRegularExpressionMatch match = it.next();
        QString id = match.captured(1);
        int pwm = match.captured(2).toInt();
        int time = match.captured(3).toInt();
        handleMotorCommand(id, pwm, time);
    }
}

void BLEManager::handleMotorCommand(const QString &id, int pwm, int time)
{
    if (!m_motorMap.contains(id)) return;

    auto motor = m_motorMap[id];
    motor->setPwm(pwm);
    motor->setTime(time);

    emit motorCommandReceived(id, pwm, time);

    QString motion = computeMotionState();
    if (motion != m_currentMotion) {
        m_currentMotion = motion;
        emit currentMotionChanged();
    }
}

void BLEManager::handleRawData(const QString &rawData) {
    if (rawData.contains("UTime")) {
        parseUltrasonicData(rawData);
    } else {
        parseMotorCommand(rawData);
    }
}

QString BLEManager::computeMotionState()
{
    auto pwmToDir = [](int pwm) {
        if (pwm > 1500) return QStringLiteral("正");
        if (pwm < 1500) return QStringLiteral("反");
        return QStringLiteral("停");
    };

    QString fl = pwmToDir(m_motorMap["006"]->pwm());
    QString fr = pwmToDir(m_motorMap["007"]->pwm());
    QString bl = pwmToDir(m_motorMap["008"]->pwm());
    QString br = pwmToDir(m_motorMap["009"]->pwm());

    if (fl == "正" && fr == "反" && bl == "正" && br == "反") return "前进 MOVE_FORWARD";
    if (fl == "反" && fr == "正" && bl == "反" && br == "正") return "后退 MOVE_BACKWARD";
    if (fl == "反" && fr == "反" && bl == "正" && br == "正") return "左转 MOVE_LEFT";
    if (fl == "正" && fr == "正" && bl == "反" && br == "反") return "右转 MOVE_RIGHT";
    if (fl == "停" && fr == "停" && bl == "停" && br == "停") return "停止 STOP";
    return "IDLE";
}

QString BLEManager::currentMotion() const
{
    return m_currentMotion;
}
