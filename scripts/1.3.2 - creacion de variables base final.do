****************************************************************************************************************************************
*														PREPARA BASE FINAL
*	
*				CALCULO DE VARIACIONES, VARIABLES POR REGION, LOGARITMOS, ETC.
*
****************************************************************************************************************************************

drop _all

use "${path_dataout}\base_tesis_completa.dta", replace

* dropeo variables que no pertenecen a las provincias
capture drop if nprov>24

* me quedo con las variables que quiero usar

* variables de provincia y año
loc var_prov = "año nprov prov nreg region pampeana cuyo noa nea patagonia"

* #NOTE - ME QUEDO CON LAS PBG USANDO IPI, EXPO USANDO IPI EXPO Y LAS DE SALARIO USANDO IPC
* variables de pbg
* PARA USAR TODAS IPC/IPI loc var_pbg = "pbg_cepal_ipi pbg_cepal_ipc pbg_isap_tromb_ipi pbg_isap_tromb_ipc pbg_isap_trajt_ipi pbg_isap_trajt_ipc var_pbg_isap_tromb_ipi var_pbg_isap_tromb_ipc var_pbg_isap_trajt_ipi var_pbg_isap_trajt_ipc var_pbg_cepal_ipi var_pbg_cepal_ipc isap_tromb isap_trajt var_isap_tromb var_isap_trajt pbi_ipi pbi_ipc pbi_pbg_isap_trajt_ipi pbi_pbg_isap_trajt_ipc pbi_pbg_cepal_ipi pbi_pbg_cepal_ipc"
loc var_pbg = "pbg_cepal_ipi pbg_isap_tromb_ipi pbg_isap_trajt_ipi isap_tromb isap_trajt pbi_ipi pbi_pbg_isap_tromb_ipi pbi_pbg_isap_trajt_ipi pbi_pbg_cepal_ipi"

* variables de desigualdad
*loc var_desig = "gini_m_sa gini_indec_sa gini_m_ca gini_indec_ca"
loc var_desig = "gini_m_ca"

* variables de exportaciones
loc var_expo = "expo_pp_ipi_expo expo_moa_ipi_expo expo_moi_ipi_expo expo_cye_ipi_expo expo_total_ipi_expo"

* variables de deflactores
loc var_def = "tcn ipc_bcra ipi ipi_expo"

* variables control
loc var_control = "poblacion poblacion_eph  poblacion_alt_eph superficie_km_2 densidad tasa_mort_inf rbpm_sipa_ipi rbpm_sipa_ipc idh ptspf_sipa"

keep `var_prov' `var_pbg' `var_desig' `var_expo' `var_def' `var_control'

* Renombro variables
rename (*_ipi expo_*_ipi_expo gini*) (* expo_* gini)
rename (pbg_isap_tromb pbg_isap_trajt pbi_pbg_isap_tromb pbi_pbg_isap_trajt) (pbg_tromb pbg_trajt pbi_pbg_tromb pbi_pbg_trajt)

* calculo de variables pc (los pbg los paso a pesos, porque estaban en millones)

loc var_pc = "pbg_cepal pbg_tromb pbg_trajt pbi pbi_pbg_tromb pbi_pbg_trajt pbi_pbg_cepal expo_pp expo_moa expo_moi expo_cye expo_total"

foreach var in `var_pc' {
	
	gen `var'_pc = `var' * 1000000 / poblacion
}

* creo variables de ciclo y tendencia para el pbg, y la variación de la tendencia
loc var_pbg_cyt = "cepal trajt tromb"

