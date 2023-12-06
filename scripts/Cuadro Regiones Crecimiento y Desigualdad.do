************* Cuadro en Cruz - Por encima y debajo del promedio en cada variable ******************************
clear all
set more off


capture cd "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
if _rc!=0 cd "C:\Users\NICO\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
if _rc!=0 cd "C:\Users\Estadística 2\Google Drive\Facultad\Maestria\Tesis\Estimaciones"

use base_tesis_reducida.dta


xtset nprov año


loc varlist "var_pbg_pc_puig gini_cp"

mat REG=J(23,4,.)

foreach var of varlist `varlist' {
	gen aux_`var'_mean=.
	gen aux_`var'_ind=.
	
	forv i=1995/2010 {
		sum `var' if año==`i'
		replace aux_`var'_mean=r(mean) if año==`i'
		replace aux_`var'_ind=1 if `var'>aux_`var'_mean & año==`i'
		replace aux_`var'_ind=0 if `var'<aux_`var'_mean & año==`i'
	}
}



forv j=1/4 {
	gen r`j'=0	
}

* Region 1: Encima del promedio en ambas variables
* Region 4: Por debajo del promedio en ambas variables
* Region 2: Por debajo en crecimiento y encima en gini_cp
* Region 3: Por encima en crecimiento y por debajo en gini_cp

forv i=1995/2010 {
	replace r1=1 if aux_var_pbg_pc_puig_ind==1 & aux_gini_cp_ind==1 & año==`i'
	replace r2=1 if aux_var_pbg_pc_puig_ind==0 & aux_gini_cp_ind==1 & año==`i'
	replace r3=1 if aux_var_pbg_pc_puig_ind==1 & aux_gini_cp_ind==0 & año==`i'
	replace r4=1 if aux_var_pbg_pc_puig_ind==0 & aux_gini_cp_ind==0 & año==`i'

}
forv z=1/23 {
	forv j=1/4 {
		sum r`j' if nprov==`z'
		mat REG[`z',`j']=(r(sum)/16)

	}

}
 mat list REG
 
drop aux* r*

putexcel A1=mat(REG) using cuadro_regiones.xlsx, sheet(original) modify 


* PASAR A ALGÚN GRAFICO DE PHYTON
* CORR ENTRE GINI Y PBG