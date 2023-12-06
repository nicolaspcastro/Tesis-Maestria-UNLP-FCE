drop _all
clear all
set more off
macro drop _all

*#########################################################################################################################################*
*##########################################       0.1 MASTER      ########################################################################*
*#########################################################################################################################################*

*##########################################      CONFIGURACION    ########################################################################*

/* Globales de las rutas definidas de forma automática:

$path_user 		- Ubicación de la carpeta del Proyecto
$path_datain	- Bases de datos inputs (raw y que recibis procesadas)
$path_dataout	- Bases procesadas por tus scripts
$path_scripts	- Ubicacion de dofiles, py, ipynb, etc.
$path_figures	- Output para las figuras/gráficos
$path_maps		- Output para los mapas (html o imagen)
$path_tables	- Output para las tablas (imagen o excel)
*/

*###############################################    PATH       ###########################################################################*
* usar = 1 compu personal; usar = 2 compu mecon
loc usar = 2

if `usar' == 1 glo path 	"C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis"
if `usar' == 2 glo path 	"G:\Mi unidad\Facultad\Maestria\Tesis"

glo path_estim 				"${path}\Estimaciones"
glo path_scripts 			"${path_estim}\scripts"
glo path_datain 			"${path_estim}\data\data_in"
glo path_dataout 			"${path_estim}\data\data_out"
glo path_outputs			"${path_estim}\outputs"
glo path_tables 			"${path_outputs}\tables"

*cap mkdir "$path"

*############################################  EXPLICACIONES DEL CODIGO  #################################################################*

* ##### COMENTARIOS
	* MAYUSCULAS -->	Secciones

	* minusculas -->	Comentarios del codigo

* ##### DISPLAY
	* Verde 	-->		Comienzo de do file

	* Amarillo	-->		Codigo de apertura o guardado de base correcto

	* Rojo		-->		Codigo de apertura o guardado de base con error

* ##### ANCHORS
	* #NOTE 	-->		Notas sobre cosas a tener en cuenta que se hicieron en el codigo

	* #REVIEW 	-->		Cosas que hay que revisar

	* #TODO 	-->		Cosas que hay que faltan hacer


*#############################################     DO FILES  #############################################################################*
/*
ESTRUCTURA:
	1) Armado de bases: renombrar variables, labels, merge bases, creación, etc.

	2) Generación de descriptivas de base: 
		- cuadro crecimiento y desigualdad con regiones.
		-

	3) Estimaciones
*/

noi display in green "COMENZANDO DO FILE MASTER"

* 1) PREPARA BASE

include "$path_scripts\1.0.0 - master prepara base.do"

* 2) ESTIMACIONES
// include "$path_scripts\2.0.0 - master estimaciones.do"
