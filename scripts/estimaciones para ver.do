*******************************************************************************************************************************************************
************* ESTIMACIONES 25-09 ******************************
clear all
set more off


capture cd "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
capture cd "C:\Users\NICO\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
capture cd "C:\Users\Estadística 2\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
*if _rc!=0 cd "G:\Mi unidad\Tesistas\Nicolás Castro\Estimaciones"
loc path "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\outreg"

use base_tesis_reducida.dta


xtset nprov año

*PREGUNTA: Usar crecimiento promedio/100 para que quede un crec del 10 por ciento como 0.10

loc var_control "pbg_pc tasa_mort_inf"

loc estim " fe re"

loc crec_1 "crecimiento"

loc crec_2 "crec_ma_2 crec_mg_2"

loc crec_3 "crec_ma_3 crec_mg_3"

loc crec_4 "crec_ma_4 crec_mg_4"


loc aux "replace"

loc gini_1 "gini_cp g_l_1 ln_gini_cp ln_g_l_1"

loc gini_2 "g_i_2 g_i_l_2 g_p_2 g_p_l_2 ln_g_i_2 ln_g_i_l_2 ln_g_p_2 ln_g_p_l_2"

loc gini_3 "g_i_3 g_i_l_3 g_p_3 g_p_l_3 ln_g_i_3 ln_g_i_l_3 ln_g_p_3 ln_g_p_l_3"

loc gini_4 "g_i_4 g_i_l_4 g_p_4 g_p_l_4 ln_g_i_4 ln_g_i_l_4 ln_g_p_4 ln_g_p_l_4"




forv x=1/4 {

	foreach c in `crec_`x'' {
			
		foreach g in `gini_`x'' {
		
			foreach i in `estim' {
							
				xtreg `c' `g' if reg_`x'==1, `i' robust
				outreg2 using "`path'\e_`c'.xls", `aux' ctitle ("`c',`i'_sin_controles") st(coef pval) label 
				*sortvar(`g') 
				
				xtreg `c' `g' `var_control' if reg_`x'==1, `i' robust
				outreg2 using "`path'\e_`c'.xls", append ctitle ("`c',`i'_con_controles") st(coef pval) label 
				
			
				xtreg `c' `g' `var_control' if reg_`x'==1, `i' vce (cluster nreg)
				outreg2 using "`path'\e_`c'.xls", append ctitle ("`c',`i'_clu_nreg") st(coef pval) label 
			
				loc aux "append"	
			}
			loc aux "append"
		}
		loc aux "replace"
	}
	
}


********************hausman**************

mat HAUSMAN_RDOS=J(52,4,.)

mat colnames HAUSMAN_RDOS= "fe" "re" "hausman(chi2)" "hausman(p)"
*mat rownames HAUSMAN_RDOS= ""

loc fila=1
loc columna=1
			
