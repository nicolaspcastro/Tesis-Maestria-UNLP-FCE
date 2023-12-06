
#!/usr/bin/env python

import zipfile

zipfilename = "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\data\data_in\EPH\Bases Originales\EPH INDEC\Bases en Otros formatos\EPHP - 1991 - 2006\1991-1994\1991\DEM17191.zip"
password = None

# open and extract all files in the zip
z = zipfile.ZipFile(zipfilename, "r")
try:
    z.extractall(pwd=password)
except:
    print('Error')
    pass
zf.close()