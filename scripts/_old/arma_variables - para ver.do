***************************ARMA VARIABLES DE INTERVENCION: BIANUAL - TRIANUAL - CUATRIANUAL - QUINQUENAL

clear all
set more off

capture cd "D:\Google Drive\Doctorado\u3\base octubre 2021"
if _rc!=0 capture cd "D:\Google Drive\Doctorado\u2\base octubre 2021"
if _rc!=0 capture cd "C:\Users\nicoc\Google Drive\Trabajos\Tesis Esteban\Unidad 2 Tesis Esteban\Arma Intervencion"

use base_para_arma_var.dta, clear

drop if countrycode=="."
drop country _merge interpola



collapse (mean) tcn mdos fa_pablo bm_pablo fl_pablo gd_pablo tcn_pablo mdos_pablo cpi cpigen fa fl gd bm rt fa_mdos fad m2d cpiusa tcr_bil_ifs tcrg_bil_ifs ncountry npais, by(countrycode year mes)
foreach var of varlist _all {
	label var `var' ""
}

exit

drop ncountry npais
encode countrycode, generate (npais)




forvalues t=1/5 {
loc nperiodos=int(65/`t')
	di `nperiodos'
	gen periodo_`t' =.
	forvalues i=1/`nperiodos'{
		loc orden=`nperiodos'+1-`i'
		loc i_1=`i'-1
		gen periodo_`t'_`orden'=0
		replace periodo_`t'_`orden'=1 if year>=2015-`i'*`t' & year<2015-`i_1'*`t'
		replace periodo_`t' =`orden' if periodo_`t'_`orden'==1
	}
	replace periodo_`t'_`orden'=. if periodo_`t'==.
	
	*drop if periodo_`t' ==.
	}

drop periodo_1_* periodo_2_* periodo_3_* periodo_4_* periodo_5_*

***********************************Intervenciones de a 1 año *********************
gen double r_mdos =(fa-fl-gd)/mdos
gen double r_m2d =(fa-fl-gd)/m2d

	loc 12t=12