foreach var in `var_pbg_cyt' {

	tsfilter hp pbg_`var'_pc_ciclo_2 = pbg_`var'_pc, trend (pbg_`var'_pc_tend_2)
	tsfilter hp pbg_`var'_pc_ciclo = pbg_`var'_pc, trend (pbg_`var'_pc_tend) smooth(6.25)
	* chequear que este ok usar el smooth de 6.25
}
display "`r(smooth)'"
exit
* calculo de variables en logaritmo
loc var_log = "pbg_cepal_pc pbg_tromb_pc pbg_trajt_pc pbi_pc pbi_pbg_tromb_pc pbi_pbg_trajt_pc pbi_pbg_cepal_pc pbg_cepal_pc_ciclo pbg_trajt_pc_ciclo pbg_tromb_pc_ciclo pbg_cepal_pc_tend pbg_trajt_pc_tend pbg_tromb_pc_tend expo_pp expo_moa expo_moi expo_cye expo_total gini tasa_mort_inf rbpm_sipa idh ptspf_sipa"
loc var_log_log = ""

foreach var in `var_log' {
	
	sort nprov año
	bysort nprov: gen ln_`var' = ln(`var') 
	loc var_log_log = "`var_log_log' ln_`var'"
}


* calculo de variación de variables
loc var_var = "`var_log_log' pbg_cepal pbg_tromb pbg_trajt pbi pbi_pbg_tromb pbi_pbg_trajt pbi_pbg_cepal pbg_cepal_pc pbg_tromb_pc pbg_trajt_pc pbi_pc pbi_pbg_tromb_pc pbi_pbg_trajt_pc pbi_pbg_cepal_pc pbg_cepal_pc_ciclo pbg_trajt_pc_ciclo pbg_tromb_pc_ciclo pbg_cepal_pc_tend pbg_trajt_pc_tend pbg_tromb_pc_tend expo_pp expo_moa expo_moi expo_cye expo_total gini tcn ipc_bcra ipi ipi_expo poblacion densidad tasa_mort_inf rbpm_sipa idh ptspf_sipa"

foreach var in `var_var' {
	
	sort nprov año
	bysort nprov: gen var_`var' = (`var'/`var'[_n-1] - 1) * 100 
}


* calculo todas las variables como suma o promedio por region
* #NOTE - INCLUYO EL GINI, PERO ESO HABRÍA QUE MODIFICARLO Y CALCULARLO EN EL DO FILE DE CALCULO GINI

loc var_reg_sum 	= "pbg_cepal pbg_tromb pbg_trajt expo_pp expo_moa expo_moi expo_cye expo_total poblacion ptspf_sipa"
loc var_reg_mean 	= "gini tasa_mort_inf rbpm_sipa idh"

foreach var in `var_reg_sum' {
	
	sort nreg año
	bysort nreg: egen `var'_reg_sum = sum(`var') 
}
foreach var in `var_reg_mean' {
	
	sort nreg año
	bysort nreg: egen `var'_reg_mean = mean(`var') 
}

*calculo expo anual como porcentaje del total nacional
sort año
by año: egen expo_tot_arg_año=sum(expo_total) 

gen part_expo_total=expo_total/expo_tot_arg_año*100


* pongo la tasa de mort inf de 1996 en 1995 #REVIEW - ver si hay una mejor forma de hacerlo
// sort nprov año
// clonevar mort_inf_2=tasa_mort_inf
// replace mort_inf_2=tasa_mort_inf[_n+1]
// replace tasa_mort_inf=mort_inf_2 if año==1995
// drop mort_inf_2

* periodos 
* # NOTE - Periodos: pbg_cepal: 2004-2021; pbg_trajt: 1997-2019; pbg_tromb: 1997-2016
*			pbg_cepal: p_5 = 3; p_4 = 4; 						p_3 = 6; 				p_2 = 9
*			pbg_trajt: 			p_5 = 4; 			p_4 = 5; 				p_3 = 7; 							p_2 = 11
*			pbg_tromb: 			p_5 = 4; 			p_4 = 5; 	p_3 = 6; 							p_2 = 10

* armo los periodos en un bucle, en función de la variable que quiero calcular

loc var_per = "cepal tromb trajt"

loc ini_cepal = 2004
loc ini_trajt = 1997
loc ini_tromb = 1997

loc fin_cepal = 2021
loc fin_trajt = 2019
loc fin_tromb = 2016

loc num_per = "2 3 4 5"

