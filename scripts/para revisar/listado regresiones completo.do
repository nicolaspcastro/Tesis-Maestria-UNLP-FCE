clear all
set more off

cd "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis"

use base_tesis.dta

******REGRESIONES MONOGRAFIA*************
**************1- REGRESIONES COMUNES - SIN CONTROLES ************
*****************1.A- EFECTOS FIJOS *********************
*Comenzamos regresando el crecimiento promedio de cada periodo respecto al gini inicial del periodo
xtreg  crec_prom_2  gini_inicial_periodo if reg==1, fe 


*Le agregamos como control el producto inicial de ese periodo
xtreg  crec_prom_2  gini_inicial_periodo pbg_pc_puig if reg==1, fe 

*Ahora vovemos a hacer lo mismo pero utilizando el gini al inicio del periodo anterior
xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, fe

*nuevamente agregamos el pbg inicial del periodo t
xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, fe 

*Ahora usamos como variable explicativa el gini promedio del periodo, no el inicial.
xtreg  crec_prom_2  gini_prom if reg==1, fe

*agregamos pbg inicial
xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, fe

*Ahora utilizamos el gini promedio del periodo anterior
xtreg  crec_prom_2  gini_prom_lag  if reg==1, fe 

*agramos producto al inicio
xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, fe

*******************************************************************
exit


*****************1.B- EFECTOS ALEATORIOS *********************
*Comenzamos regresando el crecimiento promedio de cada periodo respecto al gini inicial del periodo
xtreg  crec_prom_2  gini_inicial_periodo if reg==1, re 

*Le agregamos como control el producto inicial de ese periodo
xtreg  crec_prom_2  gini_inicial_periodo pbg_pc_puig if reg==1, re 

*Ahora vovemos a hacer lo mismo pero utilizando el gini al inicio del periodo anterior
xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re

*nuevamente agregamos el pbg inicial del periodo t
xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, re 

*Ahora usamos como variable explicativa el gini promedio del periodo, no el inicial.
xtreg  crec_prom_2  gini_prom if reg==1, re

*agregamos pbg inicial
xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, re

*Ahora utilizamos el gini promedio del periodo anterior
xtreg  crec_prom_2  gini_prom_lag  if reg==1, re 

*agramos producto al inicio
xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, re


************************************************************
************************************************************

**************2- ROBUST - CONTROLAMOS POR************
****************2.A-EFECTOS FIJOS*******************

*Comenzamos regresando el crecimiento promedio de cada periodo respecto al gini inicial del periodo
xtreg  crec_prom_2  gini_inicial_periodo if reg==1, fe robust

*Le agregamos como control el producto inicial de ese periodo
xtreg  crec_prom_2  gini_inicial_periodo pbg_pc_puig if reg==1, fe robust

*Ahora vovemos a hacer lo mismo pero utilizando el gini al inicio del periodo anterior
xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, fe robust

*nuevamente agregamos el pbg inicial del periodo t
xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, fe robust

*Ahora usamos como variable explicativa el gini promedio del periodo, no el inicial.
xtreg  crec_prom_2  gini_prom if reg==1, fe robust

*agregamos pbg inicial
xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, fe robust

*Ahora utilizamos el gini promedio del periodo anterior
xtreg  crec_prom_2  gini_prom_lag  if reg==1, fe robust

*agramos producto al inicio
xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, fe robust


*******************************************************************

****************2.B-EFECTOS ALEATORIOS*******************

*Comenzamos regresando el crecimiento promedio de cada periodo respecto al gini inicial del periodo
xtreg  crec_prom_2  gini_inicial_periodo if reg==1, re robust

*Le agregamos como control el producto inicial de ese periodo
xtreg  crec_prom_2  gini_inicial_periodo pbg_pc_puig if reg==1, re robust

*Ahora vovemos a hacer lo mismo pero utilizando el gini al inicio del periodo anterior
xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re robust

*nuevamente agregamos el pbg inicial del periodo t
xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, re robust

*Ahora usamos como variable explicativa el gini promedio del periodo, no el inicial.
xtreg  crec_prom_2  gini_prom if reg==1, re robust

*agregamos pbg inicial
xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, re robust

*Ahora utilizamos el gini promedio del periodo anterior
xtreg  crec_prom_2  gini_prom_lag  if reg==1, re robust

*agramos producto al inicio
xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, re robust


****************************************************************
****************************************************************


**************3- VCE - CONTROLAMOS POR************
*****************3.A - EFECTOS FIJOS**************
*Comenzamos regresando el crecimiento promedio de cada periodo respecto al gini inicial del periodo
xtreg  crec_prom_2  gini_inicial_periodo if reg==1, fe vce (cluster nreg)

*Le agregamos como control el producto inicial de ese periodo
xtreg  crec_prom_2  gini_inicial_periodo pbg_pc_puig if reg==1, fe vce (cluster nreg)

*Ahora vovemos a hacer lo mismo pero utilizando el gini al inicio del periodo anterior
xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, fe vce (cluster nreg)

*nuevamente agregamos el pbg inicial del periodo t
xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, fe vce (cluster nreg)

*Ahora usamos como variable explicativa el gini promedio del periodo, no el inicial.
xtreg  crec_prom_2  gini_prom if reg==1, fe vce (cluster nreg)

*agregamos pbg inicial
xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, fe vce (cluster nreg)

*Ahora utilizamos el gini promedio del periodo anterior
xtreg  crec_prom_2  gini_prom_lag  if reg==1, fe vce (cluster nreg)

*agramos producto al inicio
xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, fe vce (cluster nreg)

*******************************************************************

*****************3.B - EFECTOS ALEATORIOS**************
*Comenzamos regresando el crecimiento promedio de cada periodo respecto al gini inicial del periodo
xtreg  crec_prom_2  gini_inicial_periodo if reg==1, re vce (cluster nreg)

*Le agregamos como control el producto inicial de ese periodo
xtreg  crec_prom_2  gini_inicial_periodo pbg_pc_puig if reg==1, re vce (cluster nreg)

*Ahora vovemos a hacer lo mismo pero utilizando el gini al inicio del periodo anterior
xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re vce (cluster nreg)

*nuevamente agregamos el pbg inicial del periodo t
xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, re vce (cluster nreg)

*Ahora usamos como variable explicativa el gini promedio del periodo, no el inicial.
xtreg  crec_prom_2  gini_prom if reg==1, re vce (cluster nreg)

*agregamos pbg inicial
xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, re vce (cluster nreg)

*Ahora utilizamos el gini promedio del periodo anterior
xtreg  crec_prom_2  gini_prom_lag  if reg==1, re vce (cluster nreg)

*agregamos producto al inicio
xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, fe vce (cluster nreg)

