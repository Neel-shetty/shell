import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property int index
    required property var occupied
    required property int groupOffset
    required property var monitorWorkspaces // Add this to pass the filtered workspace list

    readonly property bool isWorkspace: true // Flag for finding workspace children
    // Unanimated prop for others to use as reference
    readonly property real size: childrenRect.height + (hasWindows ? Appearance.padding.normal : 0)

    readonly property int ws: monitorWorkspaces[index] // Use the actual workspace ID from the filtered list
    readonly property bool isOccupied: occupied[ws] ?? false
    readonly property bool hasWindows: isOccupied && BarConfig.workspaces.showWindows
    readonly property bool isActive: Hyprland.activeWsId === ws // Check if this specific workspace is active

    Layout.preferredWidth: childrenRect.width
    Layout.preferredHeight: size

    StyledText {
        id: indicator

        readonly property string label: BarConfig.workspaces.label || root.ws
        readonly property string occupiedLabel: BarConfig.workspaces.occupiedLabel || label
        readonly property string activeLabel: BarConfig.workspaces.activeLabel || (root.isOccupied ? occupiedLabel : label)

        animate: true
        text: root.isActive ? activeLabel : root.isOccupied ? occupiedLabel : label
        color: BarConfig.workspaces.occupiedBg || root.isOccupied || root.isActive ? Colours.palette.m3onSurface : Colours.palette.m3outlineVariant
        horizontalAlignment: StyledText.AlignHCenter
        verticalAlignment: StyledText.AlignVCenter

        width: BarConfig.sizes.innerHeight
        height: BarConfig.sizes.innerHeight
    }

    Loader {
        id: windows

        active: BarConfig.workspaces.showWindows
        asynchronous: true

        anchors.horizontalCenter: indicator.horizontalCenter
        anchors.top: indicator.bottom

        sourceComponent: Column {
            spacing: Appearance.spacing.small

            add: Transition {
                Anim {
                    properties: "scale"
                    from: 0
                    to: 1
                    easing.bezierCurve: Appearance.anim.curves.standardDecel
                }
            }

            Repeater {
                model: ScriptModel {
                    values: Hyprland.clients.filter(c => c.workspace?.id === root.ws)
                }

                MaterialIcon {
                    required property Hyprland.Client modelData

                    text: Icons.getAppCategoryIcon(modelData.wmClass, "terminal")
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }
    }

    Behavior on Layout.preferredWidth {
        Anim {}
    }

    Behavior on Layout.preferredHeight {
        Anim {}
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
