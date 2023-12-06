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

loc var_control "pbg_pc_puig tasa_mort_inf"

loc estim " fe re"

loc crec_3 "crec_ma_3 crec_mg_3"

loc crec_4 " crec_ma_4 crec_mg_4"


loc aux "replace"

loc gini_3 "g_i_3 g_i_l_3 g_p_3 g_p_l_3 ln_g_i_3 ln_g_i_l_3 ln_g_p_3 ln_g_p_l_3"

loc gini_4 "g_i_4 g_i_l_4 g_p_4 g_p_l_4 ln_g_i_4 ln_g_i_l_4 ln_g_p_4 ln_g_p_l_4"

forv x=3/4 {

	foreach i in `estim' {
			
		foreach g in `gini_`x'' {
		
			foreach c in `crec_`x'' {
				
				xtreg `c' `g' if reg_`x'==1, `i' robust
				outreg2 using "`path'\e_`c'_`g'.xls", `aux' ctitle (`i'_sc) title(`c')
				
				xtreg `c' `g' `var_control' if reg_`x'==1, `i' robust
				outreg2 using "`path'\e_`c'_`g'.xls", append ctitle (`i'_cc) title(`c')
			
				xtreg `c' `g' `var_control' if reg_`x'==1, `i' vce (cluster nreg)
				outreg2 using "`path'\e_`c'_`g'.xls", append ctitle (`i'_cc_clu) title(`c')	
				
			
			}
		}
		loc aux "append"
		*
	}
	loc aux "replace"
}

exit
*



sort nprov año
bysort nprov: gen time_3=_n if reg_3==1
bysort nprov: gen time_4=_n if reg_4==1

exit


keep if reg_3==1


xtset nprov time

foreach gn of loc `gini_3' {

	xtabond2 crec_ma_3 l.crec_ma_3 l.pbg_pc_puig l.expo_total_a_pbg i.time, gmm(l.crec_ma_3 `gn') iv(l.pbg_pc_puig l.expo_total_a_pbg i.time) robust two small orthogonal nodiffsargan
	
	*otreg2 bla bla bla

}




----
****regresiones que hay que investigar

xtreg crec_ma_4 ln_g_i_l_4 pbg_pc_puig expo_total_a_pbg tasa_mort_inf, fe





gen sample=0
replace sample=1 if año>1994 | año<2011
xtabond2 var_pbg_pc_puig l.var_pbg_pc_puig l.pbg_pc_puig gini_cp i.año if sample==1, gmm(l.var_pbg_pc_puig gini_cp) iv(i.año l.pbg_pc_puig) robust two small orthogonal nodiffsargan


xtabond2 var_pbg_pc_puig l.var_pbg_pc_puig l.pbg_pc_puig ln_gini_cp i.año if sample==1, gmm(l.var_pbg_pc_puig gini_cp) iv(i.año l.pbg_pc_puig) robust two small orthogonal nodiffsargan





gen sample=0 
replace sample=1 if año>1994 & año<2011 
keep if sample==1
xtabond2 var_pbg_pc_puig l.var_pbg_pc_puig l.pbg_pc_puig ln_g_cp i.año if sample==1, gmm(l.var_pbg_pc_puig ln_g_cp) iv(i.año l.pbg_pc_puig) robust two small orthogonal nodiffsargan


xtabond2 crec_mg_3 l.crec_mg_3 l.pbg_pc_puig ln_g_i_l_3 i.año, gmm(l.crec_mg_3 ln_g_i_l_3 ) robust two small orthogonal nodiffsargan

*ESTO DA. HAY QUE ENTENDER PORQUE ENTRA SIN EL SMALL
xtabond2 crec_mg_3 l.crec_mg_3 l.pbg_pc_puig ln_g_i_l_3 i.año, gmm(l.crec_mg_3 ln_g_i_l_3) robust two  orthogonal nodiffsargan

xtabond2 crec_mg_3 l.crec_mg_3 l.pbg_pc_puig g_i_l_3 i.año, gmm(l.crec_mg_3 g_i_l_3) robust two  orthogonal nodiffsargan

xtabond2 crec_mg_3 l.crec_mg_3 l.pbg_pc_puig g_i_l_3 i.año, gmm(l.crec_mg_3 g_i_l_3) iv(i.año l.pbg_pc_puig) robust two orthogonal nodiffsargan

xtabond2 crec_rapetti_3 l.crec_rapetti_3 l.pbg_pc_puig gini_inicial_per_lag_3 i.año, gmm(l.crec_rapetti_3 gini_inicial_per_lag_3) iv(i.año l.pbg_pc_puig) robust two orthogonal nodiffsargan small
*****armar variable con coeficiente de gini INICIAL para todos
***** ver de rankear provincias por coeficiente de gini

sort nprov año 
xtset nprov año 

xi:xtreg ln_g_i_l_3 pbg_pc_puig tasa_mort_inf i.año, fe robust 
predict ln_gini_lag_hat 
xi:xtreg crec_mg_3 ln_gini_lag_hat pbg_pc_puig tasa_mort_inf i.año, fe robust 

ACORDATE QUE EL LOGARITMO NO ES UNA TRANSFORMACIÓN LINEAL

*poner en el bucle de las regresiones el test de hausman y que te exporte el resultado directo

xi:xtreg crec_mg_3 g_i_l_3 pbg_pc_puig tasa_mort_inf i.año, fe robust


para exportar sólo lo que nos interesa


mat resultados=J(111,3,.)
mat coef=e(b)  
mat varv_model= e(V_modelbased) 
mat resultados[1,1]=coef[1,1]
mat resultados[1,2]=coef[1,1]/sqrt(varv_model[1,1])
mat resultados[1,3]=resultados[1,1]/resultados[1,2]

**exporta nobs nprov rcuadrado y hausman

**unir con base destino expo (potencial instrumento un 3er socio comercial del país destino que no comercie con argentina)
** fijate si podés usando datos censales y datos de institutos provinciales armar las series de los principales controles que no tenemos.