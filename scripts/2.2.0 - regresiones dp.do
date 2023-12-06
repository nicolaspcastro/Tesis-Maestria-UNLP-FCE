****************************************************************************************************************************************
*                                               REGRESIONES DE DATOS EN PANEL
****************************************************************************************************************************************

* DATOS EN PANEL: para cada provincia tenemos una observación por periodo. La variable dependiente es el crecimiento anual promedio del pbg para todo el periodo, la variable independiente es el coeficiente de gini al inicio del periodo o el coeficiente de gini promedio del periodo. 

* Los periodos son de 3/4/5 años

* Los controles son:
    * pbg al inicio del periodo (todos los años necesario) 
    * exportaciones promedio del periodo / al inicio del periodo (todos los años necesarios)
    * tasa de mortalidad infantil al inicio del periodo (todos los años necesarios)
    * puestos de trabajo en el sector formal (1996 a 2017, no habría problema porque uso al inicio así que con 2017 me alcanza)
    * indice de desarrollo humano al inicio del periodo (96 01 06 11 16, hay que completar los años faltantes de alguna manera). Solo puedo usarlo en periodos de 4 y 5 años, porque tengo 5 observaciones. podría usar el más cercano
    
noi display in green "CORRIENDO ESTIMACIONES DE DATOS EN PANEL"

* importo base

use "${path_dataout}\base_tesis_estimaciones.dta", clear

xtset nprov año

* armo una matriz para guardar resultados
mat define coeficientes = J(1000, 6, .)

loc periodos = "2 3 4 5"

loc i = 1
foreach periodo in `periodos'{

    *display "`periodo'"

    loc datos_en_panel = "cepal trajt tromb"

    foreach var in `datos_en_panel' {

        loc var_dep_`var'_`periodo'           = "mean_dp_`var'_`periodo'_a mean_dp_`var'_`periodo'_b mean_dp_`var'_`periodo'_c mean_dp_`var'_`periodo'_d"

        loc var_indep_`var'_`periodo'         = "gini mean_dp_gini_`var'_`periodo'"
        loc controles_ini_1_`var'_`periodo'   = "expo_total tasa_mort_inf ptspf_sipa"
        loc controles_ini_2_`var'_`periodo'   = "expo_total tasa_mort_inf"
        loc controles_ini_3_`var'_`periodo'   = "expo_total ptspf_sipa"
        loc controles_ini_4_`var'_`periodo'   = "tasa_mort_inf ptspf_sipa"
        loc controles_ini_5_`var'_`periodo'   = "expo_total"
        loc controles_ini_6_`var'_`periodo'   = "tasa_mort_inf"
        loc controles_ini_7_`var'_`periodo'   = "ptspf_sipa"

        loc controles_`var'_`periodo' = "controles_ini_1_`var'_`periodo' controles_ini_2_`var'_`periodo' controles_ini_3_`var'_`periodo' controles_ini_4_`var'_`periodo' controles_ini_5_`var'_`periodo' controles_ini_6_`var'_`periodo' controles_ini_7_`var'_`periodo'"
    }


    

    foreach var in `datos_en_panel' {
        foreach var_d in `var_dep_`var'_`periodo'' {
            foreach var_i in `var_indep_`var'_`periodo'' {
                foreach var_control in `controles_`var'_`periodo'' {
                    noi display in green "estimando `var_d' `var_i' `var_control'"
                    
                    xtreg `var_d' `var_i' pbg_`var'_pc ``var_control'' if reg_dp_`var'_`periodo' == 1, fe vce(robust)

                    mat define resultados = r(table)
                    
                    loc beta = resultados[1,1]
                    loc p_v = resultados[4,1]
                    
                    if `p_v' < 0.05 loc p_v_aux = 1 
                    if `p_v' >= 0.05 loc p_v_aux = 0 
                    
                    if regexm("`var_d'", "_a$") == 1 loc var_dep = 1 
                    if regexm("`var_d'", "_b$") == 1 loc var_dep = 2 
                    if regexm("`var_d'", "_c$") == 1 loc var_dep = 3 
                    if regexm("`var_d'", "_d$") == 1 loc var_dep = 4
                    
                    loc var_indep = 2  
                    if "`var_i'" == "gini" loc var_indep = 1 
                     

                    mat coeficientes[`i', 1] = `beta'       // beta del coeficiente de gini
                    mat coeficientes[`i', 2] =  `p_v_aux'   // si es significativo (=1) o no (=0)
                    mat coeficientes[`i', 3] =  `var_dep'   // variable dependiente (a=1, b=2, c=3, d=4)
                    mat coeficientes[`i', 4] =  `var_indep' // var indep (gini=1, gini promedio=2)
                    mat coeficientes[`i', 5] =  `periodo'   // cantidad de años en el periodo

                    if ("`var_d'" == "mean_dp_`var'_a" & "`var_i'" == "gini" & "`var_control'" == "controles_ini_1") outreg2 using "${path_tables}/dp/reg_`var'_`periodo'.xls", replace
                    
                    else outreg2 using "${path_tables}/dp/reg_`var'_`periodo'.xls", append

                    loc i = `i' + 1
                }
            }    
        }
    }
}

exit        