cmake_minimum_required(VERSION 3.21)

project(TruckBlindSpotExample VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Silence le warning 'QTP0001' (préfixe ressources QML)
# Voir: https://doc.qt.io/qt-6/qt-cmake-policy-qtp0001.html
if (POLICY CMP0144)  # CMake >= 3.25
  cmake_policy(SET CMP0144 NEW)
endif()
# Préfixe par défaut pour modules QML (même si on n'ajoute pas de module QML ici)
set(QT_QML_IMPORT_PATH "")
set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/qml")

# Modules Qt nécessaires
find_package(Qt6 REQUIRED COMPONENTS
    Quick
    Quick3D
    Quick3DAssetUtils   # requis pour RuntimeLoader (chargement .glb)
    Multimedia
    SerialPort
)

# Exécutable (main.qml est dans qml.qrc)
qt_add_executable(appTruckBlindSpotExample
    main.cpp
    ArduinoController.cpp
    qml.qrc
)

# Lier les libs Qt
target_link_libraries(appTruckBlindSpotExample PRIVATE
    Qt6::Quick
    Qt6::Quick3D
    Qt6::Quick3DAssetUtils
    Qt6::Multimedia
    Qt6::SerialPort
)

# (Optionnel) Icône/GUI Windows : évite la console noire quand tu lances l'appli
if (WIN32)
  set_target_properties(appTruckBlindSpotExample PROPERTIES WIN32_EXECUTABLE TRUE)
endif()
