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















exit
*

