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

