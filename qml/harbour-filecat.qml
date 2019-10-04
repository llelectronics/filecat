import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: mainWindow

    initialPage: Component { OpenDialog { } }
    cover: undefined
    allowedOrientations: defaultAllowedOrientations

    property string lastKnownDir

    property alias infoBanner: infoBanner

    property bool vPlayerExternal: false

    property bool isLightTheme: {
        if (Theme.colorScheme == Theme.LightOnDark) return false
        else return true
    }

    ListModel {
        id: clipboard
//        ListElement {
//            source: "path/to/filename"
//              name: "filename"
//        }
        function add(path,name) {
            append({"source":path, "name": name});
        }
        function remove(path) {
            for (var i=0; i<count; i++) {
                if (get(i).source === path) remove(i);
            }
        }
    }

    function findBaseName(url) {
        url = url.toString();
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        var dot = fileName.lastIndexOf('.');
        return dot == -1 ? fileName : fileName.substring(0, dot);
    }

    function openWithvPlayer(url,title) {
        if (!vPlayerExternal) pageStack.push(Qt.resolvedUrl("pages/fmComponents/VideoPlayer.qml"), {dataContainer: pageStack.currentPage, streamUrl: url, streamTitle: title});
        else Qt.openUrlExternally(url);
    }

    InfoBanner {
        id: infoBanner
        z:99
    }
}
