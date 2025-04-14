// motorinfo.h
#ifndef MOTORINFO_H
#define MOTORINFO_H

#include <QObject>

class MotorInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(int pwm READ pwm WRITE setPwm NOTIFY pwmChanged)
    Q_PROPERTY(int time READ time WRITE setTime NOTIFY timeChanged)

public:
    explicit MotorInfo(QObject *parent = nullptr) : QObject(parent), m_pwm(1500), m_time(0) {}

    int pwm() const { return m_pwm; }
    void setPwm(int pwm) {
        if (m_pwm != pwm) {
            m_pwm = pwm;
            emit pwmChanged();
        }
    }

    int time() const { return m_time; }
    void setTime(int time) {
        if (m_time != time) {
            m_time = time;
            emit timeChanged();
        }
    }

signals:
    void pwmChanged();
    void timeChanged();

private:
    int m_pwm;
    int m_time;
};

#endif // MOTORINFO_H
