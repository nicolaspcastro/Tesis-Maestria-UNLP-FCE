************* PREPARA BASE TESIS - 11/08/21 ******************************
clear all
set more off


capture cd "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones"
if _rc!=0 cd "G:\Mi unidad\Tesistas\Nicolás Castro\Estimaciones"


use base_tesis_inicio.dta

*dropeo resto no distrib
cap drop if nprov>24

drop crec_prom_2

gen crecimiento=var_pbg_pc/100

xtset nprov año

*Generamos dummies regionales

gen pampeana=0
gen cuyo=0
gen noa=0
gen nea=0
gen patagonia=0

replace pampeana=1 if nreg==1
replace cuyo=1 if nreg==2
replace noa=1 if nreg==4
replace nea=1 if nreg==3
replace patagonia=1 if nreg==5


*calculo expo anual como porcentaje del total nacional
sort año
gen expo_tot_sum_año=.
forv i=1995/2011 {

sum expo_total if año==`i'
bysort año: replace expo_tot_sum_año=r(sum) if año==`i' 

}


gen porc_expo=expo_total/expo_tot_sum_año*100

*pongo la tasa de mort inf de 1996 en 1995
sort nprov año
clonevar mort_inf_2=tasa_mort_inf
replace mort_inf_2=tasa_mort_inf[_n+1]
replace tasa_mort_inf=mort_inf_2 if año==1995
drop mort_inf_2


*genero los periodos
*periodos de 4 años
gen periodo_4=.
replace periodo_4=1 if año>1994 & año<1999
replace periodo_4=2 if año>1998 & año<2003
replace periodo_4=3 if año>2002 & año<2007
replace periodo_4=4 if año>2006 & año<2011

*periodos de 3 años
gen periodo_3=.
replace periodo_3=1 if año>1994 & año<1998
replace periodo_3=2 if año>1997 & año<2001
replace periodo_3=3 if año>2000 & año<2004
replace periodo_3=4 if año>2003 & año<2007
replace periodo_3=5 if año>2006 & año<2010

*periodos de 2 años
gen periodo_2=.
replace periodo_2=1 if año>1994 & año<1997
replace periodo_2=2 if año>1996 & año<1999
replace periodo_2=3 if año>1998 & año<2001
replace periodo_2=4 if año>2000 & año<2003
replace periodo_2=5 if año>2002 & año<2005
replace periodo_2=6 if año>2004 & año<2007
replace periodo_2=7 if año>2006 & año<2009
replace periodo_2=8 if año>2008 & año<2011

tsfilter hp pbg_pc_ciclo=pbg_pc_puig, trend (pbg_pc_tend)
sort nprov año
bysort nprov: gen var_tend=((pbg_pc_tend/pbg_pc_tend[_n-1])-1)*100
label var var_tend "Variación de la Tendencia del PBI - se lee en porcentaje (igual que var_ppbg_pb)"


forv x=3/4 {

	*genero las variables a usar
	*reg para indicar que observaciones usar
	gen reg_`x'=.
	*crecimiento del pbg pc en el periodo
	gen crec_prom_`x'=.
	*crecimiento del pbg pc rapetti
	gen crec_rapetti_`x'=.
	*gini en el año de inicio del periodo
	gen gini_inicial_periodo_`x'=.
	*gini a inicio del periodo anterior
	gen gini_inicial_per_lag_`x'=.
	*gini promedio del periodo
	gen gini_prom_`x'=.
	*gini promedio del periodo anterior
	gen gini_prom_lag_`x'=.
	*crecimiento del pbg - solo la tendencia
	gen crec_tend_`x'=.
	*reemplazamos la variables
	*pongo el gini al inicio de cada periodo
	sort nprov año
	
	forv z=1995(`x')2007{
		replace gini_inicial_periodo_`x'=gini_cp if año==`z'
		replace reg_`x'=1 if año==`z'
		
	
	}
	
	sort nprov año
	*calculo la variacion de cada periodo y provincia y se la incorporo a las observaciones de la regresion
	*calculo el gini promedio de cada periodo y provincia y se lo incorporo a las observaciones de la regresion
	forv i=1/5{
		forv j=1/24{
			sum var_pbg_pc_puig if periodo_`x'==`i' & nprov==`j'
			bysort nprov año: replace crec_prom_`x'=r(mean)/100 if periodo_`x'==`i' & nprov==`j' & reg_`x'==1
			sum gini_cp if periodo_`x'==`i' & nprov==`j'
			bysort nprov año: replace gini_prom_`x'=r(mean) if periodo_`x'==`i' & nprov==`j' & reg_`x'==1
			sum var_tend if periodo_`x'==`i' & nprov==`j'
			bysort nprov año: replace crec_tend_`x'=r(mean)/100 if periodo_`x'==`i' & nprov==`j' & reg_`x'==1
		}
		
	}
	
	
		
	
	
	
}

*reg para indicar que observaciones usar
gen reg_2=.
*crecimiento del pbg pc en el periodo
gen crec_prom_2=.
*crecimiento del pbg pc rapetti
gen crec_rapetti_2=.
*gini en el año de inicio del periodo
gen gini_inicial_periodo_2=.
*gini a inicio del periodo anterior
gen gini_inicial_per_lag_2=.
*gini promedio del periodo
gen gini_prom_2=.
*gini promedio del periodo anterior
gen gini_prom_lag_2=.
*crecimiento del pbg - solo la tendencia
gen crec_tend_2=.

sort nprov año
	
forv w=1995(2)2009{
	replace gini_inicial_periodo_2=gini_cp if año==`w'
	replace reg_2=1 if año==`w'
		
	
}