foreach var in `var_per' {

	foreach n in `num_per' {

		gen p_`n'_`var' = .

		if ("`var'" == "cepal" & `n' == 5) {
			
			loc group = 3
			loc inicio_`var' = `fin_`var'' - `n'*`group'
			forvalues i = 1(1)`group' {
				
				replace p_`n'_`var' = `i' if año > `inicio_`var'' + (`i'-1)*`n' & año <= `inicio_`var'' + (`i')*`n' 
			}	
		}
		if ("`var'" == "cepal" & `n' == 4) | (("`var'" == "trajt" | "`var'" == "tromb") & `n' == 5)	{
			
			loc group = 4
			loc inicio_`var' = `fin_`var'' - `n'*`group'
			forvalues i = 1(1)`group' {
				
				replace p_`n'_`var' = `i' if año > `inicio_`var'' + (`i'-1)*`n' & año <= `inicio_`var'' + (`i')*`n' 
			}
		}
		if (("`var'" == "trajt" | "`var'" == "tromb") & `n' == 4)	{
			
			loc group = 5
			loc inicio_`var' = `fin_`var'' - `n'*`group'
			forvalues i = 1(1)`group' {
				
				replace p_`n'_`var' = `i' if año > `inicio_`var'' + (`i'-1)*`n' & año <= `inicio_`var'' + (`i')*`n' 
			}
		}
		if (("`var'" == "cepal" | "`var'" == "tromb") & `n' == 3)	{
			
			loc group = 6
			loc inicio_`var' = `fin_`var'' - `n'*`group'
			forvalues i = 1(1)`group' {
				
				replace p_`n'_`var' = `i' if año > `inicio_`var'' + (`i'-1)*`n' & año <= `inicio_`var'' + (`i')*`n' 
			}
		}
		if ("`var'" == "trajt" & `n' == 3)	{
			
			loc group = 7
			loc inicio_`var' = `fin_`var'' - `n'*`group'
			forvalues i = 1(1)`group' {
				
				replace p_`n'_`var' = `i' if año > `inicio_`var'' + (`i'-1)*`n' & año <= `inicio_`var'' + (`i')*`n' 
			}
		}
		if ("`var'" == "cepal" & `n' == 2)	{
			
			loc group = 9
			loc inicio_`var' = `fin_`var'' - `n'*`group'
			forvalues i = 1(1)`group' {
				
				replace p_`n'_`var' = `i' if año > `inicio_`var'' + (`i'-1)*`n' & año <= `inicio_`var'' + (`i')*`n' 
			}
		}
		if ("`var'" == "tromb" & `n' == 2)	{
			
			loc group = 10
			loc inicio_`var' = `fin_`var'' - `n'*`group'
			forvalues i = 1(1)`group' {
				
				replace p_`n'_`var' = `i' if año > `inicio_`var'' + (`i'-1)*`n' & año <= `inicio_`var'' + (`i')*`n' 
			}
		}
		if ("`var'" == "trajt" & `n' == 2)	{
			
			loc group = 11
			loc inicio_`var' = `fin_`var'' - `n'*`group'
			forvalues i = 1(1)`group' {
				
				replace p_`n'_`var' = `i' if año > `inicio_`var'' + (`i'-1)*`n' & año <= `inicio_`var'' + (`i')*`n' 
			}
		}
	} 
}

save "${path_dataout}\base_tesis_completa_graficos.dta", replace


/* 
Idea de hacer serie de regresiones en función de como fueron moviendose los papers en la literatura:
	- Arrancar con regresiones de ciclo y tendencia como recomendó Pablo.
	- Regresines cross-section: crecimiento promedio de todo el periodo de datos en gini inicial para todas las provincias.
	- Panel con distintos periodos de 2 a 5. Elegir si usar gini al inicio o promedio y si del periodo o laggeado para bajar la cantidad de resultados.
	- IDEA ESTEBAN: Hacer lo mismo pero usando la variación de la tendencia solamente, no todo de todo el pbg
	-Paneles dinamicos? En Dominicis hay review de algúnos trabajos. Desde arellano-bond hasta otros que solucionan problema de eso. Mirar con Esteban
	
*/

* variables de regresión
/*
A: variación media pbg
B: variación media tendencia pbg
C: variación media logaritmo pbg
D: variación media logaritmo tendencia pbg

1: Datos transversales
2: Datos en panel
3: Panel dinamico
4:
*/

*# TODO: VER DE DEJAR LAS VARIABLES QUE NO ESTAN EN LA FECHA DE REGRESIÓN BIEN

* 1) Datos transversales
* regresión: común 
* genero las variables de regresión, = 1 si es el primer año de la serie y las variables de crecimiento promedio para el periodo

loc datos_tranversales = "cepal trajt tromb"

foreach var in `datos_tranversales' {

	gen reg_dt_`var' = 0
	if "`var'" == "cepal" replace reg_dt_`var' = 1 if año == `ini_`var''
	if "`var'" == "trajt" replace reg_dt_`var' = 1 if año == `ini_`var''
	if "`var'" == "tromb" replace reg_dt_`var' = 1 if año == `ini_`var''
		
	bysort nprov: egen mean_dt_`var'_a = mean(var_pbg_`var'_pc)
	bysort nprov: egen mean_dt_`var'_b = mean(var_pbg_`var'_pc_tend)
	bysort nprov: egen mean_dt_`var'_c = mean(var_ln_pbg_`var'_pc)
	bysort nprov: egen mean_dt_`var'_d = mean(var_ln_pbg_`var'_pc_tend)
}
bysort nprov: egen mean_dt_gini = mean(gini)
bysort nprov: egen mean_dt_expo_tot = mean(expo_total)

