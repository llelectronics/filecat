#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QTextStream>

class FileIO : public QObject
{
    Q_OBJECT

public slots:
    QString txtData() {return _txtData;}
    void read(const QString& source)
    {
        if (source.isEmpty())
            _txtData = "Error reading file";

        QFile file(source);
        if (!file.open(QFile::ReadOnly))
            _txtData = "File can't be opened";

        QString line;
        QTextStream stream(&file);
        _txtData = "";
        while (!stream.atEnd()){
            line = stream.readLine();
            _txtData += line+"\n";
        }
        emit txtDataChanged();
        file.close();
    }
    bool write(const QString& source, const QString& data)
    {
        if (source.isEmpty())
            return false;

        QFile file(source);
        if (!file.open(QFile::WriteOnly | QFile::Truncate))
            return false;

        QTextStream out(&file);
        out << data;
        file.close();
        return true;
    }

Q_SIGNALS:
    // The change notification signals of the properties
    void txtDataChanged();

private:
    QString _txtData;

public:
    FileIO() {}
};

#endif // FILEIO_H
