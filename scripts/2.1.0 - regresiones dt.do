****************************************************************************************************************************************
*                                               REGRESIONES DE DATOS TRANSVERSALES
****************************************************************************************************************************************

* DATOS TRANSVERSALES: para cada provincia teneomos una observación. La variable dependiente es el crecimiento anual promedio del pbg para todo el periodo, la variable independiente es el coeficiente de gini al inicio del periodo o el coeficiente de gini promedio del periodo. 

* Los controles son:
    * pbg al inicio del periodo (todos los años necesario) 
    * exportaciones promedio del periodo / al inicio del periodo (todos los años necesarios)
    * tasa de mortalidad infantil al inicio del periodo (todos los años necesarios)
    * puestos de trabajo en el sector formal (1996 a 2017, no habría problema porque uso al inicio así que con 2017 me alcanza)
    * indice de desarrollo humano al inicio del periodo (96 01 06 11 16, hay que completar los años faltantes de alguna manera). Solo puedo usarlo en periodos de 4 y 5 años, porque tengo 5 observaciones. podría usar el más cercano
    
noi display in green "CORRIENDO ESTIMACIONES DE DATOS TRANSVERSALES"

* importo base

use "${path_dataout}\base_tesis_estimaciones.dta", clear


loc datos_transversales = "cepal trajt tromb"

foreach var in `datos_transversales' {

    loc var_dep_`var'     = "mean_dt_`var'_a mean_dt_`var'_b mean_dt_`var'_c mean_dt_`var'_d"
}

loc var_indep       = "gini mean_dt_gini"
*loc controles_ini   = "expo_total mean_dt_expo_total pbg_`var'_pc idh"
loc controles_ini_1   = "expo_total tasa_mort_inf ptspf_sipa"
loc controles_ini_2   = "expo_total tasa_mort_inf"
loc controles_ini_3   = "expo_total ptspf_sipa"
loc controles_ini_4   = "tasa_mort_inf ptspf_sipa"
loc controles_ini_5   = "expo_total"
loc controles_ini_6   = "tasa_mort_inf"
loc controles_ini_7   = "ptspf_sipa"

loc controles = "controles_ini_1 controles_ini_2 controles_ini_3 controles_ini_4 controles_ini_5 controles_ini_6 controles_ini_7"

foreach var in `datos_transversales' {
    foreach var_d in `var_dep_`var'' {
        foreach var_i in `var_indep' {
            foreach var_control in `controles' {
                noi display in green "estimando `var_d' `var_i' `var_control'"
                
                reg `var_d' `var_i' pbg_`var'_pc ``var_control'' if reg_dt_`var' == 1

                if ("`var_d'" == "mean_dt_`var'_a" & "`var_i'" == "gini" & "`var_control'" == "controles_ini_1") outreg2 using "${path_tables}/dt/reg_`var'.xls", replace
                
                else outreg2 using "${path_tables}/dt/reg_`var'.xls", append
            }
        }    
    }
}

exit        