sort nprov año

forv i=1/8{
	forv j=1/24{
		sum var_pbg_pc_puig if periodo_2==`i' & nprov==`j'
		bysort nprov año: replace crec_prom_2=r(mean)/100 if periodo_2==`i' & nprov==`j' & reg_2==1
		sum gini_cp if periodo_2==`i' & nprov==`j'
		bysort nprov año: replace gini_prom_2=r(mean) if periodo_2==`i' & nprov==`j' & reg_2==1
		sum var_tend if periodo_2==`i' & nprov==`j'
		bysort nprov año: replace crec_tend_2=r(mean)/100 if periodo_2==`i' & nprov==`j' & reg_2==1	
	}
		
}





replace gini_inicial_per_lag_4=l.l.l.l.gini_inicial_periodo_4 if reg_4==1
replace gini_prom_lag_4=l.l.l.l.gini_prom_4 if reg_4==1

replace gini_inicial_per_lag_3=l.l.l.gini_inicial_periodo_3 if reg_3==1
replace gini_prom_lag_3=l.l.l.gini_prom_3 if reg_3==1

replace gini_inicial_per_lag_2=l.l.gini_inicial_periodo_2 if reg_2==1
replace gini_prom_lag_2=l.l.gini_prom_2 if reg_2==1

gen reg_1=.
replace reg_1=1 if año>1994 & año<2011
gen g_l_1=l.gini_cp

loc gini_1 "gini_cp g_l_1"

loc gini_2 "gini_inicial_periodo_2 gini_inicial_per_lag_2 gini_prom_2 gini_prom_lag_2"

loc gini_3 "gini_inicial_periodo_3 gini_inicial_per_lag_3 gini_prom_3 gini_prom_lag_3"

loc gini_4 "gini_inicial_periodo_4 gini_inicial_per_lag_4 gini_prom_4 gini_prom_lag_4"


forv x=1/4 {

	foreach g in `gini_`x'' {
		gen ln_`g'=log(`g')

	}

}

sort nprov año
bysort nprov:replace crec_rapetti_2=(pbg_pc_puig[_n+1]/pbg_pc_puig)-1
sort nprov año
bysort nprov:replace crec_rapetti_3=((pbg_pc_puig[_n+2]/pbg_pc_puig)^(1/2))-1
sort nprov año
bysort nprov:replace crec_rapetti_4=((pbg_pc_puig[_n+3]/pbg_pc_puig)^(1/3))-1




/*
sort nprov año

bysort nprov: replace crec_rapetti_3=((pbg_pc_puig[_n+2]/pbg_pc_puig)^(1/2))-1 if año==1992
sort nprov año
bysort nprov: replace crec_rapetti_4=((pbg_pc_puig[_n+2]/pbg_pc_puig)^(1/3))-1 if año==1991
*/
*corr entre crecimientos por encima de 0.91
corr crec_prom_4 crec_rapetti_4
corr crec_prom_4 crec_rapetti_4


corr var_pbg_pc_puig pbg_pc_puig gini_cp expo_total tasa_mort_inf
corr var_pbg_pc_puig pbg_pc_puig gini_cp porc_expo expo_total_a_pbg tasa_mort_inf


rename crec_prom_2 crec_ma_2
rename crec_prom_3 crec_ma_3
rename crec_prom_4 crec_ma_4

rename crec_rapetti_2 crec_mg_2
rename crec_rapetti_3 crec_mg_3
rename crec_rapetti_4 crec_mg_4

rename gini_inicial_periodo_2 g_i_2
rename gini_inicial_per_lag_2 g_i_l_2
rename gini_prom_2 g_p_2
rename gini_prom_lag_2 g_p_l_2
rename ln_gini_inicial_periodo_2 ln_g_i_2
rename ln_gini_inicial_per_lag_2 ln_g_i_l_2
rename ln_gini_prom_2 ln_g_p_2
rename ln_gini_prom_lag_2 ln_g_p_l_2

rename gini_inicial_periodo_3 g_i_3
rename gini_inicial_per_lag_3 g_i_l_3
rename gini_prom_3 g_p_3
rename gini_prom_lag_3 g_p_l_3
rename ln_gini_inicial_periodo_3 ln_g_i_3
rename ln_gini_inicial_per_lag_3 ln_g_i_l_3
rename ln_gini_prom_3 ln_g_p_3
rename ln_gini_prom_lag_3 ln_g_p_l_3

rename gini_inicial_periodo_4 g_i_4
rename gini_inicial_per_lag_4 g_i_l_4
rename gini_prom_4 g_p_4
rename gini_prom_lag_4 g_p_l_4
rename ln_gini_inicial_periodo_4 ln_g_i_4
rename ln_gini_inicial_per_lag_4 ln_g_i_l_4
rename ln_gini_prom_4 ln_g_p_4
rename ln_gini_prom_lag_4 ln_g_p_l_4

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


gen ln_pbg_pc=log(pbg_pc)
bysort nprov: gen var_ln_pbg_pc=ln_pbg_pc-ln_pbg_pc[_n-1]
label var ln_pbg_pc "Logaritmo del PBG pc"
label var var_ln_pbg_pc "Variación anual del Logaritmo del PBG pc"

gen ln_pbg_pc_tend=log(pbg_pc_tend)
bysort nprov: gen var_ln_pbg_pc_tend=ln_pbg_pc_tend-ln_pbg_pc_tend[_n-1]

bysort nprov: gen var_gini=gini_cp-gini_cp[_n-1]
label var var_gini "Variación anual del coeficiente de Gini"

save base_tesis_reducida.dta, replace