* 2) Datos en panel
* regresión: variación promedio de todo el periodo vs gini al inicio del periodo (periodos de 2, 3, 4 y 5 años)

loc datos_panel = "cepal trajt tromb"
loc periodos = "2 3 4 5"

foreach var in `datos_panel' {
	foreach per in `periodos' {
		
		gen reg_dp_`var'_`per' = 0
		sort nprov p_`per'_`var' año
		by nprov p_`per'_`var': gen aux_`per'_`var' = _n
		replace reg_dp_`var'_`per' = 1 if aux_`per'_`var' == 1

		bysort nprov p_`per'_`var': egen mean_dp_`var'_`per'_a = mean(var_pbg_`var'_pc)
		bysort nprov p_`per'_`var': egen mean_dp_`var'_`per'_b = mean(var_pbg_`var'_pc_tend)
		bysort nprov p_`per'_`var': egen mean_dp_`var'_`per'_c = mean(var_ln_pbg_`var'_pc)
		bysort nprov p_`per'_`var': egen mean_dp_`var'_`per'_d = mean(var_ln_pbg_`var'_pc_tend)

		bysort nprov p_`per'_`var': egen mean_dp_gini_`var'_`per' = mean(gini)
		bysort nprov p_`per'_`var': egen mean_dp_expo_total_`var'_`per' = mean(expo_total)
	}
}


save "${path_dataout}\base_tesis_estimaciones.dta", replace
exit
* regresión: variación promedio de todo el periodo vs gini promedio del periodo anterior (periodos de 2, 3, 4 y 5 años)



* 3) Panel dinámico

loc datos_panel_dinamico = "cepal trajt tromb"







xtreg `c' `g' if reg_`x'==1, `i' 
mat HAUSMAN_RDOS[`fila',`columna']=e(b)
estimates store `i'_sc
loc columna=`columna'+1
		
hausman fe_sc re_sc
*si el valor de chi2 es grande, se rechaza la hipotesis nula --> se usa efectos fijos
*si pv es menor a 0.05 se rechaza h0 --> efectos fijos
mat HAUSMAN_RDOS[`fila',`columna']=r(chi2)
loc columna=`columna'+1
mat HAUSMAN_RDOS[`fila',`columna']=r(p)

