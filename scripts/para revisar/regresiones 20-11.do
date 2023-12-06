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