forv x=1/4 {

			
	foreach c in `crec_`x'' {
		
		foreach g in `gini_`x'' {
			
			
			foreach i in `estim' {
				
				xtreg `c' `g' if reg_`x'==1, `i' 
				mat HAUSMAN_RDOS[`fila',`columna']=e(b)
				estimates store `i'_sc
				loc columna=`columna'+1
			}
			
			hausman fe_sc re_sc
			*si el valor de chi2 es grande, se rechaza la hipotesis nula --> se usa efectos fijos
			*si pv es menor a 0.05 se rechaza h0 --> efectos fijos
			mat HAUSMAN_RDOS[`fila',`columna']=r(chi2)
			loc columna=`columna'+1
			mat HAUSMAN_RDOS[`fila',`columna']=r(p)
			
			loc fila=`fila'+1
			loc columna=1
			
		}
		loc aux "append"
		*
	}
	loc aux "replace"
}

mat list HAUSMAN_RDOS

putexcel A1=mat(HAUSMAN_RDOS) using "`path'\hausman.xlsx", sheet(original) modify 


*******************************************************************************************************************************************************
************* ESTIMACIONES 25-09 ******************************
clear all
set more off


capture cd "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
capture cd "C:\Users\NICO\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
capture cd "C:\Users\Estadística 2\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
*if _rc!=0 cd "G:\Mi unidad\Tesistas\Nicolás Castro\Estimaciones"

use base_tesis_reducida.dta


xtset nprov año

*PREGUNTA: Usar crecimiento promedio/100 para que quede un crec del 10 por ciento como 0.10

loc var_control "pbg_pc_puig tasa_mort_inf"

loc estim " fe re"

loc crec_3 "crec_ma_3 crec_mg_3"

loc crec_4 " crec_ma_4 crec_mg_4"


loc aux "replace"

loc gini_3 "g_i_3 g_i_l_3 g_p_3 g_p_l_3 ln_g_i_3 ln_g_i_l_3 ln_g_p_3 ln_g_p_l_3"

loc gini_4 "g_i_4 g_i_l_4 g_p_4 g_p_l_4 ln_g_i_4 ln_g_i_l_4 ln_g_p_4 ln_g_p_l_4"

loc nombre=1

loc fila=1
loc me=1
mat crec_1=J(48,5,.)
mat colnames crec_1 = "Metod_Estim" "Coef" "SD" "Estad_t" "Hausman"
*mat rownames crec_1 = ""

foreach g in `gini_3' {	
			
			foreach i in `estim' {
			
							
				xtreg crec_ma_3 `g' if reg_3==1, `i' robust
				estimates store crec_1_`g'_`i'_sc
				mat coef_sc=e(b)
				mat varv_model_sc= e(V_modelbased) 
				mat crec_1[`fila',2]=coef_sc[1,1]
				mat crec_1[`fila',3]=coef_sc[1,1]/sqrt(varv_model_sc[1,1])
				mat crec_1[`fila',4]=crec_1[1,2]/crec_1[1,3]
				mat crec_1[`fila',1]=`me'
				loc fila=`fila'+1
				
				xtreg crec_ma_3 `g' `var_control' if reg_3==1, `i' robust
				estimates store crec_1_`g'_`i'_cc
				mat coef_cc=e(b)
				mat varv_model_cc= e(V_modelbased) 
				mat crec_1[`fila',2]=coef_cc[1,1]
				mat crec_1[`fila',3]=coef_cc[1,1]/sqrt(varv_model_cc[1,1])
				mat crec_1[`fila',4]=crec_1[1,2]/crec_1[1,3] 
				mat crec_1[`fila',1]=`me'+1
				loc fila=`fila'+1
				
				xtreg crec_ma_3 `g' `var_control' if reg_3==1, `i' vce (cluster nreg)
				estimates store crec_1_`g'_`i'
				mat coef_cl=e(b)
				mat varv_model_cl= e(V_modelbased) 
				mat crec_1[`fila',2]=coef_cl[1,1]
				mat crec_1[`fila',3]=coef_cl[1,1]/sqrt(varv_model_cl[1,1])
				mat crec_1[`fila',4]=crec_1[1,2]/crec_1[1,3]	 		
				mat crec_1[`fila',1]=`me'+2
				loc fila=`fila'+1
				loc me=`me'+3
			}
			
			loc me=1
			
		}
exit


foreach c in `crec_`x'' {

	forv x=3/4 {
		loc fila=1
		loc me=1
		mat crec_`nombre'=J(50,5,.)
		mat crec_`nombre' rownames "Met Estim Coef SD Estad_t Hausman"
		mat crec_`nombre' colnames "`gini_`x''"
		
		foreach g in `gini_`x'' {	
			
			foreach i in `estim' {
			
							
				xtreg `c' `g' if reg_`x'==1, `i' robust
				estimates store `c'_`g'_`i'_sc
				mat coef_`c'_`g'_`i'_sc=e(b)
				mat varv_model_`c'_`g'_`i'_sc= e(V_modelbased) 
				mat crec_`nombre'[`fila',2]=coef_`c'_`g'_`i'_sc[1,1]
				mat crec_`nombre'[`fila',3]=coef_`c'_`g'_`i'_sc[1,1]/sqrt(varv_model_`c'_`g'_`i'_sc[1,1])
				mat crec_`nombre'[`fila',4]=crec_`nombre'[1,1]/crec_`nombre'[1,2]
				mat crec_`nombre'[`fila',1]=`me'
				loc fila=`fila'+1
				
				xtreg `c' `g' `var_control' if reg_`x'==1, `i' robust
				estimates store `c'_`g'_`i'_cc
				mat coef_`c'_`g'_`i'_cc=e(b)
				mat varv_model_`c'_`g'_`i'_cc= e(V_modelbased) 
				mat crec_`nombre'[`fila',3]=coef_`c'_`g'_`i'_cc[1,1]
				mat crec_`nombre'[`fila',4]=coef_`c'_`g'_`i'_cc[1,1]/sqrt(varv_model_`c'_`g'_`i'_cc[1,1])
				mat crec_`nombre'[`fila',5]=crec_`nombre'[1,1]/crec_`nombre'[1,2] 
				mat crec_`nombre'[`fila',2]=`me'+1
				loc fila=`fila'+1
				
				xtreg `c' `g' `var_control' if reg_`x'==1, `i' vce (cluster nreg)
				estimates store `c'_`g'_`i'
				mat coef_`c'_`g'_`i'=e(b)
				mat varv_model_`c'_`g'_`i'= e(V_modelbased) 
				mat crec_`nombre'[`fila',3]=coef_`c'_`g'_`i'[1,1]
				mat crec_`nombre'[`fila',4]=coef_`c'_`g'_`i'[1,1]/sqrt(varv_model_`c'_`g'_`i'[1,1])
				mat crec_`nombre'[`fila',5]=crec_`nombre'[1,1]/crec_`nombre'[1,2]	 		
				mat crec_`nombre'[`fila',2]=`me'+2
				loc fila=`fila'+1
				loc me=`me'+3
			}
			loc fila=`fila'+1
			loc me=1
			
		}
			
			*
	}
	loc nombre=`nombre'+1
}


exit


mat coef=e(b)  
mat varv_model= e(V_modelbased) 
mat resultados[1,1]=coef[1,1]
mat resultados[1,2]=coef[1,1]/sqrt(varv_model[1,1])
mat resultados[1,3]=resultados[1,1]/resultados[1,2]
exit






*******************************************************************************************************************************************************


* Regresiones que van dando bien

xtreg crec_prom_2 gini_inicial_periodo pbg_pc_puig if reg==1, fe 

xtreg crec_prom_2 gini_inicial_per_lag if reg==1, fe

xtreg crec_prom_2 gini_inicial_per_lag pbg_pc_puig if reg==1, fe 

xtreg crec_prom_2 gini_prom if reg==1, fe

xtreg crec_prom_2 gini_prom pbg_pc_puig if reg==1, fe

xtreg crec_prom_2 gini_prom_lag  if reg==1, fe 

xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, fe

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re

xtreg  crec_prom_2  gini_prom if reg==1, re

xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, re

xtreg  crec_prom_2  gini_inicial_periodo pbg_pc_puig if reg==1, fe robust

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, fe robust

xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, fe robust

xtreg  crec_prom_2  gini_prom if reg==1, fe robust

xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, fe robust

xtreg  crec_prom_2  gini_prom_lag  if reg==1, fe robust

xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, fe robust

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re robust

xtreg  crec_prom_2  gini_prom if reg==1, re robust

xtreg  crec_prom_2  gini_prom_lag  if reg==1, re robust

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_prom if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_prom_lag  if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re vce (cluster nreg)






*******************************************************************************************************************************************************
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











*******************************************************************************************************************************************************
************* ESTIMACIONES 25-09 ******************************
clear all
set more off


capture cd "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
capture cd "C:\Users\NICO\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
capture cd "C:\Users\Estadística 2\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
*if _rc!=0 cd "G:\Mi unidad\Tesistas\Nicolás Castro\Estimaciones"
loc path "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\outreg"

use base_tesis_reducida.dta


xtset nprov año

xtreg var_ln_pbg_pc var_gini pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_ciclo.xls", replace ctitle ("vardep:var_ln_pbg_pc,varindep:var_gini") st(coef pval)  

xtreg var_ln_pbg_pc var_gini pbg_pc tasa_mort_inf, fe vce (cluster nprov)
outreg2 using "`path'\reg_ciclo.xls", append ctitle ("vardep:var_ln_pbg_pc,varindep:var_gini,cluster-nprov") st(coef pval)  

xtreg var_ln_pbg_pc var_gini pbg_pc tasa_mort_inf, fe vce (cluster nreg)
outreg2 using "`path'\reg_ciclo.xls", append ctitle ("vardep:var_ln_pbg_pc,varindep:var_gini,cluster-nprov") st(coef pval)  

tsfilter hp pbg_pc_ciclo=pbg_pc, trend (pbg_pc_tend)

xtreg pbg_pc_ciclo gini_cp, fe robust
outreg2 using "`path'\reg_ciclo.xls", append ctitle ("vardep:ciclo_pbg,varindep:gini") st(coef pval)  

xtreg pbg_pc_tend gini_cp, fe robust
outreg2 using "`path'\reg_ciclo.xls", append ctitle ("vardep:tendencia_pbg,varindep:gini") st(coef pval)  

xtreg pbg_pc_tend l.gini_cp, fe robust
outreg2 using "`path'\reg_ciclo.xls", append ctitle ("vardep:tendencia_pbg,varindep:gini_laggeado") st(coef pval)  

xtreg pbg_pc_tend l.l.gini_cp, fe robust
outreg2 using "`path'\reg_ciclo.xls", append ctitle ("vardep:tendencia_pbg,varindep:gini_laggeado_2_per") st(coef pval)  


* ver modelos ardl --> autregresive ditributed lag











*******************************************************************************************************************************************************
************* ESTIMACIONES 20-11 ******************************
clear all
set more off


capture cd "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
capture cd "C:\Users\NICO\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
capture cd "C:\Users\Estadística 2\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
*if _rc!=0 cd "G:\Mi unidad\Tesistas\Nicolás Castro\Estimaciones"
loc path "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\rdos_20-11"

use base_tesis_reducida.dta


xtset nprov año


/* 
Idea de hacer serie de regresiones en función de como fueron moviendose los papers en la literatura:
	- Arrancar con regresiones de ciclo y tendencia como recomendó Pablo.
	- Regresines cross-section: crecimiento promedio de todo el periodo de datos en gini inicial para todas las provincias.
	- Panel con distintos pediodos de 2 a 4. Elegir si usar gini al inicio o promedio y si del periodo o laggeado para bajar la cantidad de resultados.
	- IDEA ESTEBAN: Hacer lo mismo pero usando la variación de la tendencia solamente, no todo de todo el pbg
	-Paneles dinamicos? En Dominicis hay review de algúnos trabajos. Desde arellano-bond hasta otros que solucionan problema de eso. Mirar con Esteban
	
*/


* 1) ciclo y tendencia


xtreg pbg_pc_ciclo gini_cp, fe robust
*con xtreg o reg solo?
outreg2 using "`path'\reg_20-11.xls", replace ctitle ("vardep:ciclo_pbg") st(coef pval)  
outreg2 using "`path'\reg_5-12.xls", replace ctitle ("vardep:ciclo_pbg") st(coef pval)  


xtreg pbg_pc_tend gini_cp, fe robust
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:tend_pbg") st(coef pval)  
outreg2 using "`path'\reg_5-12.xls", append ctitle ("vardep:ciclo_pbg") st(coef pval)  

xtreg pbg_pc_tend l.gini_cp, fe robust

xtreg pbg_pc_tend l.l.gini_cp, fe robust


* 2) Cross-section
preserve
drop if año<1995 & año>2010
bysort nprov: egen crec_periodo=mean(var_ln_pbg_pc)


reg crec_periodo gini_cp if año==1995

reg crec_periodo gini_cp tasa_mort_inf if año==1995

reg crec_periodo gini_cp pbg_pc tasa_mort_inf if año==1995

reg crec_periodo gini_cp ln_pbg_pc tasa_mort_inf if año==1995
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec prom anual periodo") st(coef pval)  


sort nprov año
bysort nprov: gen aux_pbg=ln_pbg_pc[_n+15]


bysort nprov: gen crec_per2=(aux_pbg - ln_pbg_pc)/16

reg crec_per2 gini_cp if año==1995

reg crec_per2 gini_cp tasa_mort_inf if año==1995

reg crec_per2 gini_cp pbg_pc tasa_mort_inf if año==1995

reg crec_per2 gini_cp ln_pbg_pc tasa_mort_inf if año==1995
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec periodo / t") st(coef pval)  


restore


* 3)Datos en Panel. En literatura suelen usar periodos de 5 años, pero hasta que se pueda alargar la serie de gini usamos 4
*gini inicial del periodo
preserve

