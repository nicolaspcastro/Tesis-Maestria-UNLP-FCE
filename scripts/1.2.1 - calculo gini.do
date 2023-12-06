****************************************************************************************************************************************
*                                 CALCULO DE COEFICIENTE DE GINI POR PROVINCIA - BUCLE PARA TODAS LAS EPH 
****************************************************************************************************************************************

noi display in green "COMENZANDO DO FILE CALCULO GINI"

* #TODO - Calcular el gini para las regiones
quietly {
	
	************************************** CALCULO GINI PARA CADA EPH, USANDO IPCF MIO Y DE INDEC, Y EXPORTO A MATRIZ
	noi display in yellow "REALIZANDO CALCULOS DE COEFICIENTE DE GINI"
	* Matriz de gini usando las eph puntuales por separado
	foreach dato in $bases_gini {
		
		mat gini_`dato' = J(59,28,.)
			
		mat colnames gini_`dato' = "Año" "Semestre" "Encuesta" "Argentina" "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Cordoba" "Corrientes" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquen" "Rio Negro" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Santiago del Estero" "Tierra del Fuego" "Tucuman" 

		mat gini_`dato'_reg = J(59,9,.)
			
		mat colnames gini_`dato'_reg = "Año" "Semestre" "Encuesta" "Argentina" "pampeana" "cuyo" "nea" "noa" "patagonica"
	}
	* Matriz de gini appendeando las eph puntuales
	foreach dato in $bases_gini {
		
		mat gini_`dato'_aux = J(6,28,.)
			
		mat colnames gini_`dato'_aux = "Año" "Semestre" "Encuesta" "Argentina" "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Cordoba" "Corrientes" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquen" "Rio Negro" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Santiago del Estero" "Tierra del Fuego" "Tucuman"

		mat gini_`dato'_aux_reg = J(6,28,.)
		
		mat colnames gini_`dato'_aux_reg = "Año" "Semestre" "Encuesta" "Argentina" "pampeana" "cuyo" "noa" "nea" "patagonica"
	}
	mat poblacion = J(59,28,.)
	mat colnames poblacion = "Año" "Semestre" "Encuesta" "Argentina" "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Cordoba" "Corrientes" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquen" "Rio Negro" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Santiago del Estero" "Tierra del Fuego" "Tucuman" 

	mat poblacion_aux = J(6,28,.)
	mat colnames poblacion_aux = "Año" "Semestre" "Encuesta" "Argentina" "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Cordoba" "Corrientes" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquen" "Rio Negro" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Santiago del Estero" "Tierra del Fuego" "Tucuman" 

	* Guardo una local con todos los nombres de archivos dta de la carpeta de bases finales
	cd "$path_datain\EPH\Bases Procesadas\Finales"
	fs *.dta

	loc fila = 1
	foreach encuesta in `r(files)' {

		use "$path_datain\EPH\Bases Procesadas\Finales\\`encuesta'", clear

		noi display in yellow "CALCULANDO GINI PARA BASE `encuesta'"
		
		foreach dato in $bases_gini {
			
			* Locales para poner en matriz año, semestre y encuesta (ephp o ephc)
			loc a = substr("`encuesta'",6,4)
			loc s = substr("`encuesta'",12,1)
			loc e = substr("`encuesta'",1,4)

			* Relleno las primeras 3 columnas de la matriz de gini, con año, semestre y encuesta
			mat gini_`dato'[`fila',1] = `a'
			mat gini_`dato'[`fila',2] = `s'
			if "`e'" == "ephp" mat gini_`dato'[`fila',3] = 1	/*  EPH PUNTUAL  */
			if "`e'" == "ephc" mat gini_`dato'[`fila',3] = 2	/*  EPH CONTINUA */

			mat gini_`dato'_reg[`fila',1] = `a'
			mat gini_`dato'_reg[`fila',2] = `s'
			if "`e'" == "ephp" mat gini_`dato'_reg[`fila',3] = 1	/*  EPH PUNTUAL  */
			if "`e'" == "ephc" mat gini_`dato'_reg[`fila',3] = 2	/*  EPH CONTINUA */

			* Relleno las primeras 3 columnas de la matriz de población, con año, semestre y encuesta
			mat poblacion[`fila',1] = `a'
			mat poblacion[`fila',2] = `s'
			if "`e'" == "ephp" mat poblacion[`fila',3] = 1
			if "`e'" == "ephc" mat poblacion[`fila',3] = 2

			* Cálculo el coeficiente de GINI para el país y lo relleno en la columna 4 de la matriz de gini
			gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
			mat gini_`dato'[`fila',4] = r(gini)
			mat gini_`dato'_reg[`fila',4] = r(gini)

			* Cálculo la población y lo relleno en la columna 4 de la matriz de población
			* #REVIEW - chequear si esto va con pondera o pondih
			sum pondera [w=pondera] 							
			mat poblacion[`fila',4] = r(sum_w)

			* Calculo el coeficiente de Gini para cada provincia
			levelsof nprov, loc (nprov)
			foreach x in `nprov' {

	            preserve
				keep if nprov == `x'

				gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
				loc col = `x' + 4
				* #REVIEW mat gini_`dato'[`fila',`col'] = `x' 			/* esto no sirve para nada porque la pisa despues, pensar porque lo agregue o si sirve modificar el codigo para que sirva*/
				mat gini_`dato'[`fila',`col'] = r(gini)

				sum pondera [w=pondera]
				mat poblacion[`fila',`col'] = r(sum_w)

				restore
				loc ++col
			}
			* Calculo el coeficiente de Gini para cada región
			levelsof nreg, loc (nreg)
			foreach x in `nreg' {

	            preserve
				keep if nreg == `x'

				gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
				loc col = `x' + 4
				mat gini_`dato'_reg[`fila',`col'] = r(gini)

				restore
				loc ++col
			}
		}
		loc ++fila
	}
	putexcel set "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("gini_m", replace) modify
	putexcel A1 = matrix(gini_m), colnames
	putexcel set "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("gini_indec", replace) modify
	putexcel A1 = matrix(gini_indec), colnames

	putexcel set "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("gini_m_reg", replace) modify
	putexcel A1 = matrix(gini_m_reg), colnames
	putexcel set "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("gini_indec_reg", replace) modify
	putexcel A1 = matrix(gini_indec_reg), colnames

	putexcel set "$path_tables\Poblacion\poblacion.xlsx", sheet("poblacion", replace) modify
	putexcel A1 = matrix(poblacion), colnames

	* Hago lo mismo, pero appendeando las bases de 2003 a 2006 puntuales a las continuas
	loc fila = 1
	forvalues y = 2003/2006 {
		forvalues w = 1/2 {

			capture use "$path_datain\EPH\Bases Procesadas\Finales\EPHC_`y'_s`w'_proc", clear

			if _rc != 0 continue
			loc z = `w' + 1
			if `w' == 1 append using "$path_datain\EPH\Bases Procesadas\Finales\EPHP_`y'_O`w'_proc", force
			if `y' == 2006 & `w' == 2 continue
			if `w' == 2 append using "$path_datain\EPH\Bases Procesadas\Finales\EPHP_`y'_O`z'_proc", force

			noi display in yellow "CALCULANDO GINI AUXILIAR PARA BASE `y' `w'"

			foreach dato in $bases_gini {

				mat gini_`dato'_aux[`fila',1] = `y'
				mat gini_`dato'_aux[`fila',2] = `w'
				mat gini_`dato'_aux[`fila',3] = 3

				mat gini_`dato'_aux_reg[`fila',1] = `y'
				mat gini_`dato'_aux_reg[`fila',2] = `w'
				mat gini_`dato'_aux_reg[`fila',3] = 3

				mat poblacion_aux[`fila',1] = `y'
				mat poblacion_aux[`fila',2] = `w'
				mat poblacion_aux[`fila',3] = 3

				gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
				mat gini_`dato'_aux[`fila',4] = r(gini)
				mat gini_`dato'_aux_reg[`fila',4] = r(gini)

				sum pondih [w=pondih]
				mat poblacion_aux[`fila',4] = r(sum_w)

				* gini por provincia
				levelsof nprov, loc (nprov)
				foreach x in `nprov' {

					preserve
					keep if nprov == `x'

					gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
					loc col = `x' + 4
					*mat gini_`dato'_aux[`fila',`col'] = `x' 
					mat gini_`dato'_aux[`fila',`col'] = r(gini)

					sum pondih [w=pondih]
					mat poblacion_aux[`fila',`col'] = r(sum_w)

					restore
					loc ++col
				}

				* gini por region
				levelsof nreg, loc (nreg)
				foreach x in `nreg' {

					preserve
					keep if nreg == `x'

					gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
					loc col = `x' + 4
					*mat gini_`dato'_aux_reg[`fila',`col'] = `x' 
					mat gini_`dato'_aux_reg[`fila',`col'] = r(gini)

					restore
					loc ++col
				}
			}
			loc ++fila
		}
	}
	putexcel set "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("gini_m_aux", replace) modify
	putexcel A1 = matrix(gini_m_aux), colnames
	putexcel set "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("gini_indec_aux", replace) modify
	putexcel A1 = matrix(gini_indec_aux), colnames

	putexcel set "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("gini_m_aux_reg", replace) modify
	putexcel A1 = matrix(gini_m_aux_reg), colnames
	putexcel set "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("gini_indec_aux_reg", replace) modify
	putexcel A1 = matrix(gini_indec_aux_reg), colnames

	putexcel set "$path_tables\Poblacion\poblacion.xlsx", sheet("poblacion_aux", replace) modify
	putexcel A1 = matrix(poblacion_aux), colnames
	
	
	************************************** CALCULO GINI POR AÑO (PROMEDIO DE LOS 2 SEMESTRES) PARA CADA PROVINCIA
	*********** MERGE DE BASES
	loc tablas = "gini_m gini_indec gini_m_aux gini_indec_aux poblacion poblacion_aux"
	*loc tablas = "gini_m"

	foreach tab in `tablas' {

		noi display in yellow "GENERANDO BASE DE `tab'"

		if "`tab'" == "gini_m" | "`tab'" == "gini_indec" | "`tab'" == "gini_m_aux" | "`tab'" == "gini_indec_aux" 				///
		import excel "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("`tab'") firstrow case(lower) clear

		if "`tab'" == "poblacion" | "`tab'" == "poblacion_aux"																	///
		import excel "$path_tables\Poblacion\poblacion.xlsx", sheet("`tab'") firstrow case(lower) clear

		loc prov = "argentina buenosaires catamarca chaco chubut ciudadautonomadeba cordoba corrientes entreríos formosa jujuy lapampa larioja mendoza misiones neuquen rionegro salta sanjuan sanluis santacruz santafe santiagodelestero tierradelfuego tucuman"
		 
		foreach p in `prov' {
			
			preserve

			keep año semestre encuesta `p'
			rename `p' `tab'
			gen provincia = "`p'"

			save "$path_datain\Gini\Auxiliares\\`tab'_`p'.dta", replace

			restore
		}
		clear
		foreach p in `prov' {

			append using "$path_datain\Gini\Auxiliares\\`tab'_`p'.dta"
			erase "$path_datain\Gini\Auxiliares\\`tab'_`p'.dta"
		}

		gen prov=""
		replace prov = "Buenos Aires"               if provincia == "buenosaires"
		replace prov = "Catamarca"                  if provincia == "catamarca"
		replace prov = "Chaco"                      if provincia == "chaco"
		replace prov = "Chubut"                     if provincia == "chubut"
		replace prov = "Ciudad Autonoma de BA"      if provincia == "ciudadautonomadeba"
		replace prov = "Cordoba"                    if provincia == "cordoba"
		replace prov = "Corrientes"                 if provincia == "corrientes"
		replace prov = "Entre Rios"                 if provincia == "entreríos"
		replace prov = "Formosa"                    if provincia == "formosa"
		replace prov = "Jujuy"                      if provincia == "jujuy"
		replace prov = "La Pampa"                   if provincia == "lapampa"
		replace prov = "La Rioja"                   if provincia == "larioja"
		replace prov = "Mendoza"                    if provincia == "mendoza"
		replace prov = "Misiones"                   if provincia == "misiones"
		replace prov = "Neuquen"                    if provincia == "neuquen"
		replace prov = "Rio Negro"                  if provincia == "rionegro"
		replace prov = "Salta"                      if provincia == "salta"
		replace prov = "San Juan"                   if provincia == "sanjuan"
		replace prov = "San Luis"                   if provincia == "sanluis"
		replace prov = "Santa Cruz"                 if provincia == "santacruz"
		replace prov = "Santa Fe"                   if provincia == "santafe"
		replace prov = "Santiago del Estero"        if provincia == "santiagodelestero"
		replace prov = "Tierra del Fuego"           if provincia == "tierradelfuego"
		replace prov = "Tucuman"                    if provincia == "tucuman"
		replace prov = "Argentina"					if provincia == "argentina"

		gen nprov=.
		replace nprov=1     if prov=="Buenos Aires" 
		replace nprov=5     if prov=="Ciudad Autonoma de BA"
		replace nprov=6     if prov=="Cordoba" 
		replace nprov=21    if prov=="Santa Fe" 
		replace nprov=11    if prov=="La Pampa" 
		replace nprov=13    if prov=="Mendoza" 
		replace nprov=18    if prov=="San Juan"  
		replace nprov=19    if prov=="San Luis" 
		replace nprov=3     if prov=="Chaco"   
		replace nprov=7     if prov=="Corrientes"  
		replace nprov=8     if prov=="Entre Rios" 
		replace nprov=9     if prov=="Formosa"  
		replace nprov=14    if prov=="Misiones"  
		replace nprov=2     if prov=="Catamarca" 
		replace nprov=10    if prov=="Jujuy" 
		replace nprov=12    if prov=="La Rioja" 
		replace nprov=17    if prov=="Salta" 
		replace nprov=22    if prov=="Santiago del Estero" 
		replace nprov=24    if prov=="Tucuman" 
		replace nprov=16    if prov=="Rio Negro" 
		replace nprov=15    if prov=="Neuquen" 
		replace nprov=4     if prov=="Chubut" 
		replace nprov=20    if prov=="Santa Cruz" 
		replace nprov=23    if prov=="Tierra del Fuego"
		
		save "$path_datain\Gini\\`tab'.dta", replace
	}

	clear
	foreach tab in `tablas' {

		noi display in yellow "MERGEANDO BASE DE `tab'"

		if "`tab'" == "gini_m" use "$path_datain\Gini\\`tab'.dta", clear
		if "`tab'" == "gini_indec" | "`tab'" == "poblacion" 																		///
		merge 1:1 año encuesta nprov semestre using "$path_datain\Gini\\`tab'.dta", gen(_merge_`tab') keepusing(`tab')
		if "`tab'" == "gini_m_aux" | "`tab'" == "gini_indec_aux" | "`tab'" == "poblacion_aux" 										///
		merge m:1 año nprov semestre using "$path_datain\Gini\\`tab'.dta", gen(_merge_`tab') keepusing(`tab')
		
	}
	drop _merge*
	replace poblacion 		= round(poblacion)
	replace poblacion_aux 	= round(poblacion_aux)
	
	*********** GINI COMÚN
		
	* Calulo la media anual del gini de los dos semestres para todos los años y la población total
	sort año nprov
	by año nprov: egen gini_m_mean = mean(gini_m)
	by año nprov: egen gini_indec_mean = mean(gini_indec)
	
	sort año nprov
	by año nprov: egen poblacion_final = mean(poblacion)
	
	* Calculo diferencial para los años 2003, 2004, 2005 y 2006 donde se mezclan las encuestas puntales y continuas
	
	loc diferenciales = "2003 2004 2005 2006"
	foreach dif in `diferenciales'{
		if `dif' == 2003 {
			
			* Genero una variable nueva de semestre para este año en particular, y luego reemplazo el semestre 3 (que viene de eph puntual)
			* por 2, para poder calcular las medias
			gen semestre_`dif' = semestre if año == `dif'
			replace semestre_`dif' = 2 if semestre_`dif' == 3
			
			* Genero por año, semestre y provincia la suma de la población (aca se mezclarían las encuestas puntuales y continuas para las que
			* hay datos en ambas encuestas). Luego calculo la participación para el gini ponderado
			sort año semestre_`dif' nprov 
			by año semestre_`dif' nprov: egen poblacion_sum_`dif' = sum(poblacion)
			gen poblacion_part_`dif' = poblacion / poblacion_sum_`dif' if año == `dif'

			* Además, calculo la población promedio de las 2 poblaciones sumadas (uso encuesta porque sino tengro tres datos para promediar)
			sort año encuesta nprov
			by año encuesta nprov: egen poblacion_final_`dif' = mean(poblacion_sum_`dif') 
			replace poblacion_final = poblacion_final_`dif' if año == `dif'

			loc gini = "gini_m gini_indec"
			foreach g in `gini' {
				
				* Para cada gini, genero una variable especifica para ese año igual al gini original, luego para el semestre 2, donde se superponen
				* las encuestas reemplazo por el gini por la ponderación. Por último, calculo la suma de esos ginis poderados
				gen `g'_`dif' = `g' if año == `dif' 
				replace `g'_`dif' = `g' * poblacion_part_`dif' if año == `dif' & semestre_`dif' == 2
				sort año semestre_`dif' nprov
				by año semestre_`dif' nprov: egen `g'_sum_`dif' = sum(`g'_`dif')

				* Para finalizar este año, calculo la media de los ginis de los dos semestres. Al haber 3 datos, tomo el promedio de la encuesta
				* Así toma dos valores (chequeado que queda bien). Luego reemplazo el valor de gini_mean por el nuevo gini ponderado
				sort año encuesta nprov 
				by año encuesta nprov: egen `g'_mean_`dif' = mean(`g'_sum_`dif')
				replace `g'_mean = `g'_mean_`dif' if año == `dif'
				
			}
		}
		
		if (`dif' == 2004 | `dif' == 2005) {
			
			* Idem a 2003, pero al tener 2 valores por semestre es más directo
			gen semestre_`dif' = semestre if año == `dif'
			replace semestre_`dif' = 2 if semestre_`dif' == 3
			
			sort año semestre_`dif' nprov 
			by año semestre_`dif' nprov: egen poblacion_sum_`dif' = sum(poblacion)
			gen poblacion_part_`dif' = poblacion / poblacion_sum_`dif' if año == `dif'
			* Deberían quedar los 4 datos con la misma población final, porque por más que se haga de a pares, toma la poblacion sumada para el 
			* semestre
			sort año nprov
			by año nprov: egen poblacion_final_`dif' = mean(poblacion_sum_`dif')
			replace poblacion_final = poblacion_final_`dif' if año == `dif'

			loc gini = "gini_m gini_indec"
			foreach g in `gini' {
					
				gen `g'_`dif' = `g' * poblacion_part_`dif' if año == `dif'
				sort año semestre_`dif' nprov
				by año semestre_`dif' nprov: egen `g'_sum_`dif' = sum(`g'_`dif')

				sort año encuesta nprov 
				by año encuesta nprov: egen `g'_mean_`dif' = mean(`g'_sum_`dif')
				replace `g'_mean = `g'_mean_`dif' if año == `dif'
				
			}
		}
		
		if `dif' == 2006 {
			
			* Calculo la variable de semestre especifica para este año
			gen semestre_`dif' = semestre if año == `dif'
			
			* Calculo la población sumada para cada semestre y la participación
			sort año semestre_`dif' nprov 
			by año semestre_`dif' nprov: egen poblacion_sum_`dif' = sum(poblacion)
			gen poblacion_part_`dif' = poblacion / poblacion_sum_`dif' if año == `dif'
			
			* Calculo la población promedio, uso encuesta porque tengo tres datos
			sort año encuesta nprov
			by año encuesta nprov: egen poblacion_final_`dif' = mean(poblacion_sum_`dif')
			replace poblacion_final = poblacion_final_`dif' if año == `dif'	

			loc gini = "gini_m gini_indec"
			foreach g in `gini' {
				
				* Creo la variable gini del año igual al valor original, y luego lo cambio para el valor del gini por la ponderación para el 
				* semestre 1 donde se solapan las encuestas
				gen `g'_`dif' = `g' if año == `dif' 
				replace `g'_`dif' = `g' * poblacion_part_`dif' if año == `dif' & semestre_`dif' == 1
				* Genero el gini promedio ponderado como la suma de los dos ginis del semestre
				sort año semestre_`dif' nprov
				by año semestre_`dif' nprov: egen `g'_sum_`dif' = sum(`g'_`dif')

				* Genero el gini promedio por encuesta. El problema aca es que el contador de observaciones me queda con un 1 en una observacion
				* que no tiene  bien el gini promedio del año (porque es la encuesta 1). Lo había solucionado modificandole el valor del gini,
				* pero lo cambie a modificar el contador de observaciones, así no modifico datos
				sort año encuesta nprov 
				by año encuesta nprov: egen `g'_mean_`dif' = mean(`g'_sum_`dif')
				replace `g'_mean = `g'_mean_`dif' if año == `dif'
			}
		}
	}
	

	*********** GINI AUXILIAR

	* Genero una nueva variable de gini. Esta va a ser igual a al gini común para todos los años, menos para los que se solapan las encuestas
	loc vars = "gini_m gini_indec poblacion"
	
	foreach v in `vars' {
	
		gen `v'_alt = `v'
		replace `v'_alt = `v'_aux if (año == 2003 & semestre != 1) | (año == 2004) | (año == 2005) | (año == 2006 & semestre != 2) 
		replace `v'_alt = . if (año == 2004 & semestre == 1 & encuesta == 1) | (año == 2005 & semestre == 1 & encuesta == 1) ///
								|(año == 2006 & semestre == 1 & encuesta == 1)
	}

	sort año nprov
	by año nprov: egen gini_m_alt_mean = mean(gini_m_alt)
	by año nprov: egen gini_indec_alt_mean = mean(gini_indec_alt)
	by año nprov: egen poblacion_alt_mean = mean(poblacion_alt)

	*********** GUARDADO DE BASE PARA MERGEAR

	* Genero un contador de observaciones por año y nprov, para quedarme solo con una observación. 
	sort año nprov encuesta semestre
	by año nprov: gen identificador = _n
	format pob* %20.0fc
	* Reemplazo el valor del contador para el año 2006, para que quede con 1 un valor que me sirva
	replace identificador = identificador - 1 if año == 2006

	* Nos quedamos con un valor por año y provincia y borro variables
	keep if identificador == 1
	
	save "$path_datain\Gini\gini_completa.dta", replace

	keep año prov nprov gini_m_mean gini_indec_mean gini_m_alt_mean gini_indec_alt_mean poblacion_final poblacion_alt_mean

	rename (poblacion_final poblacion_alt_mean gini_m_mean gini_indec_mean gini_m_alt_mean gini_indec_alt_mean) 				///
			(poblacion_eph poblacion_alt_eph gini_m_sa gini_indec_sa gini_m_ca gini_indec_ca)


	label var poblacion_eph 		"Población total EPH"
	label var poblacion_alt_eph 	"Población total EPH agregada"
	label var gini_m_sa 			"Coeficiente de Gini sin append"
	label var gini_indec_sa 		"Coeficiente de Gini sin append"
	label var gini_m_ca 			"Coeficiente de Gini con append"
	label var gini_indec_ca 		"Coeficiente de Gini con append"

	noi display in yellow "GUARDANDO BASE DE GINI PARA MERGEAR"
	save "$path_datain\Gini\gini_final_merge.dta", replace

	/*

	* #TODO  TERMINARLO EN ALGUN MOMENTO
	************************************** CALCULO GINI POR AÑO (PROMEDIO DE LOS 2 SEMESTRES) PARA CADA REGION
	*********** MERGE DE BASES
	loc tablas = "gini_m_reg gini_indec_reg gini_m_aux_reg gini_indec_aux_reg"
	*loc tablas = "gini_m"

	foreach tab in `tablas' {

		noi display in yellow "GENERANDO BASE DE `tab'"

		import excel "$path_tables\Coeficiente de Gini\gini.xlsx", sheet("`tab'") firstrow case(lower) clear

		loc region = "argentina pampeana cuyo nea noa patagonica"
		 
		foreach p in `region' {
			
			preserve

			keep año semestre encuesta `p'
			rename `p' `tab'
			gen region = "`p'"

			save "$path_datain\Gini\Auxiliares\\`tab'_`p'.dta", replace

			restore
		}
		clear
		foreach p in `region' {

			append using "$path_datain\Gini\Auxiliares\\`tab'_`p'.dta"
			erase "$path_datain\Gini\Auxiliares\\`tab'_`p'.dta"
		}

		gen nreg=.
		replace nreg=1     	if region=="pampeana" 
		replace nreg=2     	if region=="cuyo"
		replace nreg=3     	if region=="nea" 
		replace nreg=4    	if region=="noa" 
		replace nreg=5    	if region=="patagonica"
		
		save "$path_datain\Gini\\`tab'.dta", replace
	}

	clear
	foreach tab in `tablas' {

		noi display in yellow "MERGEANDO BASE DE `tab'"

		if "`tab'" == "gini_m_reg" use "$path_datain\Gini\\`tab'.dta", clear
		if "`tab'" == "gini_indec_reg" 						 																		///
		merge 1:1 año encuesta nprov semestre using "$path_datain\Gini\\`tab'.dta", gen(_merge_`tab') keepusing(`tab')
		if "`tab'" == "gini_m_aux_reg" | "`tab'" == "gini_indec_aux_reg" 					 										///
		merge m:1 año nprov semestre using "$path_datain\Gini\\`tab'.dta", gen(_merge_`tab') keepusing(`tab')
		
	}
	drop _merge*
	
	* #REVIEW: HASTA ACA DEBERÍA ESTAR OK, FALTA LO SIGUIENTE
	*********** GINI COMÚN
		
	* Calulo la media anual del gini de los dos semestres para todos los años y la población total
	sort año nreg
	by año nreg: egen gini_m_mean = mean(gini_m)
	by año nreg: egen gini_indec_mean = mean(gini_indec)
	
	sort año nreg
	by año nreg: egen poblacion_final = mean(poblacion)
	
	* Calculo diferencial para los años 2003, 2004, 2005 y 2006 donde se mezclan las encuestas puntales y continuas
	
	loc diferenciales = "2003 2004 2005 2006"
	foreach dif in `diferenciales'{
		if `dif' == 2003 {
			
			* Genero una variable nueva de semestre para este año en particular, y luego reemplazo el semestre 3 (que viene de eph puntual)
			* por 2, para poder calcular las medias
			gen semestre_`dif' = semestre if año == `dif'
			replace semestre_`dif' = 2 if semestre_`dif' == 3
			
			* Genero por año, semestre y provincia la suma de la población (aca se mezclarían las encuestas puntuales y continuas para las que
			* hay datos en ambas encuestas). Luego calculo la participación para el gini ponderado
			sort año semestre_`dif' nreg 
			by año semestre_`dif' nreg: egen poblacion_sum_`dif' = sum(poblacion)
			gen poblacion_part_`dif' = poblacion / poblacion_sum_`dif' if año == `dif'

			* Además, calculo la población promedio de las 2 poblaciones sumadas (uso encuesta porque sino tengro tres datos para promediar)
			sort año encuesta nreg
			by año encuesta nreg: egen poblacion_final_`dif' = mean(poblacion_sum_`dif') 
			replace poblacion_final = poblacion_final_`dif' if año == `dif'

			loc gini = "gini_m gini_indec"
			foreach g in `gini' {
				
				* Para cada gini, genero una variable especifica para ese año igual al gini original, luego para el semestre 2, donde se superponen
				* las encuestas reemplazo por el gini por la ponderación. Por último, calculo la suma de esos ginis poderados
				gen `g'_`dif' = `g' if año == `dif' 
				replace `g'_`dif' = `g' * poblacion_part_`dif' if año == `dif' & semestre_`dif' == 2
				sort año semestre_`dif' nreg
				by año semestre_`dif' nreg: egen `g'_sum_`dif' = sum(`g'_`dif')

				* Para finalizar este año, calculo la media de los ginis de los dos semestres. Al haber 3 datos, tomo el promedio de la encuesta
				* Así toma dos valores (chequeado que queda bien). Luego reemplazo el valor de gini_mean por el nuevo gini ponderado
				sort año encuesta nreg 
				by año encuesta nreg: egen `g'_mean_`dif' = mean(`g'_sum_`dif')
				replace `g'_mean = `g'_mean_`dif' if año == `dif'
				
			}
		}
		
		if (`dif' == 2004 | `dif' == 2005) {
			
			* Idem a 2003, pero al tener 2 valores por semestre es más directo
			gen semestre_`dif' = semestre if año == `dif'
			replace semestre_`dif' = 2 if semestre_`dif' == 3
			
			sort año semestre_`dif' nreg 
			by año semestre_`dif' nreg: egen poblacion_sum_`dif' = sum(poblacion)
			gen poblacion_part_`dif' = poblacion / poblacion_sum_`dif' if año == `dif'
			* Deberían quedar los 4 datos con la misma población final, porque por más que se haga de a pares, toma la poblacion sumada para el 
			* semestre
			sort año nreg
			by año nreg: egen poblacion_final_`dif' = mean(poblacion_sum_`dif')
			replace poblacion_final = poblacion_final_`dif' if año == `dif'

			loc gini = "gini_m gini_indec"
			foreach g in `gini' {
					
				gen `g'_`dif' = `g' * poblacion_part_`dif' if año == `dif'
				sort año semestre_`dif' nreg
				by año semestre_`dif' nreg: egen `g'_sum_`dif' = sum(`g'_`dif')

				sort año encuesta nreg 
				by año encuesta nreg: egen `g'_mean_`dif' = mean(`g'_sum_`dif')
				replace `g'_mean = `g'_mean_`dif' if año == `dif'
				
			}
		}
		
		if `dif' == 2006 {
			
			* Calculo la variable de semestre especifica para este año
			gen semestre_`dif' = semestre if año == `dif'
			
			* Calculo la población sumada para cada semestre y la participación
			sort año semestre_`dif' nreg 
			by año semestre_`dif' nreg: egen poblacion_sum_`dif' = sum(poblacion)
			gen poblacion_part_`dif' = poblacion / poblacion_sum_`dif' if año == `dif'
			
			* Calculo la población promedio, uso encuesta porque tengo tres datos
			sort año encuesta nreg
			by año encuesta nreg: egen poblacion_final_`dif' = mean(poblacion_sum_`dif')
			replace poblacion_final = poblacion_final_`dif' if año == `dif'	

			loc gini = "gini_m gini_indec"
			foreach g in `gini' {
				
				* Creo la variable gini del año igual al valor original, y luego lo cambio para el valor del gini por la ponderación para el 
				* semestre 1 donde se solapan las encuestas
				gen `g'_`dif' = `g' if año == `dif' 
				replace `g'_`dif' = `g' * poblacion_part_`dif' if año == `dif' & semestre_`dif' == 1
				* Genero el gini promedio ponderado como la suma de los dos ginis del semestre
				sort año semestre_`dif' nreg
				by año semestre_`dif' nreg: egen `g'_sum_`dif' = sum(`g'_`dif')

				* Genero el gini promedio por encuesta. El problema aca es que el contador de observaciones me queda con un 1 en una observacion
				* que no tiene  bien el gini promedio del año (porque es la encuesta 1). Lo había solucionado modificandole el valor del gini,
				* pero lo cambie a modificar el contador de observaciones, así no modifico datos
				sort año encuesta nreg 
				by año encuesta nreg: egen `g'_mean_`dif' = mean(`g'_sum_`dif')
				replace `g'_mean = `g'_mean_`dif' if año == `dif'
			}
		}
	}
	

	*********** GINI AUXILIAR

	* Genero una nueva variable de gini. Esta va a ser igual a al gini común para todos los años, menos para los que se solapan las encuestas
	loc vars = "gini_m gini_indec poblacion"
	
	foreach v in `vars' {
	
		gen `v'_alt = `v'
		replace `v'_alt = `v'_aux if (año == 2003 & semestre != 1) | (año == 2004) | (año == 2005) | (año == 2006 & semestre != 2) 
		replace `v'_alt = . if (año == 2004 & semestre == 1 & encuesta == 1) | (año == 2005 & semestre == 1 & encuesta == 1) ///
								|(año == 2006 & semestre == 1 & encuesta == 1)
	}

	sort año nreg
	by año nreg: egen gini_m_alt_mean = mean(gini_m_alt)
	by año nreg: egen gini_indec_alt_mean = mean(gini_indec_alt)
	by año nreg: egen poblacion_alt_mean = mean(poblacion_alt)

	*********** GUARDADO DE BASE PARA MERGEAR

	* Genero un contador de observaciones por año y nreg, para quedarme solo con una observación. 
	sort año nreg encuesta semestre
	by año nreg: gen identificador = _n
	format pob* %20.0fc
	* Reemplazo el valor del contador para el año 2006, para que quede con 1 un valor que me sirva
	replace identificador = identificador - 1 if año == 2006

	* Nos quedamos con un valor por año y provincia y borro variables
	keep if identificador == 1
	
	save "$path_datain\Gini\gini_completa.dta", replace

	keep año prov nreg gini_m_mean gini_indec_mean gini_m_alt_mean gini_indec_alt_mean poblacion_final poblacion_alt_mean

	rename (poblacion_final poblacion_alt_mean gini_m_mean gini_indec_mean gini_m_alt_mean gini_indec_alt_mean) 				///
			(poblacion_eph poblacion_alt_eph gini_m_sa gini_indec_sa gini_m_ca gini_indec_ca)


	label var poblacion_eph 		"Población total EPH"
	label var poblacion_alt_eph 	"Población total EPH agregada"
	label var gini_m_sa 			"Coeficiente de Gini sin append"
	label var gini_indec_sa 		"Coeficiente de Gini sin append"
	label var gini_m_ca 			"Coeficiente de Gini con append"
	label var gini_indec_ca 		"Coeficiente de Gini con append"

	noi display in yellow "GUARDANDO BASE DE GINI PARA MERGEAR"
	save "$path_datain\Gini\gini_final_merge.dta", replace
}


 



		