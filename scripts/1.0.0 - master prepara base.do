****************************************************************************************************************************************
*                                                       MASTER PREPARA BASES
****************************************************************************************************************************************

* CREACIÓN DE GLOBALES PRINCIPALES
glo año_continua = "03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21"
glo año_puntual = "95 96 97 98 99 00 01 02 03 04 05 06"
glo trimestre = "1 2 3 4"
glo semestre = "1 2"
glo onda = "1 3"
glo bases = "Individual Hogar"
glo bases_gini = "m indec"
glo año_excel = "16 17 18 19 20 21"

do "$path_scripts/comandos/comandos"

noi display in green "COMENZANDO DO FILE MASTER PREPARA BASE"

* COSNTRUCCIÓN BASE EPH INDEC A SEMESTRAL CON VARIABLES CEDLAS Y OTRAS:
*include "$path_scripts\1.1.0 - prepara base eph.do"

* CREACIÓN DE BASES CON VARIABLES PARA BASE FINAL (GINI, PBG, ETC.)
*include "$path_scripts\1.2.0 - prepara base variables.do"

* MERGE DISTINTAS BASES Y CREACIÓN DE VARIABLES EXTRAS PARA BASE FINAL
include "$path_scripts\1.3.0 - prepara base final.do"