drop gini_cp

clonevar gini_cp=g_i_4

xtreg crec_ma_4 gini_cp pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec ma 4 años - g_inicial") st(coef pval)  

xtreg crec_ma_4 gini_cp pbg_pc tasa_mort_inf, fe vce (cluster nreg)
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec ma 4 años - g_inicial") st(coef pval)  


xtreg crec_mg_4 gini_cp pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec mg 4 años - g_inicial") st(coef pval)  

xtreg crec_mg_4 gini_cp pbg_pc tasa_mort_inf, fe vce (cluster nreg)
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec mg 4 años - g_inicial") st(coef pval)  

restore

*gini inciial periodo laggeado
preserve

drop gini_cp

clonevar gini_cp=g_i_l_4

xtreg crec_ma_4 gini_cp pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec ma 4 años - g_inicial_lag") st(coef pval)  

xtreg crec_ma_4 gini_cp pbg_pc tasa_mort_inf, fe vce (cluster nreg)
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec ma 4 años - g_inicial_lag") st(coef pval)  


xtreg crec_mg_4 gini_cp pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec mg 4 años - g_inicial_lag") st(coef pval)  

xtreg crec_mg_4 gini_cp pbg_pc tasa_mort_inf, fe vce (cluster nreg)
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec mg 4 años - g_inicial_lag") st(coef pval)  




