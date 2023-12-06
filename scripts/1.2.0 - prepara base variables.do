****************************************************************************************************************************************
*                                               PREPERACIÓN DE BASES DE VARIABLES PARA BASE FINAL
****************************************************************************************************************************************
set more off

noi display in green "COMENZANDO DO FILE PREPARA BASE VARIABLES"

* CALCULO DE COEFICIENTE DE GINI:
*include "$path_scripts\1.2.1 - calculo gini.do"

* CALCULO DE OTRAS VARIABLES QUE SALEN DE EPH PARA USAR DE CONTROL (DESEMPLEO, POBREZA, ETC.)
*include "$path_scripts\1.2.2 - calculo otras variables eph.do"

* MERGE BASES DE CALCULOS QUE SALEN DE DO FILES ANTERIORES
*include "$path_scripts\1.2.3 - merge indicadores eph.do"

* IMPORTO BASES PARA PBG Y REALIZO DISTINTOS CALCULOS
*include "$path_scripts\1.2.4 - calculo pbg.do"

* IMPORTO BASES CON RESTO DE VARIABLES DE CONTROL
*include "$path_scripts\1.2.5 - calculo resto variables.do"