forv t=1/5{
	

	sort npais periodo_`t' year mes
	
	bysort periodo_`t': egen anio=max(year)
	
	sort npais periodo_`t' year mes

	
	
	* intervención 1 absoluta
	gen double int1_abs =.
	by npais: replace int1_abs = abs((rt-rt[_n-1])) / (bm[_n-1]/tcn[_n-1]) 
	
	* intervención 1 en el mes
	gen double int1_m =.
	by npais: replace int1_m = (rt-rt[_n-1]) / (bm[_n-1]/tcn[_n-1])
	* intervención 1 en el año
	gen double int1_a =.
	by npais: replace int1_a = (rt-rt[_n-`12t']) / (bm[_n-`12t']/tcn[_n-`12t']) if anio==year & mes==12
	
	
	* intervención 2 en el mes
	gen double int2_m =.
	by npais: replace int2_m = (fa_mdos - fa_mdos[_n-1]) 
	* intervención 2 en el año
	gen double int2_a =.
	by npais: replace int2_a = (fa_mdos - fa_mdos[_n-`12t']) if anio==year & mes==12
	
	* intervención 3 en el mes
	
	gen double int3_m =.
	by npais: replace int3_m = (r_mdos - r_mdos[_n-1]) 
	* intervención 3 en el año
	gen double int3_a =.
	by npais: replace int3_a = (r_mdos - r_mdos[_n-`12t']) if anio==year & mes==12
	
	* intervención 4 en el mes
	
	gen double int4_m =.
	by npais: replace int4_m = (r_m2d - r_m2d[_n-1]) 
	* intervención 4 en el año
	gen double int4_a =.
	by npais: replace int4_a = (r_m2d - r_m2d[_n-`12t']) if anio==year & mes==12
	
	
	
	* variables a diciembre
	foreach var of varlist fa bm fl gd tcn mdos tcr_bil_ifs tcrg_bil_ifs {
		gen double `var'_fin =`var' if anio==year & mes==12
	}
	
	preserve
	collapse (mean) anio fa bm fl gd tcn rt mdos fa_mdos fad m2d fa_fin bm_fin fl_fin gd_fin tcn_fin mdos_fin int1_abs int1_m int1_a int2_m int2_a int3_m int3_a int4_a int4_m tcr_bil_ifs tcr_bil_ifs_fin tcrg_bil_ifs tcrg_bil_ifs_fin , by(periodo_`t' countrycode)

	rename anio year
	
	foreach var of varlist _all {
	label var `var' ""
}
	
	save base_intervención_`t'.dta, replace
	restore
	drop int* fa_fin bm_fin fl_fin gd_fin tcn_fin mdos_fin tcr_bil_ifs_fin tcrg_bil_ifs_fin anio
	loc 12t=`12t'+12
}

exit





















































------------
***********************************Intervenciones de a 2 años *********************



sort npais year mes periodo_2


* intervención 1 BIANUAL
*simple (dic a dic)
gen double int1_a_t2 =.
by npais: replace int1_a_t2 = (rt-rt[_n-24]) / (bm[_n-24]/tcn[_n-24]) if mes==12 
*& ind_2==2
*prom (promedio de cada año del intrevalo)
bysort npais periodo_2: egen double int1_b_prom = mean(int1_a) if mes==12


* intervención 2 BIANUAL
*simple (dic a dic)
gen double int2_b_sim =.
by npais: replace int2_b_sim = (fa_mdos - fa_mdos[_n-24]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_2: egen double int2_b_prom = mean(int2_a) if mes==12

* intervención 3 BIANUAL
*simple (dic a dic)
gen double int3_b_sim =.
by npais: replace int3_b_sim = (r_mdos - r_mdos[_n-24]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_2: egen double int3_b_prom = mean(int3_a) if mes==12

* intervención 4 BIANUAL
*simple (dic a dic)
gen double int4_b_sim =.
by npais: replace int4_b_sim = (r_m2d - r_m2d[_n-24]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_2: egen double int4_b_prom = mean(int4_a) if mes==12







***********************************Intervenciones de a 3 años *********************



sort npais  year mes periodo_3



* intervención 1 TRIANUAL
*simple (dic a dic)
gen double int1_t_sim =.
by npais: replace int1_t_sim = (rt-rt[_n-36]) / (bm[_n-36]/tcn[_n-36]) if mes==12  
*prom (promedio de cada año del intrevalo)
*prom (promedio de cada año del intrevalo)
bysort npais periodo_3: egen double int1_t_prom = mean(int1_a) if mes==12


* intervención 2 TRIANUAL
*simple (dic a dic)
gen double int2_t_sim =.
by npais: replace int2_t_sim = (fa_mdos - fa_mdos[_n-36]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_3: egen double int2_t_prom = mean(int2_a) if mes==12

* intervención 3 TRIANUAL
*simple (dic a dic)
gen double int3_t_sim =.
by npais: replace int3_t_sim = (r_mdos - r_mdos[_n-36]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_3: egen double int3_t_prom = mean(int3_a) if mes==12

* intervención 4 TRIANUAL
*simple (dic a dic)
gen double int4_t_sim =.
by npais: replace int4_t_sim = (r_m2d - r_m2d[_n-36]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_3: egen double int4_t_prom = mean(int4_a) if mes==12


***********************************Intervenciones de a 4 años *********************


sort npais year mes periodo_4

* intervención 1 CUATRIANUAL
*simple (dic a dic)
gen double int1_c_sim =.
by npais: replace int1_c_sim = (rt-rt[_n-48]) / (bm[_n-48]/tcn[_n-48]) if mes==12  
*prom (promedio de cada año del intrevalo)
bysort npais periodo_4: egen double int1_c_prom = mean(int1_a) if mes==12



* intervención 2 CUATRIANUAL
*simple (dic a dic)
gen double int2_c_sim =.
by npais: replace int2_c_sim = (fa_mdos - fa_mdos[_n-48]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_4: egen double int2_c_prom = mean(int2_a) if mes==12

* intervención 3 CUATRIANUAL
*simple (dic a dic)
gen double int3_c_sim =.
by npais: replace int3_c_sim = (r_mdos - r_mdos[_n-48]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_4: egen double int3_c_prom = mean(int3_a) if mes==12

* intervención 4 CUATRIANUAL
*simple (dic a dic)
gen double int4_c_sim =.
by npais: replace int4_c_sim = (r_m2d - r_m2d[_n-48]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_4: egen double int4_c_prom = mean(int4_a) if mes==12


***********************************Intervenciones de a 5 años *********************



sort npais year mes periodo_5


* intervención 1 QUINQUENAL
*simple (dic a dic)
gen double int1_q_sim =.
by npais: replace int1_q_sim = (rt-rt[_n-60]) / (bm[_n-60]/tcn[_n-60]) if mes==12  
*prom (promedio de cada año del intrevalo)
bysort npais periodo_5: egen double int1_q_prom = mean(int1_a) if mes==12
 


* intervención 2 QUINQUENAL
*simple (dic a dic)
gen double int2_q_sim =.
by npais: replace int2_q_sim = (fa_mdos - fa_mdos[_n-60]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_5: egen double int2_q_prom = mean(int2_a) if mes==12

* intervención 3 QUINQUENAL
*simple (dic a dic)
gen double int3_q_sim =.
by npais: replace int3_q_sim = (r_mdos - r_mdos[_n-60]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_5: egen double int3_q_prom = mean(int3_a) if mes==12

* intervención 4 QUINQUENAL
*simple (dic a dic)
gen double int4_q_sim =.
by npais: replace int4_q_sim = (r_m2d - r_m2d[_n-60]) if mes==12
*prom (promedio de cada año del intrevalo)
bysort npais periodo_5: egen double int4_q_prom = mean(int4_a) if mes==12

exit










