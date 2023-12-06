****************************************************************************************************************************************
*                                 CALCULO DE COEFICIENTE DE GINI POR PROVINCIA - BUCLE PARA TODAS LAS EPH 
****************************************************************************************************************************************

noi display in green "COMENZANDO DO FILE CALCULO GINI"


quietly {
	/*
	************************************** CALCULO GINI PARA CADA EPH, USANDO IPCF MIO Y DE INDEC, Y EXPORTO A MATRIZ
	noi display in yellow "REALIZANDO CALCULOS DE COEFICIENTE DE GINI"
	* Matriz de gini usando las eph puntuales por separado
	foreach dato in $bases_gini {
		
		mat gini_`dato' = J(59,28,.)
			
		mat colnames gini_`dato' = "Año" "Semestre" "Encuesta" "Argentina" "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Cordoba" "Corrientes" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquen" "Rio Negro" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Santiago del Estero" "Tierra del Fuego" "Tucuman" 
	}
	* Matriz de gini appendeando las eph puntuales
	foreach dato in $bases_gini {
		
		mat gini_`dato'_aux = J(6,28,.)
			
		mat colnames gini_`dato'_aux = "Año" "Semestre" "Encuesta" "Argentina" "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Cordoba" "Corrientes" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquen" "Rio Negro" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Santiago del Estero" "Tierra del Fuego" "Tucuman" 
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

			* Relleno las primeras 3 columnas de la matriz de población, con año, semestre y encuesta
			mat poblacion[`fila',1] = `a'
			mat poblacion[`fila',2] = `s'
			if "`e'" == "ephp" mat poblacion[`fila',3] = 1
			if "`e'" == "ephc" mat poblacion[`fila',3] = 2

			* Cálculo el coeficiente de GINI para el país y lo relleno en la columna 4 de la matriz de gini
			gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
			mat gini_`dato'[`fila',4] = r(gini)

			* Cálculo la población y lo relleno en la columna 4 de la matriz de población
			sum pondera [w=pondera] 							/* chequear si esto va con pondera o pondih */
			mat poblacion[`fila',4] = r(sum_w)

			* Calculo el coeficiente de Gini para cada provincia
			levelsof nprov, loc (nprov)
			foreach x in `nprov' {

	            preserve
				keep if nprov == `x'

				gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
				loc col = `x' + 4
				* mat gini_`dato'[`fila',`col'] = `x' 			/* esto no sirve para nada porque la pisa despues, pensar porque lo agregue o si sirve modificar el codigo para que sirva*/
				mat gini_`dato'[`fila',`col'] = r(gini)

				sum pondera [w=pondera]
				mat poblacion[`fila',`col'] = r(sum_w)

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

				mat poblacion_aux[`fila',1] = `y'
				mat poblacion_aux[`fila',2] = `w'
				mat poblacion_aux[`fila',3] = 3

				gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
				mat gini_`dato'_aux[`fila',4] = r(gini)

				sum pondih [w=pondih]
				mat poblacion_aux[`fila',4] = r(sum_w)

				levelsof nprov, loc (nprov)
				foreach x in `nprov' {

					preserve
					keep if nprov == `x'

					gini ipcf_`dato' [w=pondih] if ipcf_`dato' > 0
					loc col = `x' + 4
					mat gini_`dato'_aux[`fila',`col'] = `x' 
					mat gini_`dato'_aux[`fila',`col'] = r(gini)

					sum pondih [w=pondih]
					mat poblacion_aux[`fila',`col'] = r(sum_w)

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
	putexcel set "$path_tables\Poblacion\poblacion.xlsx", sheet("poblacion_aux", replace) modify
	putexcel A1 = matrix(poblacion_aux), colnames
	
	*/
	************************************** CALCULO GINI POR AÑO (PROMEDIO DE LOS 2 SEMETRES)
	
	loc tablas = "gini_m gini_indec gini_m_aux gini_indec_aux poblacion poblacion_aux"
	*loc tablas = "gini_m"

	foreach tab in `tablas' {

		noi display in yellow "GENERANDO BASE DE `tab'"

		if "`tab'" == "gini_m" | "`tab'" == "gini_indec" | "`tab'" == "gini_m_aux" | "`tab'" == "gini_indec_aux"				///
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
		
		save "$path_datain\Gini\\`tab'_intermedia.dta", replace
	}	
		* calculo la media anual
		sort año encuesta nprov
		by año encuesta nprov: egen `tab'_aux = mean (`tab')

		* para el año 2003 tengo que cálcular la media entre dos encuestas distintas (ephp para semestre 1 y 2 y eph continua para semestre 2), entonces calculo nuevamente la media para ese año, y la reemplazo en la variable creada antes
		if "`tab'" == "gini_m" | "`tab'" == "gini_indec" | "`tab'" == "poblacion" {

			sort año nprov
			by año nprov: egen `tab'_aux2 = mean (`tab') 	if año == 2003 & (semestre==1 | semestre==2) /* uso semestre 1, pero es lo mismo usar semestre 3 (correspondiente a la onda 3 de la ephp) ESTO ESTA MAL, NO LO BORRO POR SI ESTOY ENTENDIENDO ALGO MAL AL REVISAR*/ 
			replace `tab'_aux = `tab'_aux2 					if año == 2003
			replace `tab'_aux = `tab' 						if semestre == 3 & año == 2003	/* Queda para calcular al final despues */
			drop `tab'_aux2 
		}

		* me quedo con una observacion por año, prov y encuesta (para las prov que tiene datos tanto en ephp como ephc van a quedar dos observaciones)
		sort año encuesta nprov semestre
		by año encuesta nprov: gen  aux  = _n
		if "`tab'" == "gini_m" | "`tab'" == "gini_indec" | "`tab'" == "poblacion" {
		
			replace aux = 2 if aux == 1 & encuesta == 2 & año == 2003	/* para que uno de los dos datos promediados de 2003 semestre 1 quede con 2 y se elimine*/ 
			replace aux = 1 if aux == 2 & encuesta == 1 & año == 2003	/* para que quede la observación de la onda 3 y no de la onda 1, que ya esta promediada - esto puede cambiar si encuentro que está mal*/
		}
		drop `tab'
		rename `tab'_aux `tab'
		keep if aux==1
		drop aux
		
		save "$path_datain\Gini\\`tab'.dta", replace
		erase "$path_datain\Gini\\`tab'_intermedia.dta"
		

		
	*}

	clear
	foreach tab in `tablas' {

		noi display in yellow "MERGEANDO BASE DE `tab'"

		if "`tab'" == "gini_m" use "$path_datain\Gini\\`tab'.dta", clear
		*if "`tab'" == "gini_indec" | "`tab'" == "poblacion" 																		///
		*merge 1:1 año encuesta nprov semestre using "$path_datain\Gini\\`tab'.dta", gen(_merge_`tab') keepusing(`tab')
		if "`tab'" == "gini_indec" | "`tab'" == "poblacion" 																		///
		merge 1:1 año encuesta nprov semestre using "$path_datain\Gini\\`tab'_intermedia.dta", gen(_merge_`tab') keepusing(`tab')
		*if "`tab'" == "gini_m_aux" | "`tab'" == "gini_indec_aux" | "`tab'" == "poblacion_aux" 										///
		*merge m:1 año nprov using "$path_datain\Gini\\`tab'.dta", gen(_merge_`tab') keepusing(`tab')
		if "`tab'" == "gini_m_aux" | "`tab'" == "gini_indec_aux" | "`tab'" == "poblacion_aux" 										///
		merge m:1 año nprov using "$path_datain\Gini\\`tab'_intermedia.dta", gen(_merge_`tab') keepusing(`tab')
	}
}
exit
	drop _merge*
	replace poblacion 		= round(poblacion)
	replace poblacion_aux 	= round(poblacion_aux)
	

	sort 	año nprov
	by 		año nprov: egen pob_total = sum(poblacion)

	format pob* %20.0fc

	gen pob_part = poblacion / pob_total
	loc gini = "gini_m gini_indec"
	foreach g in `gini' {

		* genero nuevo valor de gini ponderado
		gen `g'_pond = `g' * pob_part
		sort 	año nprov
		by 		año nprov: egen `g'_final = sum(`g'_pond) 
		* reemplazo valores de gini original en aux para años donde aux esta en missing
		replace  `g'_aux = `g'_final if `g'_aux == .
	}
	sort 	año nprov
	by 		año nprov: gen aux = _n
	keep if aux == 1
	order año nprov prov gini_m_final gini_indec_final gini_m_aux gini_indec_aux 
	loc gini = "gini_m_final gini_indec_final gini_m_aux gini_indec_aux"
	foreach g in `gini' {

		replace `g' = . if `g' == 0
	}
	save "$path_datain\Gini\gini_completa.dta", replace

	drop semestre encuesta provincia gini_m gini_indec poblacion poblacion_aux pob_total pob_part gini_m_pond gini_indec_pond aux
	drop if nprov == .
	rename (gini_m_final gini_indec_final) (gini_m gini_indec)

	save "$path_datain\Gini\gini_final.dta", replace
}

 