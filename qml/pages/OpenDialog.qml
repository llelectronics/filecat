import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.filecat.FolderListModel 1.0
import Nemo.Configuration 1.0
import "fmComponents"

Page {
    id: page
    allowedOrientations: Orientation.All

    property bool multiSelect: selectMode ? true : false
    property bool selectMode: false
    property bool onlyFolders: false
    property bool hiddenShow: false
    property string path:  _fm.getHome()
    property variant filter: [ "*" ]

    property string lastSavedDir: mainWindow.lastKnownDir

    // Sorting
    property string sortType: qsTr("Name")
    property int _sortField: FolderListModel.Name
    //

    property bool _loaded: false

    property QtObject dataContainer
    property QtObject imgView

    signal fileOpen(string path);

   property var customPlaces: [
//       {
//           name: qsTr("Android Storage"),
//           path: _fm.getHome() + "/android_storage",
//           icon: "image://theme/icon-m-folder"
//       }
   ]


    ConfigurationGroup {
        id: customPlacesSettings
        path: "/apps/harbour-llsfileman" // DO NOT CHANGE to share custom places between apps
    }

    onCustomPlacesChanged: {
        saveCustomPlaces();
    }

    onPathChanged: {
        openFile(path);
        if (imgView) imgView.destroy();
    }

    onStatusChanged: {
        if (status == PageStatus.Active && !_loaded) {
            pageStack.pushAttached(Qt.resolvedUrl("fmComponents/PlacesPage.qml"),
                                   { "father": page })
            _loaded = true
        }
    }

    function refresh() {
        var oPath = path
        path = ""
        path = oPath
    }

    function openFile(path) {
        if (_fm.isFile(path)) {

            var mime = _fm.getMime(path);
            console.debug("[OpenDialog] Detected mimetype: " + mime);
            var mimeinfo = mime.toString().split("/");

            if(mimeinfo[0] === "video" || mimeinfo[0] === "audio")
            {
                mainWindow.openWithvPlayer(path,mainWindow.findBaseName(path));
                if (mainWindow.vPlayerExternal) {
                    mainWindow.infoBanner.parent = page
                    mainWindow.infoBanner.anchors.top = page.top
                    mainWindow.infoBanner.showText(qsTr("Opening..."))
                }
                return;
            }
            else if ((mimeinfo[0] === "text")) {
                pageStack.push("fmComponents/TextEditor.qml", { "fileName" : path },  PageStackAction.Animated);
            }
            else if (mimeinfo[0] === "image") {
                imgView = compoImgViewer.createObject (overlay, {
                                                 "source" : path,
                                             });
            } else {
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                mainWindow.infoBanner.showText(qsTr("Opening..."));
                Qt.openUrlExternally(path);
            }
        }
    }

    function saveCustomPlaces() {
        var customPlacesJson = JSON.stringify(customPlaces);
        //console.debug(customPlacesJson);
        customPlacesSettings.setValue("places",customPlacesJson);
    }

    FolderListModel {
        id: fileModel
        folder: path
        showDirsFirst: true
        showDotAndDotDot: false
        showOnlyReadable: true
        nameFilters: filter
        sortField: _sortField
    }

    // WORKAROUND showHidden buggy not refreshing
    FolderListModel {
        id: fileModelHidden
        folder: path
        showDirsFirst: true
        showDotAndDotDot: false
        showOnlyReadable: true
        nameFilters: filter
        sortField: _sortField
    }

    function humanSize(bytes) {
        var precision = 2;
        var kilobyte = 1024;
        var megabyte = kilobyte * 1024;
        var gigabyte = megabyte * 1024;
        var terabyte = gigabyte * 1024;

        if ((bytes >= 0) && (bytes < kilobyte)) {
            return bytes + ' B';

        } else if ((bytes >= kilobyte) && (bytes < megabyte)) {
            return (bytes / kilobyte).toFixed(precision) + ' KB';

        } else if ((bytes >= megabyte) && (bytes < gigabyte)) {
            return (bytes / megabyte).toFixed(precision) + ' MB';

        } else if ((bytes >= gigabyte) && (bytes < terabyte)) {
            return (bytes / gigabyte).toFixed(precision) + ' GB';

        } else if (bytes >= terabyte) {
            return (bytes / terabyte).toFixed(precision) + ' TB';

        } else {
            return bytes + ' B';
        }
    }

    function findBaseName(url) {
        var fileName = url.substring(url.lastIndexOf('/') + 1);
        return fileName;
    }

    function findFullPath(url) {
        url = url.toString();
        var fullPath = url.substring(url.lastIndexOf('://') + 3);
        return fullPath;
    }

    function updateSortType() {
        if (_sortField === FolderListModel.Name) sortType = qsTr("Name")
        else if (_sortField === FolderListModel.Time) sortType = qsTr("Time")
        else if (_sortField === FolderListModel.Size) sortType = qsTr("Size")
        else if (_sortField === FolderListModel.Type) sortType = qsTr("Type")
    }

    SilicaListView {
        id: view
        model: fileModel
        width: parent.width
        height: multiSelectBar.open ? parent.height - multiSelectBar.height : parent.height

        header: PageHeader {
            title: findBaseName((path).toString())
            description: hiddenShow ? path + " [.*]" : path
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!hiddenShow) {
                        view.model = fileModelHidden
                        view.model.showHidden = true
                    }
                    else {
                        view.model = fileModel
                        view.model.showHidden = false
                    }
                    hiddenShow = !hiddenShow
                    showHiddenIndicator.start()
                }
                onPressAndHold: {
                    mainWindow.lastKnownDir = fileModel.folder
                    lastSavedDir = fileModel.folder
                    infoBanner.parent = page
                    infoBanner.anchors.top = page.top
                    infoBanner.showText(qsTr("Saved directory to last known"))
                }
            }
            BackgroundItem {
                anchors.left: extraContent.left
                anchors.top: extraContent.top
                visible: lastSavedDir !== ""
                Label {
                    text: "\u21B7"
                    font.pixelSize: Theme.fontSizeHuge
                }
                onClicked: {
                    var anotherFM = pageStack.push(Qt.resolvedUrl("OpenDialog.qml"), {"path": lastSavedDir, "_sortField": _sortField, "dataContainer": dataContainer, "selectMode": selectMode, "multiSelect": multiSelect, "lastSavedDir": ""});
                    anotherFM.fileOpen.connect(fileOpen)
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Create Folder")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("fmComponents/CreateDirDialog.qml"),
                                                { "path": findFullPath(fileModel.folder.toString()) })
                    dialog.accepted.connect(function() {
                        if (dialog.errorMessage !== "") {
                            console.debug(dialog.errorMessage)
                            infoBanner.parent = page
                            infoBanner.anchors.top = page.top
                            infoBanner.showText(dialog.errorMessage)
                        }
                    })
                }
            }
