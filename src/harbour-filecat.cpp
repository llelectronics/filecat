#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include "fmhelper.hpp"
#include "folderlistmodel/qquickfolderlistmodel.h"
#include "videohelper.hpp"
#include "fileio.h"

#include <QQuickView>
#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>

int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/harbour-filecat.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //   - SailfishApp::pathToMainQml() to get a QUrl to the main QML file
    //
    // To display the view, call "show()" (will show fullscreen on device).
    QGuiApplication *app = SailfishApp::application(argc, argv);

    qmlRegisterType<QQuickFolderListModel>("harbour.filecat.FolderListModel", 1, 0, "FolderListModel");

    app->setApplicationVersion("1.0.0");
    QQuickView *view = SailfishApp::createView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);

    //QObject *object = view->rootObject(); // unused for now

    videoHelper *vHelper = new videoHelper();
    view->engine()->rootContext()->setContextProperty("_videoHelper", vHelper);

    FM *fileAction = new FM();
    view->engine()->rootContext()->setContextProperty("_fm", fileAction);

    FileIO fileIO;
    view->engine()->rootContext()->setContextProperty("_fileio", &fileIO);

    view->setSource(SailfishApp::pathTo("qml/harbour-filecat.qml"));

    view->showFullScreen();

    return app->exec();
}