loc fila=`fila'+1
loc columna=1



* paso base a panel (#REVIEW - Esto creo que solo para cuando hago las regresiones)
xtset nprov año


   

* #TODO ESTO SUBIRLO 






/*
label var g_l_1 		"Coeficiente de Gini Laggeado"
label var ln_gini_cp	"Logaritmo del Coeficiente de Gini"
label var ln_g_l_1		"Logaritmo del Coeficiente de Gini Laggeado"

label var  crec_ma_2 	"Crecimiento - Media Aritmetica - Periodos de 2 años"
label var  crec_mg_2 	"Crecimiento - Media Geometrica - Periodos de 2 años"
label var  g_i_2		"Coeficiente de Gini Inicial del Periodo - Periodos de 2 años"
label var  g_i_l_2 		"Coeficiente de Gini Inicial del Periodo Laggeado- Periodos de 2 años"
label var  g_p_2 		"Coeficiente de Gini Promedio del Periodo - Periodos de 2 años"
label var  g_p_l_2 		"Coeficiente de Gini Promedio del Periodo Laggeado - Periodos de 2 años"
label var  ln_g_i_2		"Logaritmo del Coeficiente de Gini Inicial del Periodo - Periodos de 2 años"
label var  ln_g_i_l_2   "Logaritmo del Coeficiente de Gini Inicial del Periodo Laggeado- Periodos de 2 años"
label var  ln_g_p_2     "Logaritmo del Coeficiente de Gini Promedio del Periodo - Periodos de 2 años"
label var  ln_g_p_l_2   "Logaritmo del Coeficiente de Gini Promedio del Periodo Laggeado - Periodos de 2 años"

label var  crec_ma_3 	"Crecimiento - Media Aritmetica - Periodos de 3 años"
label var  crec_ma_4 	"Crecimiento - Media Aritmetica - Periodos de 4 años"
label var  crec_mg_3 	"Crecimiento - Media Geometrica - Periodos de 3 años"
label var  crec_mg_4 	"Crecimiento - Media Geometrica - Periodos de 4 años"
label var  g_i_3 		"Coeficiente de Gini Inicial del Periodo - Periodos de 3 años"
label var  g_i_l_3 		"Coeficiente de Gini Inicial del Periodo Laggeado- Periodos de 3 años"
label var  g_p_3 		"Coeficiente de Gini Promedio del Periodo - Periodos de 3 años"
label var  g_p_l_3 		"Coeficiente de Gini Promedio del Periodo Laggeado - Periodos de 3 años"
label var  ln_g_i_3		"Logaritmo del Coeficiente de Gini Inicial del Periodo - Periodos de 3 años"
label var  ln_g_i_l_3   "Logaritmo del Coeficiente de Gini Inicial del Periodo Laggeado- Periodos de 3 años"
label var  ln_g_p_3     "Logaritmo del Coeficiente de Gini Promedio del Periodo - Periodos de 3 años"
label var  ln_g_p_l_3   "Logaritmo del Coeficiente de Gini Promedio del Periodo Laggeado - Periodos de 3 años"
label var  g_i_4		 "Coeficiente de Gini Inicial del Periodo - Periodos de 4 años"
label var  g_i_l_4       "Coeficiente de Gini Inicial del Periodo Laggeado- Periodos de 4 años"
label var  g_p_4         "Coeficiente de Gini Promedio del Periodo - Periodos de 4 años"
label var  g_p_l_4       "Coeficiente de Gini Promedio del Periodo Laggeado - Periodos de 4 años"
label var  ln_g_i_4		 "Logartimo del Coeficiente de Gini Inicial del Periodo - Periodos de 4 años"
label var  ln_g_i_l_4    "Logartimo del Coeficiente de Gini Inicial del Periodo Laggeado- Periodos de 4 años"
label var  ln_g_p_4      "Logartimo del Coeficiente de Gini Promedio del Periodo - Periodos de 4 años"
label var  ln_g_p_l_4    "Logartimo del Coeficiente de Gini Promedio del Periodo Laggeado - Periodos de 4 años"

rename pbg_puig pbg
rename var_pbg_puig var_pbg
rename pbg_pc_puig pbg_pc
rename var_pbg_pc_puig var_pbg_pc

label var pbg_pc "PBG pc - pesos 1993"
label var gini_cp "Coeficiente de Gini"
label var tasa_mort_inf "Tasa de Mortalidad Infantil - Por cada 1000 nacidos vivos"
*/


save "${path_dataout}\base_tesis_estimaciones.dta", replace

