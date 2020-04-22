# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-filecat

CONFIG += sailfishapp

SOURCES += src/harbour-filecat.cpp \
    src/folderlistmodel/fileinfothread.cpp \
    src/folderlistmodel/qquickfolderlistmodel.cpp

DISTFILES += qml/harbour-filecat.qml \
    qml/cover/CoverPage.qml \
    qml/pages/OpenDialog.qml \
    qml/pages/fmComponents/FileItemDelegate.qml \
    qml/pages/fmComponents/MultiSelectBar.qml \
    qml/pages/fmComponents/TextEditor.qml \
    qml/pages/fmComponents/imageViewerComponents/ImageControls.qml \
    qml/pages/fmComponents/mimetypeIcons.js \
    rpm/harbour-filecat.changes.in \
    rpm/harbour-filecat.changes.run.in \
    rpm/harbour-filecat.spec \
    rpm/harbour-filecat.yaml \
    translations/*.ts \
    harbour-filecat.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-filecat-de.ts \
translations/harbour-filecat-el.ts \
translations/harbour-filecat-es.ts \
translations/harbour-filecat-fr.ts \
translations/harbour-filecat-it.ts \
translations/harbour-filecat-nl_BE.ts \
translations/harbour-filecat-nl_NL.ts \
translations/harbour-filecat-pl.ts \
translations/harbour-filecat-ru.ts \
translations/harbour-filecat-sv.ts \
translations/harbour-filecat-zh_CN.ts

QT += dbus

HEADERS += \
    src/fileio.h \
    src/fmhelper.hpp \
    src/folderlistmodel/fileinfothread_p.h \
    src/folderlistmodel/fileproperty_p.h \
    src/folderlistmodel/qquickfolderlistmodel.h \
    src/videohelper.hpp

CONFIG += c++11
