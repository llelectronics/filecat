import QtQuick 2.0
import Sailfish.Silica 1.0
//import Sailfish.TransferEngine 1.0

Page {
    id: sharePage
    property alias filePath: shareMethodList.source

    SailfishTransferMethodsModel {
        id: transferMethodsModel
    }

    ShareMethodList {
        id: shareMethodList
        model: transferMethodsModel

        header: PageHeader {
            title: qsTr("Share")
        }
    }

}
