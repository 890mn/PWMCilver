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

signals:
    void connectedChanged(bool connected);
    void messageReceived(const QString &message);
    void deviceConnected();

private:
    BLEManager *manager;
    bool m_connected = false;
};
