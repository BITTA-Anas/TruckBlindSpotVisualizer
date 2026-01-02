/****************************************************************************
** Meta object code from reading C++ file 'ArduinoController.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.9.3)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../ArduinoController.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ArduinoController.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.9.3. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN17ArduinoControllerE_t {};
} // unnamed namespace

template <> constexpr inline auto ArduinoController::qt_create_metaobjectdata<qt_meta_tag_ZN17ArduinoControllerE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "ArduinoController",
        "buttonReceived",
        "",
        "value",
        "dangerLeft",
        "dangerRight",
        "clearLeft",
        "clearRight",
        "readSerial"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'buttonReceived'
        QtMocHelpers::SignalData<void(int)>(1, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 3 },
        }}),
        // Signal 'dangerLeft'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'dangerRight'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'clearLeft'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'clearRight'
        QtMocHelpers::SignalData<void()>(7, 2, QMC::AccessPublic, QMetaType::Void),
        // Slot 'readSerial'
        QtMocHelpers::SlotData<void()>(8, 2, QMC::AccessPrivate, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<ArduinoController, qt_meta_tag_ZN17ArduinoControllerE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject ArduinoController::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17ArduinoControllerE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17ArduinoControllerE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN17ArduinoControllerE_t>.metaTypes,
    nullptr
} };

void ArduinoController::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<ArduinoController *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->buttonReceived((*reinterpret_cast< std::add_pointer_t<int>>(_a[1]))); break;
        case 1: _t->dangerLeft(); break;
        case 2: _t->dangerRight(); break;
        case 3: _t->clearLeft(); break;
        case 4: _t->clearRight(); break;
        case 5: _t->readSerial(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (ArduinoController::*)(int )>(_a, &ArduinoController::buttonReceived, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArduinoController::*)()>(_a, &ArduinoController::dangerLeft, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArduinoController::*)()>(_a, &ArduinoController::dangerRight, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArduinoController::*)()>(_a, &ArduinoController::clearLeft, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArduinoController::*)()>(_a, &ArduinoController::clearRight, 4))
            return;
    }
}

const QMetaObject *ArduinoController::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ArduinoController::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN17ArduinoControllerE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int ArduinoController::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 6)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 6;
    }
    return _id;
}

// SIGNAL 0
void ArduinoController::buttonReceived(int _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 0, nullptr, _t1);
}

// SIGNAL 1
void ArduinoController::dangerLeft()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void ArduinoController::dangerRight()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void ArduinoController::clearLeft()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void ArduinoController::clearRight()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}
QT_WARNING_POP
