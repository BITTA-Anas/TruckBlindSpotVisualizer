import QtQuick
import QtQuick.Window
import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils
import QtMultimedia

Window {
    id: win
    width: 1280
    height: 720
    visible: true
    title: qsTr("3D + 3 fenêtres caméra (découpe unique)")

    // ---------- SCÈNE 3D ----------
    View3D {
        id: scene3D
        anchors.fill: parent
        focus: true

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Color
            clearColor: "#202020"
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        TapHandler { onTapped: scene3D.forceActiveFocus() }
        DragHandler { onActiveChanged: if (active) scene3D.forceActiveFocus() }

        DirectionalLight {
            brightness: 1.0
            eulerRotation: Qt.vector3d(-45, -35, 0)
            ambientColor: Qt.rgba(0.45, 0.45, 0.45, 1.0)
        }
        DirectionalLight {
            brightness: 0.6
            eulerRotation: Qt.vector3d(35, 45, 0)
            ambientColor: Qt.rgba(0.25, 0.25, 0.25, 1.0)
        }

        Node {
            id: truckRoot
            property real modelScale: 150   // ⇦ agrandis/réduis ici
            scale: Qt.vector3d(modelScale, modelScale, modelScale)
            position: Qt.vector3d(0, 0, 0)

            // ➜ vue de 3/4 (45°)
            eulerRotation: Qt.vector3d(0, 45, 0)

            RuntimeLoader {
                id: truckModel
                source: "qrc:/models/2003_gmc_topkick_c6500.glb"
            }
        }

        PerspectiveCamera {
            id: cam3D
            position: Qt.vector3d(0, 3, 18)
        }

        OrbitCameraController {
            camera: cam3D
            origin: truckRoot
        }
    }

    // ---------- CAMÉRA UNIQUE + DUPLICATION PAR SHADER ----------
    Camera { id: webcam; active: true }

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

    // ---------- Composant vignette (un tiers du flux vidéo) ----------
    Component {
        id: camSlice

        Rectangle {
            id: frame
            property int sliceIndex: 1 // 0=gauche, 1=centre, 2=droite
            width: 360
            height: 220
            radius: 12
            color: "#0f1116"
            border.color: "#3a3f4b"
            border.width: 1
            clip: true

            ShaderEffectSource {
                id: sliceTex
                anchors.fill: parent
                sourceItem: videoSourceBox
                live: true
                hideSource: true
                sourceRect: Qt.rect(
                    sliceIndex * videoSourceBox.width / 3,
                    (videoSourceBox.height - (videoSourceBox.width/3) * frame.height/frame.width)/2,
                    videoSourceBox.width / 3,
                    (videoSourceBox.width/3) * frame.height/frame.width
                )
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 24
                color: "#00000080"
                Text {
                    anchors.centerIn: parent
                    color: "white"
                    font.pointSize: 10
                    font.bold: true
                    text: sliceIndex === 0 ? "Cam: tiers gauche"
                         : sliceIndex === 1 ? "Cam: tiers centre"
                         : "Cam: tiers droit"
                }
            }
        }
    }

    // ---------- Placement des 3 vignettes ----------
    // Gauche
    Loader {
        id: leftView
        sourceComponent: camSlice
        onLoaded: item.sliceIndex = 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 40
    }

    // Droite
    Loader {
        id: rightView
        sourceComponent: camSlice
        onLoaded: item.sliceIndex = 2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 40
    }

    // Centre (en haut)
    Loader {
        id: centerView
        sourceComponent: camSlice
        onLoaded: item.sliceIndex = 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
    }

    // ---------- Contrôles clavier : rotation du camion ----------
    Shortcut { sequences: [ Qt.Key_Left  ]; onActivated: truckRoot.eulerRotation.y -= 5 }
    Shortcut { sequences: [ Qt.Key_Right ]; onActivated: truckRoot.eulerRotation.y += 5 }
    Shortcut { sequences: [ Qt.Key_5 ]; onActivated: truckRoot.eulerRotation = Qt.vector3d(0, 45, 0) }
}