restore

preserve 

bysort nprov: gen aux_pbg_pd=ln_pbg_pc[_n+3]


bysort nprov: gen crec_pd=(aux_pbg_pd - ln_pbg_pc)/4

drop gini_cp

clonevar gini_cp=g_i_4

xtreg crec_ma_4 gini_cp pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_20-11.xls", append ctitle ("vardep:crec dom g_inicial") st(coef pval)  


restore


*4) mismas regresiones que en (2) y (3) pero usando la tendencia dep pbg


* 4.1) Cross-section
preserve
drop if año<1995 & año>2010
bysort nprov: egen crec_periodo_tend=mean(var_ln_pbg_pc_tend)


reg crec_periodo_tend gini_cp if año==1995

reg crec_periodo_tend gini_cp tasa_mort_inf if año==1995

reg crec_periodo_tend gini_cp pbg_pc tasa_mort_inf if año==1995

reg crec_periodo_tend gini_cp ln_pbg_pc tasa_mort_inf if año==1995
outreg2 using "`path'\reg_5-12.xls", append ctitle ("vardep:crec prom anual tend periodo") st(coef pval)  


sort nprov año
bysort nprov: gen aux_pbg_tend=ln_pbg_pc_tend[_n+15]


bysort nprov: gen crec_per2_tend=(aux_pbg_tend - ln_pbg_pc_tend)/16

