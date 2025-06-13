pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string monitorName

    readonly property list<Workspace> workspaces: layout.children.filter(c => c.isWorkspace).sort((w1, w2) => w1.ws - w2.ws)
    readonly property var occupied: Hyprland.workspaces.values.reduce((acc, curr) => {
        acc[curr.id] = curr.lastIpcObject.windows > 0;
        return acc;
    }, {})
    
    // Get workspaces assigned to this monitor
    readonly property var monitorWorkspaces: {
        const monitor = Hyprland.monitors.values.find(m => m.name === monitorName);
        if (!monitor) {
            return [];
        }
        
        // Get all workspaces for this monitor
        const wsIds = Hyprland.workspaces.values
            .filter(ws => {
                return ws.monitor.name === monitorName;
            })
            .map(ws => ws.id)
            .sort((a, b) => a - b);
        
        return wsIds;
    }
    
    readonly property int minWorkspace: {
        const min = monitorWorkspaces.length > 0 ? Math.min(...monitorWorkspaces) : 1;
        return min;
    }
    readonly property int maxWorkspace: {
        const max = monitorWorkspaces.length > 0 ? Math.max(...monitorWorkspaces) : BarConfig.workspaces.shown;
        return max;
    }
    readonly property int workspaceCount: {
        const count = monitorWorkspaces.length > 0 ? monitorWorkspaces.length : BarConfig.workspaces.shown;
        return count;
    }
    readonly property int groupOffset: {
        const offset = minWorkspace - 1;
        return offset;
    }

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    ColumnLayout {
        id: layout

        spacing: 0
        layer.enabled: true
        layer.smooth: true

        Repeater {
            model: root.workspaceCount

            Workspace {
                occupied: root.occupied
                groupOffset: root.groupOffset
                monitorWorkspaces: root.monitorWorkspaces
            }
        }
    }

    Loader {
        active: BarConfig.workspaces.occupiedBg
        asynchronous: true

        z: -1
        anchors.fill: parent

        sourceComponent: OccupiedBg {
            workspaces: root.workspaces
            occupied: root.occupied
            groupOffset: root.groupOffset
        }
    }

    Loader {
        active: BarConfig.workspaces.activeIndicator
        asynchronous: true

        sourceComponent: ActiveIndicator {
            workspaces: root.workspaces
            mask: layout
            maskWidth: root.width
            maskHeight: root.height
            groupOffset: root.groupOffset
        }
    }

    MouseArea {
        anchors.fill: parent

        onPressed: event => {
            const workspaceComponent = layout.childAt(event.x, event.y);
            if (workspaceComponent && workspaceComponent.ws) {
                const ws = workspaceComponent.ws;
                if (Hyprland.activeWsId !== ws)
                    Hyprland.dispatch(`workspace ${ws}`);
            }
        }
    }
}
