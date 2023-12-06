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
