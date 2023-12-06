*******************************************************************************************************************************************
*                                             DO FILE AUXILIAR EPH CONTINUA - PASAR BASES A DTA, MERGE, ETC.
*******************************************************************************************************************************************

quietly {
	noi display in green "COMENZANDO DO FILE AUXILIAR EPH CONTINUA"
	***************************************************************************************************************************************
	*                                               APERTURA DE BASES .XLSX Y GUARDADO EN .DTA
	***************************************************************************************************************************************

	* ABRIMOS BASES DE 2016 A 2021 QUE ESTAN EN FORMATO EXCEL 

	* BASES EN FORMATO XLS 
	foreach base in $bases {
	    foreach i in $año_excel {
	        foreach j in $trimestre {
			
	            capture import excel "${path_datain}\EPH\Bases Originales\EPH INDEC\Bases en Otros formatos\EPHC - 2016 - 2021\\`base'_t`j'`i'.xls", firstrow case(lower) clear
	
	    		if _rc==601{

	    		no display in red "NO EXISTE BASE 20`i'_`j' EN EL FORMATO SELECCIONADO (XLS) - PASANDO A SIGUIENTE BASE..."
		        }

	    		if _rc!=601 {

					no display in yellow "EXISTE BASE 20`i'_`j' EN EL FORMATO SELECCIONADO (XLS) - GUARDANDO ARCHIVO DTA..."
	                save "${path_datain}\EPH\Bases Originales\EPH INDEC\Bases en DTA\\`base'\\`base'_t`j'`i'.dta", replace
				}
			}
		}
	}

	* BASES EN FORMATO XLSX
	foreach base in $bases {
	    foreach i in $año_excel {
	        foreach j in $trimestre {

	    		capture import excel "${path_datain}\EPH\Bases Originales\EPH INDEC\Bases en Otros formatos\EPHC - 2016 - 2021\\`base'_t`j'`i'.xlsx", firstrow case(lower) clear
	
	    		if _rc==601{

	    		display in red "NO EXISTE BASE 20`i'_`j' EN EL FORMATO SELECCIONADO (XLSX) - PASANDO A SIGUIENTE BASE..."
		        }

	    		if _rc!=601 {

					display in yellow "EXISTE BASE 20`i'_`j' EN EL FORMATO SELECCIONADO (XLSX) - GUARDANDO ARCHIVO DTA..."
	                save "${path_datain}\EPH\Bases Originales\EPH INDEC\Bases en DTA\\`base'\\`base'_t`j'`i'.dta", replace
				}
			}
		}
	}

	***************************************************************************************************************************************
	*                                               JUNTO BASES A NIVEL INDIVIDUAL CON BASES A NIVEL HOGAR
	***************************************************************************************************************************************
	* BASES DESDE 2003 TRIMESTRE 3 HASTA 2021 TRIMESTRE 4
	foreach i in $año_continua {
		foreach j in $trimestre {

			capture use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Individual\Individual_t`j'`i'", clear

			if _rc==601{

	    		noi display in red "NO EXISTE BASE 20`i'_`j' - PASANDO A SIGUIENTE BASE..."
		    }
			if _rc==0 {
			
			noi display in yellow "EXISTE BASE 20`i'_`j' - GENERANDO BASE COMPLETA..."

			rename *, lower
			destring, replace
			sort codusu nro_hogar aglomerado
			save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Individual\Individual_aux", replace

			use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Hogar\Hogar_t`j'`i'", clear

			rename *, lower
			destring, replace
			sort codusu nro_hogar aglomerado
			merge 1:m codusu nro_hogar aglomerado using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Individual\Individual_aux"
			erase "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Individual\Individual_aux.dta"

			tabulate _merge
			keep if (_merge==3)
			drop _merge
			duplicates report
			duplicates drop
			compress

			save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHC_20`i'_T`j'", replace
			}
		}
	}

	***************************************************************************************************************************************
	*                                               PASAR BASES TRIMESTRALES A BASES SEMESTRALES
	***************************************************************************************************************************************
	* BASES DESDE 2003 POR SEMESTRE

	foreach i in $año_continua {
		foreach k in $semestre {

	        loc z=(`k'*2)-1
			loc w=(`k'*2)

	        if (`i'==03 & `k'==1) | (`i'==15 & `k'==2) | (`i'==07 & `k'==2) | (`i'==16 & `k'==1) {

				if (`i'==03 & `k'==1) | (`i'==15 & `k'==2) {
				
					display in red "NO EXISTEN DATOS PARA CREAR BASE 20`i'_`k' - PASANDO A SIGUIENTE BASE..."            
	        	}

	        	if (`i'==07 & `k'==2) | (`i'==16 & `k'==1) {
				
	            	display in yellow "EXISTEN DATOS PARCIALES PARA CREAR BASE 20`i'_`k' - COPIANDO DATOS..."

					clear
	            	capture use          "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHC_20`i'_T`z'", clear
			    	capture append using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHC_20`i'_T`w'", force

	            	gen pondera_oficial = pondera
	            	capture gen pondih_original = pondih
	            	compress

	            	capture drop dig* edad hstrt ocupado id hombre nivel gedad1 ghstrt
	            	sort  codusu nro_hogar trimestre componente

	            	save "$path_datain\EPH\Bases Procesadas\Semestrales\EPHC_20`i'_S`k'", replace
	        	}
			}
	        else {
			
	            display in yellow "EXISTEN DATOS PARA CREAR BASE 20`i'_`k' - REPONDERANDO..."

	            use          "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHC_20`i'_T`z'", clear
			    append using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHC_20`i'_T`w'", force
			    duplicates report
			    duplicates drop

				capture summarize pondih
				if (_rc==111) {
					
					clonevar pondih  = pondera
					clonevar pondiio = pondera
					clonevar pondii  = pondera
				}
			    summ   ch04 [w=pondih]	if  trimestre == `z'
			    scalar p_trimestre_a = r(sum_w)

			    summ   ch04 [w=pondih]	if  trimestre == `w'
			    scalar p_trimestre_b = r(sum_w)

			    scalar p_trimestre = (p_trimestre_a+p_trimestre_b)/2

			    gen pondera_oficial = pondera
	            gen pondih_oficial = pondih
	            gen pondiio_oficial = pondiio
			    gen pondii_oficial = pondii

			    duplicates tag codusu componente nro_hogar aglo, gen(auxiliar) 
			    gen     obs_duplicada = 0
			    replace obs_duplicada = 1    if  auxiliar==1
			    replace pondera = pondera/2  if  obs_duplicada==1
				replace pondih  = pondih/2   if  obs_duplicada==1
				replace pondiio = pondih/2   if  obs_duplicada==1
				replace pondii  = pondih/2   if  obs_duplicada==1
				
			    drop auxiliar

			    * Repondera para llegar al expandido de los aglomerados relevados 
			    summ    ch04 [w=pondih]
			    scalar  p_semestre = r(sum_w)
			    scalar  coef_p = p_trimestre/p_semestre 

			    egen    pondera2 = min(pondera), by(codusu nro_hogar trimestre)
			    replace pondera = pondera2*coef_p
			    replace pondera = round(pondera)

	            egen     pondih2 = min(pondih), by(codusu nro_hogar trimestre)
			    replace  pondih = pondih2*coef_p
			    replace  pondih = round(pondih)

			    egen    pondiio2 = min(pondiio), by(codusu nro_hogar trimestre)
			    replace pondiio = pondiio2*coef_p
			    replace pondiio = round(pondiio)

			    egen     pondii2 = min(pondii), by(codusu nro_hogar trimestre)
			    replace  pondii = pondii2*coef_p
			    replace  pondii = round(pondii)

	            drop pondera2 pondih2 pondiio2 pondii2

				destring p*, replace force

			    compress
			    sort  codusu nro_hogar trimestre componente 
			    save  "$path_datain\EPH\Bases Procesadas\Semestrales\EPHC_20`i'_S`k'", replace
	        }
		}
	}
}