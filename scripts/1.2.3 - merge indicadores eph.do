****************************************************************************************************************************************
*                                               MERGE BASES EPH
****************************************************************************************************************************************
* Por ahora solo abre y guarda la base de gini, agregar el resto
quietly {

	noi display in green "COMENZANDO MERGE DE BASES DE EPH"

	* Abrimos base de gini
	use "$path_datain\Gini\gini_final_merge.dta", replace 

	* Merge con base de empleo

	* Merge con base de ...


	noi display in yellow "GUARDANDO BASE VARIABLES EPH"
	save "${path_datain}\Bases Finales - Prepara Base\eph_base_completa.dta", replace
}



* OLD
/*
* PASO LAS TABLAS A BASE DE DATOS Y LAS MERGEO, ASÍ LO COMBINO CON LA BASE DE LA TESIS. PARA LOS AÑOS QUE HAY DOS SEMESTRES CALCULO EL GINI COMO EL PROMEDIO DE AMBOS (CHEQUEAR SI ESTARIA OK ESO)

noi display in green "COMENZANDO DO FILE MERGE INDICADORES EPH"
* ESTE DO FILE HAY QUE MODIFICARLO COMPLETO PROBABLEMENTE

clear all

glo bases = "cedlas indec"

foreach base in $bases {

	* GINI
	clear
	import excel "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("`base'") firstrow case(lower)

	rename provincia prov

	drop if prov=="Argentina"
	sort prov 
	egen nprov=group(prov)

	loc año1 = "04 05 06 07 08 09 10 11 12 13 14 17 18 19 20"
	loc año2 = "03 15 16 21"

	foreach a in `año1'{

		egen gini_`base'_20`a' = rowmean(gini_`base'_`a'_1 gini_`base'_`a'_2)
	}
	foreach b in `año2' {

		gen gini_`base'_20`b' = gini_`base'_`b'_
	}

	keep prov nprov gini_`base'_2003 gini_`base'_2004 gini_`base'_2005 gini_`base'_2006 gini_`base'_2007 gini_`base'_2008 gini_`base'_2009 	gini_`base'_2010 gini_`base'_2011 gini_`base'_2012 gini_`base'_2013 gini_`base'_2014 gini_`base'_2015 gini_`base'_2016 gini_`base'_2017 	gini_`base'_2018 gini_`base'_2019 gini_`base'_2020 gini_`base'_2021

	reshape long gini_`base'_, i(prov nprov) j(año)

	rename gini_`base'_ gini_`base'

	save "${path_datain}\Gini\gini_`base'.dta", replace
}

merge 1:1 prov nprov año using "${path_datain}\Gini\gini_cedlas.dta", gen(_merge_gini)

drop _merge_gini

rename prov prov_control

save "${path_datain}\Gini\gini_final.dta", replace

*/