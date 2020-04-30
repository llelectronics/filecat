import QtQuick 2.0
import Sailfish.Silica 1.0

DockedPanel {

    property QtObject viewer

    width: (viewer.photo.width > imgControls.childrenRect.width) ? viewer.photo.width : imgControls.childrenRect.width
    height: imgControls.height + Theme.paddingLarge
    contentHeight: height
    anchors.horizontalCenter: parent.horizontalCenter

    function checkMime(path) {
        var mime = _fm.getMime(path);
        var mimeinfo = mime.toString().split("/");
        if (mimeinfo[0] === "image") {
            return true
        }
        return false
    }

    function checkPrev() {
        if (checkMime(fileModel.get(blocker.getCurIdx() - 1, "fileURL"))) return fileModel.get(blocker.getCurIdx() - 1, "fileURL")
        else if (checkMime(fileModel.get(blocker.getCurIdx() - 2, "fileURL"))) return fileModel.get(blocker.getCurIdx() - 2, "fileURL")
        else if (checkMime(fileModel.get(blocker.getCurIdx() - 3, "fileURL"))) return fileModel.get(blocker.getCurIdx() - 3, "fileURL")
        else return "false"
    }

    function checkNext() {
        if (checkMime(fileModel.get(blocker.getCurIdx() + 1, "fileURL"))) return fileModel.get(blocker.getCurIdx() + 1, "fileURL")
        else if (checkMime(fileModel.get(blocker.getCurIdx() + 2, "fileURL"))) return fileModel.get(blocker.getCurIdx() + 2, "fileURL")
        else if (checkMime(fileModel.get(blocker.getCurIdx() + 3, "fileURL"))) return fileModel.get(blocker.getCurIdx() + 3, "fileURL")
        else return "false"
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.overlayBackgroundColor
        opacity: 0.6
    }

    Row {
        id: imgControls
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge
        //visible: !viewer.scaled
        IconButton {
            id: prevImg
            icon.source: "image://theme/icon-m-back"
            visible: (checkPrev() !== "false") ? true: false

            onClicked: {
                viewer.resetScale();
                viewer.active = false;
                viewer.source = checkPrev();
                viewer.active = true;
            }
        }
        Button {
            id: openImgExternally
            text: qsTr("Open externally")
            onClicked: {
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                mainWindow.infoBanner.showText(qsTr("Opening..."));
                Qt.openUrlExternally(viewer.source)
            }
        }
        IconButton {
            id: nextImg
            icon.source: "image://theme/icon-m-forward"
            visible: (checkNext() !== "false") ? true: false
            onClicked: {
                viewer.resetScale();
                viewer.active = false;
                viewer.source = checkNext();
                viewer.active = true;
            }
        }
    }
}