//            MenuItem {
//                text: qsTr("Show Filesystem Root")
//                onClicked: fileModel.folder = _fm.getRoot();
//            }
//            MenuItem {
//                text: qsTr("Show Home")
//                onClicked: fileModel.folder = _fm.getHome();
//            }
//            MenuItem {
//                text: qsTr("Show Android SDCard")
//                onClicked: fileModel.folder = _fm.getHome() + "/android_storage";
//            }
            MenuItem {
                text: qsTr("Sort by: ") + sortType
                onClicked: {
                    if (_sortField === FolderListModel.Name) _sortField = FolderListModel.Time
                    else if (_sortField === FolderListModel.Time) _sortField = FolderListModel.Size
                    else if (_sortField === FolderListModel.Size) _sortField = FolderListModel.Type
                    else if (_sortField === FolderListModel.Type) _sortField = FolderListModel.Name
                    updateSortType();
                }
            }
            MenuItem {
                text: qsTr("Add to places")
                onClicked: {
                    customPlaces.push(
                                {
                                    name: findBaseName(path),
                                    path: findFullPath(fileModel.folder.toString()),
                                    icon: "image://theme/icon-m-folder"
                                }
                                )
                    customPlacesChanged()
                }
                visible: findFullPath(fileModel.folder.toString()) !== _fm.getHome()
            }

            MenuItem {
                id: pasteMenuEntry
                visible: { if (_fm.sourceUrl != "" && _fm.sourceUrl != undefined) return true;
                    else return false
                }
                text: qsTr("Paste") + "(" + findBaseName(_fm.sourceUrl) + ")"
                onClicked: {
                    busyInd.running = true
                    _fm.resetWatcher();
                    for (var i=0; i<clipboard.count; i++) {
                        console.log("Copying " + clipboard.get(i).source + " to " + findFullPath(fileModel.folder) + "/" + clipboard.get(i).name);
                        _fm.copyFile(clipboard.get(i).source,findFullPath(fileModel.folder) + "/" + clipboard.get(i).name)
                    }
                    clipboard.clear();
                    refresh();
                }
            }
            MenuItem {
                text: qsTr("Properties")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("fmComponents/FileProperties.qml"),
                                          {"path": findFullPath(fileModel.folder), dataContainer: dataContainer, "fileIcon": "image://theme/icon-m-folder", "fileSize": "4k",
                                           "fileModified": fileModel.fileModified, "fileIsDir": true, "father": page})
                    //console.debug("Path: " + findFullPath(fileModel.folder))
                }
            }
        }
        delegate: FileItemDelegate { id: bgdelegate }
        VerticalScrollDecorator { flickable: view }
    }
    Component.onCompleted: {
        updateSortType()
    }

    Connections {
        target: _fm
        onSourceUrlChanged: {
            if (_fm.sourceUrl != "" && _fm.sourceUrl != undefined) {
                pasteMenuEntry.visible = true;
            }
            else pasteMenuEntry.visible = false;
        }
        onCpResultChanged: {
            if (!_fm.cpResult) {
                var message = qsTr("Error pasting file ") + _fm.sourceUrl
                console.debug(message);
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                infoBanner.showText(message)
            }
            else {
                _fm.sourceUrl = "";
                var message = qsTr("File operation succeeded")
                console.debug(message);
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                infoBanner.showText(message)
            }
            busyInd.running = false;
        }
        onRmResultChanged: {
            console.log("rmResult: " + _fm.rmResult);
            if (!_fm.rmResult) {
                var message = qsTr("Error deleting file(s)")
                console.debug(message);
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                infoBanner.showText(message)
            }
            else {
                var message = qsTr("File deletion succeeded")
                console.debug(message);
                mainWindow.infoBanner.parent = page
                mainWindow.infoBanner.anchors.top = page.top
                infoBanner.showText(message)
            }
            busyInd.running = false;
        }
    }

    BusyIndicator {
        id: busyInd
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
    }

    Item {
        id: hiddenIndicator

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 4 * Theme.paddingLarge
        opacity: 0
        property alias fadeOut: fadeOut

        NumberAnimation on opacity {
            id: fadeOut
            to: 0
            duration: 500
            easing.type: Easing.InOutCubic
        }

        Rectangle {
            width: hiddenblIndicator.width + 2 * Theme.paddingMedium
            height: hiddenblIndicator.height + 2 * Theme.paddingMedium
            color: isLightTheme? "white" : "black"
            opacity: 0.4
            anchors.centerIn: parent

        }
        Label {
            id: hiddenblIndicator
            font.pixelSize: Theme.fontSizeSmall
            anchors.centerIn: parent
            text: hiddenShow ? qsTr("Show hidden files") : qsTr("Hide hidden files")
            color: Theme.primaryColor
        }
    }

    Timer {
        id: showHiddenIndicator
        interval: 1000
        property int count: 0
        triggeredOnStart: true
        repeat: true
        onTriggered: {
            ++count
            if (count >= 2) {
                hiddenIndicator.fadeOut.start()
                count = 0;
                stop();
            }
            else {
                hiddenIndicator.opacity = 1.0
            }
        }
    }

    Component {
            id: compoImgViewer;

            TouchBlocker {
                id: blocker;
                anchors.fill: parent;

                property alias source : imgViewer.source;

                Rectangle {
                    color: Qt.rgba (1.0 - Theme.primaryColor.r, 1.0 - Theme.primaryColor.g, 1.0 - Theme.primaryColor.b, 0.85);
                    anchors.fill: parent;
                }
                ImageViewer {
                    id: imgViewer;
                    source: "";
                    active: true;
                    anchors.fill: parent;
                    onClicked: {
                        blocker.destroy ();
                    }

                    property var root : mainWindow; // NOTE : to avoid QML warnings because it' baldy coded...
                }
            }
        }

    Item {
        id: overlay;
        anchors.fill: page;
    }

    MultiSelectBar {
        id: multiSelectBar
        open: multiSelect
    }

    RemorsePopup {
        id: remorseRemove
    }

}
