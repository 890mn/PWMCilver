#pragma once

#include <QObject>
#include "blemanager.h"

class BLEController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectedChanged)
public:
    explicit BLEController(QObject *parent = nullptr);
    Q_INVOKABLE void connectToTargetDevice();
    bool isConnected() const { return m_connected; }
    Q_INVOKABLE void sendMessage(const QString &message);

signals:
    void connectedChanged(bool connected);
    void messageReceived(const QString &message);
    void deviceConnected();
    void ultrasonicSingleUpdated(int direction, int value); // 1=左，2=前，3=右，4=后
    void motorCommandReceived(const QString &id, int pwm, int time);


private:
    BLEManager *manager;
    bool m_connected = false;
};
