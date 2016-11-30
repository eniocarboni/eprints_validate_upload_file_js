EPrints Plugins to check upload file directly with javascript (size and virus free)
=================================================================================
This plugin add function to check upload file maxsize and virus free during the upload workflow checking directly with javascript if possible or through the classic validation of eprints
The modified js 88_uploadmethod_file.js allows you to upload multiple files either by drag & drop or via browser window

Requirements
------------

In order to use the plugin you need the clamAV antivirus (http://www.clamav.net/)

Installation
------------

copy the file in the archive id:

cp cfg/cfg.d/upload.pl $EPRINTSHOME/archives/<archiveid>/cfg/cfg.d/
cp cfg/cfg.d/document_validate.pl $EPRINTSHOME/archives/<archiveid>/cfg/cfg.d/
mkdir -p $EPRINTSHOME/archives/<archiveid>/cfg/lang/{en,it}
cp cfg/lang/en/phrases/validate_upload_file.xml $EPRINTSHOME/archives/<archiveid>/cfg/lang/en/phrases/
cp cfg/lang/it/phrases/validate_upload_file.xml $EPRINTSHOME/archives/<archiveid>/cfg/lang/it/phrases/
cp cfg/static/javascript/auto/88_uploadmethod_file.js $EPRINTSHOME/archives/<archiveid>/cfg/static/javascript/auto/
mkdir -p $EPRINTSHOME/archives/<archiveid>/cgi/users/ajax
cp cgi/users/ajax/upload_validation $EPRINTSHOME/archives/<archiveid>/cgi/users/ajax/

reload apache

Configuration
-------------
Configure cfg/cfg.d/upload.pl and cfg/cfg.d/document_validate.pl