reg crec_per2_tend gini_cp if año==1995

reg crec_per2_tend gini_cp tasa_mort_inf if año==1995

reg crec_per2_tend gini_cp pbg_pc tasa_mort_inf if año==1995

reg crec_per2_tend gini_cp ln_pbg_pc tasa_mort_inf if año==1995
outreg2 using "`path'\reg_5-12.xls", append ctitle ("vardep:crec tend periodo / t") st(coef pval)  


restore


* 4.2)Datos en Panel. En literatura suelen usar periodos de 5 años, pero hasta que se pueda alargar la serie de gini usamos 4
*gini inicial del periodo
preserve

drop gini_cp

clonevar gini_cp=g_i_4

xtreg crec_tend_4 gini_cp pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_5-12.xls", append ctitle ("vardep:crec tend 4 años - g_inicial") st(coef pval)  

xtreg crec_tend_4 gini_cp pbg_pc tasa_mort_inf, fe vce (cluster nreg)
outreg2 using "`path'\reg_5-12.xls", append ctitle ("vardep:crec tend 4 años - g_inicial") st(coef pval)  



restore

*gini inciial periodo laggeado
preserve

drop gini_cp

clonevar gini_cp=g_i_l_4

xtreg crec_tend_4 gini_cp pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_5-12.xls", append ctitle ("vardep:crec tend 4 años - g_inicial_lag") st(coef pval)  

xtreg crec_tend_4 gini_cp pbg_pc tasa_mort_inf, fe vce (cluster nreg)
outreg2 using "`path'\reg_5-12.xls", append ctitle ("vardep:crec tend 4 años - g_inicial_lag") st(coef pval)  



restore

preserve 

bysort nprov: gen aux_pbg_pd_tend=ln_pbg_pc_tend[_n+3]


bysort nprov: gen crec_pd_tend=(aux_pbg_pd_tend - ln_pbg_pc_tend)/4

drop gini_cp

clonevar gini_cp=g_i_4

xtreg crec_tend_4 gini_cp pbg_pc tasa_mort_inf, fe robust
outreg2 using "`path'\reg_5-12.xls", append ctitle ("vardep:crec dom tend g_inicial") st(coef pval)  


restore


/*
by ncountry: replace crec3=(((rgdpopc [_n+`t_1']/(rgdpopc))^(1/`t_1'))-1) if time==1

sort ncountry periodo_`t' year
		by ncountry periodo_`t': egen m_crec2=mean(crec2)

*/












*******************************************************************************************************************************************************

