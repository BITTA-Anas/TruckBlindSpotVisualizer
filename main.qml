import QtQuick
import QtQuick.Window
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils
import QtMultimedia

Window {
    id: win
    width: 500
    height: 720
    visible: true
    title: qsTr("3D SAFE – rotation + caméra clignotant")

    // --- angles de départ ---
    readonly property vector3d initialRot: Qt.vector3d(0, 150, 0)   // X,Y,Z
    readonly property vector3d leftRot:    Qt.vector3d(0, -45, 0)
    readonly property vector3d rightRot:   Qt.vector3d(0, 45, 0)
    readonly property vector3d restRot:    Qt.vector3d(-90, 180, 0) // vue de dessus

    // --- positions ---
    readonly property vector3d initialPos: Qt.vector3d(0, 0, 0)
    readonly property vector3d restPos:    Qt.vector3d(0, 2, 0)     // camion plus haut en repos

    // --- tailles camion ---
    readonly property real normalScale: 120   // taille en mode normal
    readonly property real restScale:    60   // taille en mode repos

    property int  rotDuration: 700
    property var  rotEase: Easing.InOutCubic
    readonly property real eps: 0.1

    // 0 = neutre, 1 = clignotant gauche, 2 = clignotant droite
    property int cameraMode: 0
    // mode repos DOWN
    property bool restMode: false

    // 🔔 visibilité de la fenêtre d’alerte
    property bool alertVisible: false

    property string alertType: ""

    // État visuel des feux de détresse en mode repos
    property bool restBlinkOn: false

    // État clignotant gauche / droite
    property bool turnBlinkOn: false

    // état global
    property string scene: "startup"

    View3D {
        id: scene3D
        anchors.fill: parent

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Color
            clearColor: "#B4B4B4"
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        // Lumières
        DirectionalLight {
            brightness: 1.0
            eulerRotation: Qt.vector3d(-45, -35, 0)
            ambientColor: Qt.rgba(0.45,0.45,0.45,1)
        }
        DirectionalLight {
            brightness: 0.6
            eulerRotation: Qt.vector3d(35, 45, 0)
            ambientColor: Qt.rgba(0.25,0.25,0.25,1)
        }

        // ---- MODELE ----
        Node {
            id: truckRoot

            property real modelScale: win.normalScale
            scale: Qt.vector3d(modelScale, modelScale, modelScale)

            position: win.initialPos
            eulerRotation: win.initialRot

            RuntimeLoader {
                id: model
                source: "qrc:/models/2003_gmc_topkick_c6500.glb"
            }
        }

        // Caméra principale
        PerspectiveCamera {
            id: cam3D
            position: Qt.vector3d(0, 3, 18)
        }

        OrbitCameraController { camera: cam3D; origin: truckRoot }

        // Redonner le focus au clavier
        TapHandler { onTapped: keyCatcher.forceActiveFocus() }
        DragHandler {
            onActiveChanged: {
                if (!active) {
                    win.restorePoseForCurrentMode()
                } else {
                    keyCatcher.forceActiveFocus()
                }
            }
        }
    }

    // ----------- Animations rotation X, Y, Z -------------
    NumberAnimation { id: animX; target: truckRoot; property: "eulerRotation.x"; duration: rotDuration; easing.type: rotEase }
    NumberAnimation { id: animY; target: truckRoot; property: "eulerRotation.y"; duration: rotDuration; easing.type: rotEase }
    NumberAnimation { id: animZ; target: truckRoot; property: "eulerRotation.z"; duration: rotDuration; easing.type: rotEase }

    // position
    NumberAnimation { id: animPosX; target: truckRoot; property: "position.x"; duration: rotDuration; easing.type: rotEase }
    NumberAnimation { id: animPosY; target: truckRoot; property: "position.y"; duration: rotDuration; easing.type: rotEase }
    NumberAnimation { id: animPosZ; target: truckRoot; property: "position.z"; duration: rotDuration; easing.type: rotEase }

    // scale camion
    NumberAnimation { id: animScale; target: truckRoot; property: "modelScale"; duration: rotDuration; easing.type: rotEase }

    // zoom caméra
    NumberAnimation { id: animCamZ; target: cam3D; property: "position.z"; duration: rotDuration; easing.type: rotEase }

    // ----------- Caméra et flux vidéo caché -------------
    Camera {
        id: webcam
        active: cameraPanel.visible
    }

    Item {
        id: videoSourceBox
        visible: false
        width: 960
        height: 540
        anchors.right: parent.right
        anchors.top: parent.top

        VideoOutput {
            id: videoFull
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectFit
        }

        CaptureSession {
            camera: webcam
            videoOutput: videoFull
        }
    }

    // ----------- Fenêtre caméra en bas au centre + SWIPE -------------
    Rectangle {
        id: cameraPanel
        width: 320
        height: 180
        radius: 14
        color: "#101010"
        border.color: "#424242"
        border.width: 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        visible: false
        clip: true

        property real dragOffset: 0
        property real visibleFraction: 0.45

        property real thirdWidth: videoSourceBox.width / 3
        property real sliceWidth: videoSourceBox.width * visibleFraction
        property real maxPan: thirdWidth / 2

        property real baseX: {
            var W  = videoSourceBox.width;
            var Tw = thirdWidth;
            var sliceW = sliceWidth;
            var center;

            if (win.cameraMode === 1) {          // gauche → tiers gauche
                center = 1 * Tw / 2;
            } else if (win.cameraMode === 2) {   // droite → tiers droit
                center = 5 * Tw / 2;
            } else {
                center = 3 * Tw / 2;             // milieu
            }

            var x = center - sliceW / 2;
            if (x < 0) x = 0;
            if (x + sliceW > W) x = W - sliceW;
            return x;
        }

        ShaderEffectSource {
            anchors.fill: parent
            sourceItem: videoFull
            live: true
            hideSource: true

            sourceRect: {
                var W   = videoSourceBox.width;
                var sliceW = cameraPanel.sliceWidth;

                var sx = cameraPanel.baseX + cameraPanel.dragOffset;

                var minX = 0;
                var maxX = W - sliceW;
                var clampedX = Math.max(minX, Math.min(maxX, sx));

                var h = sliceW * cameraPanel.height / cameraPanel.width;
                var y = (videoSourceBox.height - h) / 2;

                return Qt.rect(clampedX, y, sliceW, h);
            }
        }

        DragHandler {
            id: camDrag
            target: null
            onTranslationChanged: {
                if (win.cameraMode === 0)
                    return;

                var Tw = cameraPanel.thirdWidth;
                var maxPan = cameraPanel.maxPan;

                var px = translation.x * (Tw / cameraPanel.width);

                if (px > maxPan) px = maxPan;
                if (px < -maxPan) px = -maxPan;

                cameraPanel.dragOffset = px;
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 4
            color: "#e0e0e0"
            font.pixelSize: 12
            text: win.restMode
                  ? "Mode repos"
                  : "Caméra"
        }
    }

    // ----------- FENÊTRE D’ALERTE (ESPACE, auto-close 3s) -------------
    Rectangle {
        id: alertOverlay
        anchors.fill: parent
        color: "#00000080"          // fond noir semi-transparent
        visible: win.alertVisible
        z: 100

        MouseArea {
            anchors.fill: parent
            onClicked: win.alertVisible = false
        }

        Rectangle {
            id: alertBox
            width: 250
            height: 200
            radius: 14
            color: "#222222"        // gris très foncé
            border.color: "#777777" // gris moyen
            border.width: 2
            anchors.centerIn: parent
            clip: true              // ✅ rien ne déborde de la boîte

            Column {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 12

    // Titre de l’alerte
    Text {
        text: "Alerte angle mort"
        color: "#ffffff"
        font.bold: true
        font.pixelSize: 18
        width: parent.width
        wrapMode: Text.WordWrap
    }

    // Message principal
    Text {
    id: alertMessage
    color: "#f0f0f0"
    wrapMode: Text.WordWrap
    width: parent.width
    maximumLineCount: 3
    elide: Text.ElideRight
    font.pixelSize: 13

    text: {
        if (alertType === "left")
            return "⚠ Objet détecté dans l’angle mort GAUCHE.\nVérifiez avant de changer de voie."
        else if (alertType === "right")
            return "⚠ Objet détecté dans l’angle mort DROIT.\nVérifiez avant de changer de voie."
        else
            return "⚠ Objet détecté dans la zone d’angle mort."
    }
}


    // Bouton OK
    Rectangle {
        id: okButton
        width: parent.width
        height: 32
        radius: 8
        color: "#444444"
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
            anchors.centerIn: parent
            text: "OK"
            color: "white"
            font.bold: true
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: win.alertVisible = false
        }
    }
}

        }
    }

    Timer {
        id: alertTimer
        interval: 3000
        repeat: false
        onTriggered: win.alertVisible = false
    }

    Timer {
    id: restBlinkTimer
    interval: 500        // 500 ms : ON / OFF
    repeat: true
    running: false

    onTriggered: {
        restBlinkOn = !restBlinkOn
    }

    }

    Timer {
    id: turnBlinkTimer
    interval: 500
    repeat: true
    running: false

    onTriggered: {
        turnBlinkOn = !turnBlinkOn
    }
}

    // ----------- Fonctions JS -----------
    function animateToPose(rotVec, posVec, scaleVal) {
        animX.to = rotVec.x
        animY.to = rotVec.y
        animZ.to = rotVec.z

        animPosX.to = posVec.x
        animPosY.to = posVec.y
        animPosZ.to = posVec.z

        animScale.to = scaleVal

        animX.start(); animY.start(); animZ.start()
        animPosX.start(); animPosY.start(); animPosZ.start()
        animScale.start()

        animCamZ.to = 18
        animCamZ.start()
    }

    function restorePoseForCurrentMode() {
        var rot, pos, sc

        if (restMode) {
            rot = restRot
            pos = restPos
            sc  = restScale
        } else if (cameraMode === 1) {
            rot = leftRot
            pos = initialPos
            sc  = normalScale
        } else if (cameraMode === 2) {
            rot = rightRot
            pos = initialPos
            sc  = normalScale
        } else {
            rot = initialRot
            pos = initialPos
            sc  = normalScale
        }

        animateToPose(rot, pos, sc)
    }

    function handleLeft() {
    if (restMode)
        return

    if (cameraMode === 1) {
        cameraMode = 0
        scene = "startup"
        turnBlinkTimer.stop()
        turnBlinkOn = false
        cameraPanel.visible = false
        restorePoseForCurrentMode()
    } else {
        cameraMode = 1
        scene = "left"
        turnBlinkOn = false
        turnBlinkTimer.start()
        cameraPanel.visible = true
        animateToPose(leftRot, initialPos, normalScale)
    }
}



    function handleRight() {
    if (restMode)
        return

    if (cameraMode === 2) {
        cameraMode = 0
        scene = "startup"
        turnBlinkTimer.stop()
        turnBlinkOn = false
        cameraPanel.visible = false
        restorePoseForCurrentMode()
    } else {
        cameraMode = 2
        scene = "right"
        turnBlinkOn = false
        turnBlinkTimer.start()
        cameraPanel.visible = true
        animateToPose(rightRot, initialPos, normalScale)
    }
}



    function handleNeutral() {
    if (restMode)
        return

    scene = "startup"
    cameraMode = 0
    cameraPanel.visible = false
    restorePoseForCurrentMode()
}


    function handleRestToggle() {
    if (!restMode) {
        restMode = true
        scene = "rest"

        cameraMode = 0
        cameraPanel.visible = false

        restBlinkOn = false
        restBlinkTimer.start()

        animateToPose(restRot, restPos, restScale)
    } else {
        restMode = false
        scene = "startup"

        restBlinkTimer.stop()
        restBlinkOn = false

        restorePoseForCurrentMode()
    }
}


    function handleAlert(type = "generic") {
    // 🔒 Anti-spam : si une alerte est déjà affichée, on ignore
    if (win.alertVisible)
        return

    alertType = type
    win.alertVisible = true
    alertTimer.restart()
}


    // ----------- Clavier ----------- 
    Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true
        Component.onCompleted: keyCatcher.forceActiveFocus()

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Left) {
                handleLeft()
                event.accepted = true
            }
            else if (event.key === Qt.Key_Right) {
                handleRight()
                event.accepted = true
            }
            else if (event.key === Qt.Key_5) {
                handleNeutral()
                event.accepted = true
            }
            else if (event.key === Qt.Key_Down) {
                handleRestToggle()
                event.accepted = true
            }
            else if (event.key === Qt.Key_Space && !restMode) {
                handleAlert("manual")
                event.accepted = true
            }
            else if (event.key === Qt.Key_Escape && win.alertVisible) {
                win.alertVisible = false
                event.accepted = true
            }
        }
    }

    Item {
    id: svgOverlay
    anchors.fill: parent
    z: 40

    /* =========================
       STARTUP : TOUT OFF
       ========================= */

    // ROUTE
    Image {
        anchors.fill: parent
        visible: scene === "startup"
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: "qrc:/models/svgicons/route.SVG"
    }

    // CLIGNOTANT GAUCHE OFF
    Image {
        anchors.fill: parent
        visible: scene === "startup" || scene === "right"
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: "qrc:/models/svgicons/ClignotantGaucheOff.SVG"
    }

    // CLIGNOTANT DROIT OFF
    Image {
        anchors.fill: parent
        visible: scene === "startup" || scene === "left"
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: "qrc:/models/svgicons/ClignotantDroitOff.SVG"
    }

    // FEU OFF
    Image {
        anchors.fill: parent
        visible: scene === "startup" || scene === "left" || scene === "right"
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: "qrc:/models/svgicons/FeuOff.SVG"
    }

    /* =========================
       CLIGNOTANTS EN FONCTION
       ========================= */

    // CLIGNOTANT GAUCHE
    Image {
        anchors.fill: parent
        visible: scene === "left" || scene === "rest"
        fillMode: Image.PreserveAspectFit
        smooth: true

        source:
            (scene === "rest" ? restBlinkOn : turnBlinkOn)
                ? "qrc:/models/svgicons/ClignotantGaucheOn.SVG"
                : "qrc:/models/svgicons/ClignotantGaucheOff.SVG"
    }

    // CLIGNOTANT DROIT
    Image {
        anchors.fill: parent
        visible: scene === "right" || scene === "rest"
        fillMode: Image.PreserveAspectFit
        smooth: true

        source:
            (scene === "rest" ? restBlinkOn : turnBlinkOn)
                ? "qrc:/models/svgicons/ClignotantDroitOn.SVG"
                : "qrc:/models/svgicons/ClignotantDroitOff.SVG"
    }

    /* =========================
       FEU DÉTRESSE
       ========================= */

    Image {
        anchors.fill: parent
        visible: scene === "rest"
        fillMode: Image.PreserveAspectFit
        smooth: true

        source:
            restBlinkOn
                ? "qrc:/models/svgicons/FeuOn.SVG"
                : "qrc:/models/svgicons/FeuOff.SVG"
    }

    // ROUTE ÉTAT REPOS
    Image {
        anchors.fill: parent
        visible: scene === "rest"
        fillMode: Image.PreserveAspectFit
        smooth: true
        source: "qrc:/models/svgicons/RouteEtatRepos.SVG"
    }
}

    Shortcut { sequences: [ Qt.Key_Left  ]; onActivated: handleLeft() }
    Shortcut { sequences: [ Qt.Key_Right ]; onActivated: handleRight() }
    Shortcut { sequences: [ Qt.Key_5    ]; onActivated: handleNeutral() }
    Shortcut { sequences: [ Qt.Key_Down ]; onActivated: handleRestToggle() }
    Shortcut {
    sequences: [ Qt.Key_Space ]
    enabled: !restMode
    onActivated: handleAlert("manual")
}

    Connections {
    target: arduino

    function onButtonReceived(value) {
        console.log("Arduino bouton:", value)

        if (value === 1) {
            handleLeft()
        } else if (value === 2) {
            handleRight()
        } else if (value === 3) {
            handleRestToggle()   // ✅ SAFE / repos
        }
    }

    function onDangerLeft() {
        // ✅ alertes UNIQUEMENT si SAFE / DOWN / BTN3 actif
        if (restMode) {
            handleAlert("left")
        }
    }

    function onDangerRight() {
        // ✅ alertes UNIQUEMENT si SAFE / DOWN / BTN3 actif
        if (restMode) {
            handleAlert("right")
        }
    }
}

}
