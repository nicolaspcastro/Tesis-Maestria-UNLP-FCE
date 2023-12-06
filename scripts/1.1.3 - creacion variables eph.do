****************************************************************************************************************************************
*                                               CREACIÓN DE VARIABLES EN EPH
****************************************************************************************************************************************

quietly {
	noi display in green "COMENZANDO DO FILE CREACIÓN VARIABLES EPH"
	**************************************************************************************************************************************
	*                                               EPH CONTINUA
	**************************************************************************************************************************************

	foreach i in $año_continua {
		foreach k in $semestre {

			*Apertura de Bases*

			clear
			capture use "$path_datain\EPH\Bases Procesadas\Semestrales\EPHC_20`i'_S`k'", clear

			if _rc==601{

	    		noi display in red "NO EXISTE BASE 20`i'_S`k' - PASANDO A SIGUIENTE BASE..."
		    }

	    	if _rc!=601 {

				noi display in yellow "EXISTE BASE 20`i'_S`k' - CREANDO VARIABLES NECESARIAS..."

				*Provincias*

				generate prov=""
				label variable prov "Nombre Provincia"
				
				replace prov="Buenos Aires" 		 if aglomerado==2 | aglomerado==3 | aglomerado==33 | aglomerado==34 | aglomerado==38 
				replace prov="Ciudad Autonoma de BA" if aglomerado==32 
				replace prov="Cordoba" 				 if aglomerado==13 | aglomerado==36  
				replace prov="Santa Fe" 			 if aglomerado==4 | aglomerado==5 
				replace prov="La Pampa" 			 if aglomerado==30

				replace prov="Mendoza" 				 if aglomerado==10 
				replace prov="San Juan" 			 if aglomerado==27  
				replace prov="San Luis" 			 if aglomerado==26

				replace prov="Chaco" 				 if aglomerado==8  
				replace prov="Corrientes" 			 if aglomerado==12  
				replace prov="Entre Rios" 			 if aglomerado==6 | aglomerado==14 
				replace prov="Formosa" 				 if aglomerado==15  
				replace prov="Misiones" 			 if aglomerado==7  

				replace prov="Catamarca" 			 if aglomerado==22
				replace prov="Jujuy" 				 if aglomerado==19
				replace prov="La Rioja" 			 if aglomerado==25
				replace prov="Salta" 				 if aglomerado==23
				replace prov="Santiago del Estero" 	 if aglomerado==18 
				replace prov="Tucuman" 				 if aglomerado==29

				replace prov="Rio Negro" 			 if aglomerado==93 
				replace prov="Neuquen" 				 if aglomerado==17
				replace prov="Chubut" 				 if aglomerado==9 | aglomerado==91
				replace prov="Santa Cruz" 			 if aglomerado==20
				replace prov="Tierra del Fuego" 	 if aglomerado==31 
				
				*Codigo de Provincia*

				generate nprov=.
				label variable nprov "Código Provincia"

				replace nprov=1  if prov=="Buenos Aires" 
				replace nprov=5  if prov=="Ciudad Autonoma de BA"
				replace nprov=6  if prov=="Cordoba" 
				replace nprov=21 if prov=="Santa Fe" 
				replace nprov=11 if prov=="La Pampa"

				replace nprov=13 if prov=="Mendoza" 
				replace nprov=18 if prov=="San Juan"  
				replace nprov=19 if prov=="San Luis"

				replace nprov=3  if prov=="Chaco"   
				replace nprov=7  if prov=="Corrientes"  
				replace nprov=8  if prov=="Entre Rios" 
				replace nprov=9  if prov=="Formosa"  
				replace nprov=14 if prov=="Misiones"

				replace nprov=2  if prov=="Catamarca" 
				replace nprov=10 if prov=="Jujuy" 
				replace nprov=12 if prov=="La Rioja" 
				replace nprov=17 if prov=="Salta" 
				replace nprov=22 if prov=="Santiago del Estero" 
				replace nprov=24 if prov=="Tucuman"

				replace nprov=16 if prov=="Rio Negro" 
				replace nprov=15 if prov=="Neuquen" 
				replace nprov=4  if prov=="Chubut" 
				replace nprov=20 if prov=="Santa Cruz" 
				replace nprov=23 if prov=="Tierra del Fuego" 
				
				*Ponderadores*

				local pondera="pondii pondih pondiio"
				foreach pond in `pondera' {

					capture summarize `pond'
					if (_rc==111) clonevar `pond'=pondera
				}

				*Identificador del hogar*

				sort codusu nro_hogar
				egen id=group(codusu nro_hogar)

				label variable id "Identificador del hogar"

				*Año*

				generate año=ano4

				label variable año "Año"

				*Relación de parentesco*

				generate relacion=.
				replace relacion=1 if (ch03==1)
				replace relacion=2 if (ch03==2)
				replace relacion=3 if (ch03==3)
				replace relacion=4 if (ch03==6 | ch03==7)
				replace relacion=5 if (ch03==4 | ch03==5 | ch03==8 | ch03==9)
				replace relacion=6 if (ch03==10 | (nro_hogar>=51 & nro_hogar<=71) | componente==51)

				label variable relacion "Relación de parentesco"
				label define   relacion	1 "Jefe/a" 2 "Cónyuge / Pareja" 3 "Hijo/a / Hijastro/a" 								///
										4 "Madre / Padre - Suegro/a" 5 "Yerno/Nuera - Nieto/a - Hermano/a - Otros Familiares" 	///
										6 "No Familiares - Servicio doméstico / Pensionistas"
				label values   relacion relacion

				*Relación de parentesco estandarizada*

				generate relacion_est=""
				replace relacion_est=" 1 - Jefe/a                           " if (ch03==1)
				replace relacion_est=" 2 - Cónyuge / Pareja                 " if (ch03==2)
				replace relacion_est=" 3 - Hijo/a / Hijastro/a              " if (ch03==3)
				replace relacion_est=" 4 - Yerno/Nuera                      " if (ch03==4)
				replace relacion_est=" 5 - Nieto/a                          " if (ch03==5)
				replace relacion_est=" 6 - Madre / Padre                    " if (ch03==6)
				replace relacion_est=" 7 - Suegro/a                         " if (ch03==7)
				replace relacion_est=" 8 - Hermano/a                        " if (ch03==8)
				replace relacion_est=" 9 - Otros Familiares                 " if (ch03==9)
				replace relacion_est="10 - No Familiares                    " if (ch03==10)
				replace relacion_est="11 - Servicio doméstico / Pensionistas" if ((nro_hogar>=51 & nro_hogar<=71) | componente==51)

				encode relacion_est, generate(aux)
				drop relacion_est
				rename aux relacion_est

				label variable relacion_est "Relación de parentesco estandarizada"

				*Miembros de hogares secundarios*

				generate hogar_sec=0
				replace hogar_sec=1 if (relacion_est==11)

				label variable hogar_sec "=1 si miembro de un hogar secundario"
				label define   hogar_sec 0 "Miembro de un hogar principal" 1 "Miembro de un hogar secundario"
				label values   hogar_sec hogar_sec

				*Número de miembros del hogar principal*

				generate aux=1
				egen miembros=sum(aux) if (hogar_sec==0 & relacion!=.), by(id)
				drop aux

				label variable miembros "Número de miembros del hogar principal"

				*Identifica al jefe de hogar*

				generate jefe=1 if (relacion==1)
				replace jefe=0 if (relacion!=1)
				replace jefe=. if (relacion==. | hogar_sec==1)

				label variable jefe "=1 si jefe de hogar"
				label define   jefe 0 "No jefe de hogar" 1 "Jefe de hogar"
				label values   jefe jefe

				*Identifica al cónyuge*

				generate conyuge=1 if (relacion==2)
				replace conyuge=0 if (relacion!=2)
				replace conyuge=. if (relacion==. | hogar_sec==1)

				label variable conyuge "=1 si cónyuge"
				label define   conyuge 0 "No cónyuge" 1 "Cónyuge"
				label values   conyuge conyuge

				*Identifica a los hijos del hogar principal*

				generate hijo=1 if (relacion==3)
				replace hijo=0 if (relacion!=3)
				replace hijo=. if (relacion==. | hogar_sec==1)

				label variable hijo "=1 si hijo"
				label define   hijo 0 "No hijo" 1 "Hijo"
				label values   hijo hijo

				*Número de hijos menores de 18 años en el hogar principal*

				generate aux=1 if (hijo==1 & ch06<18)
				egen double nro_hijos=sum(aux), by(id)
				replace nro_hijos=. if (jefe!=1 & conyuge!=1)
				drop aux

				label variable nro_hijos "Número de hijos menores de 18 años en el hogar principal"

				*Edad*

				generate edad=ch06
				replace edad=0 if (edad==-1)
				replace edad=. if (edad==99)

				generate edad2=edad*edad

				label variable edad  "Edad"
				label variable edad2 "Edad al cuadrado"

				*Grupos de edad*

				generate g_edad_1=.
				replace g_edad_1=1 if (edad>=0 & edad<=17)
				replace g_edad_1=2 if (edad>=18 & edad<=64)
				replace g_edad_1=3 if (edad>=65 & edad!=.)

				generate g_edad_2=.
				replace g_edad_2=1 if (edad>=0 & edad<=17)
				replace g_edad_2=2 if (edad>=18 & edad<=40)
				replace g_edad_2=3 if (edad>=41 & edad<=64)
				replace g_edad_2=4 if (edad>=65 & edad!=.)

				generate g_edad_3=.
				replace g_edad_3=1 if (edad>=0 & edad<=17)
				replace g_edad_3=2 if (edad>=18 & edad<=24)
				replace g_edad_3=3 if (edad>=25 & edad<=40)
				replace g_edad_3=4 if (edad>=41 & edad<=64)
				replace g_edad_3=5 if (edad>=65 & edad!=.)

				label variable g_edad_1 "Grupos de edad 1"
				label define   g_edad_1 1 "[0,17]" 2 "[18,64]" 3 "[65+]"
				label values   g_edad_1 g_edad_1

				label variable g_edad_2 "Grupos de edad 2"
				label define   g_edad_2 1 "[0,17]" 2 "[18,40]" 3 "[41,64]" 4 "[65+]"
				label values   g_edad_2 g_edad_2

				label variable g_edad_3 "Grupos de edad 3"
				label define   g_edad_3 1 "[0,17]" 2 "[18,24]" 3 "[25,40]"  4 "[41,64]" 5 "[65+]"
				label values   g_edad_3 g_edad_3

				*Género*

				generate hombre=.
				replace hombre=0 if (ch04==2)
				replace hombre=1 if (ch04==1)

				generate genero=.
				replace genero=1 if (hombre==1)
				replace genero=2 if (hombre==0)

				label variable hombre "=1 si hombre"
				label define   hombre 0 "Mujer" 1 "Hombre" 
				label values   hombre hombre

				label variable genero "Género"
				label define   genero 1 "Hombre" 2 "Mujer" 
				label values   genero genero

				*Género jefe de hogar*

				generate aux=.
				replace aux=1 if (genero==1 & jefe==1)
				replace aux=2 if (genero==2 & jefe==1)
				egen genero_jefe=max(aux), by(id)
				drop aux

				label variable genero_jefe "Género jefe de hogar"
				label define   genero_jefe 1 "Jefe hombre" 2 "Jefe mujer"
				label values   genero_jefe genero_jefe

				*Niños en el hogar*

				generate aux=0
				replace aux=1 if (edad<18 & (ch03==3 | ch03==5))
				egen niños=max(aux), by(id)
				drop aux

				label variable niños "=1 si niños en el hogar"
				label define   niños 0 "Hogar sin niños" 1 "Hogar con niños"
				label values   niños niños

				*Género y niños en el hogar*

				generate genero_niños=.
				replace genero_niños=1 if (genero==1 & niños==0)
				replace genero_niños=2 if (genero==1 & niños==1)
				replace genero_niños=3 if (genero==2 & niños==0)
				replace genero_niños=4 if (genero==2 & niños==1)

				label variable genero_niños "Género y niños en el hogar"
				label define   genero_niños 1 "Hombre sin niños" 2 "Hombre con niños"  3 "Mujer sin niños" 4 "Mujer con niños"
				label values   genero_niños genero_niños

				*Género jefe de hogar y niños en el hogar*

				generate generojefe_niños=.
				replace generojefe_niños=1 if (genero_jefe==1 & niños==0)
				replace generojefe_niños=2 if (genero_jefe==1 & niños==1)
				replace generojefe_niños=3 if (genero_jefe==2 & niños==0)
				replace generojefe_niños=4 if (genero_jefe==2 & niños==1)

				label variable generojefe_niños "Género jefe de hogar y niños en el hogar"
				label define   generojefe_niños 1 "Jefe hombre sin niños" 2 "Jefe hombre con niños"  3 "Jefe mujer sin niños" ///
												4 "Jefe mujer con niños"
				label values   generojefe_niños generojefe_niños

				*Estado civil*

				generate casado=.
				replace casado=0 if (ch07>=3 & ch07<=5)
				replace casado=1 if (ch07==1 | ch07==2)

				generate soltero=.
				replace soltero=0 if (ch07>=1 & ch07<=4)
				replace soltero=1 if (ch07==5)

				label variable casado "=1 si casado"
				label define   casado 0 "No casado" 1 "Casado"
				label values   casado casado

				label variable soltero "=1 si soltero"
				label define   soltero 0 "No soltero" 1 "Soltero"
				label values   soltero soltero

				*Nivel educativo*

				generate nivel_educ=nivel_ed
				replace nivel_educ=1 if (nivel_ed==7)

				label variable nivel_educ "Nivel educativo"
				label define   nivel_educ 1 "Primario Incompleto / Sin Instrucción" 2 "Primario Completo" 3 "Secundario Incompleto" ///
										  4 "Secundario Completo" 5 "Superior Universitario Incompleto" 							///
										  6 "Superior Universitario Completo"
				label values   nivel_educ nivel_educ

				*Dummies de nivel educativo*

				generate prii=0 
				replace prii=1 if (nivel_educ==1)

				generate pric=0 
				replace pric=1 if (nivel_educ==2)

				generate seci=0 
				replace seci=1 if (nivel_educ==3)

				generate secc=0 
				replace secc=1 if (nivel_educ==4)

				generate supi=0 
				replace supi=1 if (nivel_educ==5)

				generate supc=0 
				replace supc=1 if (nivel_educ==6)

				label variable prii "=1 si primario incompleto"
				label define   prii 0 "!= primario incompleto" 1 "== primario incompleto"
				label values   prii prii

				label variable pric "=1 si primario completo"
				label define   pric 0 "!= primario completo" 1 "== primario completo"
				label values   pric pric

				label variable seci "=1 si secundario incompleto"
				label define   seci 0 "!= secundario incompleto" 1 "== secundario incompleto"
				label values   seci seci

				label variable secc "=1 si secundario completo"
				label define   secc 0 "!= secundario completo" 1 "== secundario completo"
				label values   secc secc

				label variable supi "=1 si superior incompleto"
				label define   supi 0 "!= superior incompleto" 1 "== superior incompleto"
				label values   supi supi

				label variable supc "=1 si superior completo"
				label define   supc 0 "!= superior completo" 1 "== superior completo"
				label values   supc supc

				*Condiciones de actividad laboral*

				generate ocupado=.
				replace ocupado=0 if (estado==2 | estado==3 | estado==4)
				replace ocupado=1 if (estado==1)

				generate desocupado=.
				replace desocupado=0 if (estado==1 | estado==3 | estado==4)
				replace desocupado=1 if (estado==2)

				generate inactivo=.
				replace inactivo=0 if (estado==1 | estado==2 | estado==4)
				replace inactivo=1 if (estado==3)

				label variable ocupado "=1 si ocupado"
				label define   ocupado 0 "No ocupado" 1 "Ocupado"
				label values   ocupado ocupado

				label variable desocupado "=1 si desocupado"
				label define   desocupado 0 "No desocupado" 1 "Desocupado"
				label values   desocupado desocupado

				label variable inactivo "=1 si inactivo"
				label define   inactivo 0 "No inactivo" 1 "Inactivo"
				label values   inactivo inactivo

				*Relación laboral*

				generate rel_lab=.
				replace rel_lab=1 if (cat_ocup==1)
				replace rel_lab=2 if (cat_ocup==3)
				replace rel_lab=3 if (cat_ocup==2)
				replace rel_lab=4 if (cat_ocup==4)
				replace rel_lab=5 if (desocupado==1)

				label variable rel_lab "Relación laboral"
				label define   rel_lab 	1 "Patrón" 2 "Obrero o empleado" 3 "Cuenta propia" 4 "Trabajador familiar sin remuneración" ///
										5 "Desocupado"
				label values   rel_lab rel_lab

				*Trabajadores domésticos*

				*if (`i'==21) replace pp04b1="." if pp04b1=="NA"
				*destring pp04b1, replace
				generate trab_dom=.
				replace trab_dom=0 if (pp04b1==2)
				replace trab_dom=1 if (pp04b1==1)

				label variable trab_dom "=si trabajador doméstico"
				label define trab_dom 0 "No trabajador doméstico" 1 "Trabajador doméstico"
				label values trab_dom trab_dom

				*Descuento jubilatorio*

				*if (`i'==21) replace pp07h="." if pp07h=="NA"
				*destring pp07h, replace
				generate desc_jubi=.
				replace desc_jubi=0 if (pp07h==2)
				replace desc_jubi=1 if (pp07h==1)

				label variable desc_jubi "=1 si descuento jubilatorio"
				label define desc_jubi 0 "Sin descuento jubilatorio" 1 "Con descuento jubilatorio"
				label values desc_jubi desc_jubi

				*Cobertura médica*

				generate cober_med=.
				replace cober_med=0 if (ch08==4)
				replace cober_med=1 if (ch08!=4)

				label variable cober_med "=1 si cobertura médica"
				label define cober_med 0 "Sin cobertura médica" 1 "Con cobertura médica"
				label values cober_med cober_med

				*Regiones*

				generate gba=.
				replace gba=1 if (region==1)
				replace gba=0 if (region!=1)

				generate noa=.
				replace noa=1 if (region==40)
				replace noa=0 if (region!=40)

				generate nea=.
				replace nea=1 if (region==41)
				replace nea=0 if (region!=41)

				generate cuyo=.
				replace cuyo=1 if (region==42)
				replace cuyo=0 if (region!=42)

				generate pampeana=.
				replace pampeana=1 if (region==43)
				replace pampeana=0 if (region!=43)

				generate patagonica=.
				replace patagonica=1 if (region==44)
				replace patagonica=0 if (region!=44)

				label variable gba        "=1 si región gba"
				label variable noa        "=1 si región noa"
				label variable nea        "=1 si región nea"
				label variable cuyo       "=1 si región cuyo"
				label variable pampeana   "=1 si región pampeana"
				label variable patagonica "=1 si región patagónica"

				* variable de nreg (unimos gba y pampeana en pampeana)
				gen nreg = .
				replace nreg = 1 if region == 1 | region == 43
				replace nreg = 2 if region == 42
				replace nreg = 3 if region == 41
				replace nreg = 4 if region == 40
				replace nreg = 5 if region == 44
				
				*Ingreso laboral*
				/*
				loc var = "pp06c pp06d pp08d1 pp08f1 pp08f2 pp08j1 pp08j2 pp08j3 tot_p12"
				foreach v in `var' {

					if `i' == "21" destring `v', replace force
				}
				*/
				
				egen ing_labor=rowtotal(pp06c pp06d pp08d1 pp08f1 pp08f2 pp08j1 pp08j2 pp08j3 tot_p12)

				*Ingreso no laboral*

				replace t_vi=0 if (t_vi<0)

				egen ing_nolabor=rowtotal(t_vi)
				egen ing_nolabor_aux=rowtotal(v2_m v3_m v4_m v5_m v8_m v9_m v10_m v11_m v12_m v18_m v19_am v21_m)

				generate v22_m=ing_nolabor-ing_nolabor_aux
				replace v22_m=0 if (v22_m<0)

				generate rentas=v8_m+v10_m

				*Ingreso total individual*

				egen ing_tot=rowtotal(ing_labor ing_nolabor)
				generate ing_labor_aux=p47t-ing_tot if (p47t>ing_tot)

				egen ing_laboral=rowtotal(ing_labor ing_labor_aux)
				egen ing_nolaboral=rowtotal(ing_nolabor_aux v22_m)
				egen ing_total=rowtotal(ing_laboral ing_nolaboral)

				drop ing_labor ing_labor_aux ing_nolabor ing_nolabor_aux v22_m ing_tot

				label variable ing_laboral   "Ingreso laboral"
				label variable ing_nolaboral "Ingreso no laboral"
				label variable ing_total     "Ingreso total"

				*Ingreso total familiar e Ingreso per cápita familiar*

				rename itf itf_indec
				rename ipcf ipcf_indec
				destring itf_indec, replace force
				destring ipcf_indec, replace force

				egen itf=sum(ing_total), by(codusu nro_hogar trimestre)
				generate ipcf_m=itf/miembros
				*generate ipcf_ae=itf/aef
				generate lipcf_m=ln(ipcf_m)

				label variable itf     "Ingreso total familiar"
				*label variable ipcf_ae "Ingreso per cápita familiar por adulto equivalente"
				label variable ipcf_m  "Ingreso per cápita familiar por miembros"
				label variable lipcf_m "Logaritmo del ingreso per cápita familiar por miembros"

				*Aguinaldo*

				egen aguinaldo=rowtotal(pp08j1 v21_m)

				label variable aguinaldo "Aguinaldo"

				*Ingreso por jubilaciones y pensiones*

				generate v2_m_aux=v2_m
				*replace v2_m_aux=0 if v2_m_aux<0

				generate v21_m_aux=v21_m/6
				*replace v21_m_aux=0 if v21_m_aux<0
				replace v21_m_aux=0 if v2_m_aux==0

				egen ing_jubi=rowtotal(v2_m_aux v21_m_aux), missing
				replace ing_jubi=. if (ing_jubi==0)
				drop v2_m_aux v21_m_aux

				label variable ing_jubi "Ingreso por jubilaciones y pensiones"

				*Percentiles / Deciles de ingreso*

				cuantiles ipcf_m  [w=pondih] if (ipcf_m>=0) , ncuantiles(100) orden_aux(id componente relacion edad) generate(pipcf_m)
				*cuantiles ipcf_ae [w=pondih] if (ipcf_ae>=0), ncuantiles(100) orden_aux(id componente relacion edad) generate(pipcf_ae)
				cuantiles ipcf_m  [w=pondih] if (ipcf_m>=0) , ncuantiles(10)  orden_aux(id componente relacion edad) generate(dipcf_m)
				*cuantiles ipcf_ae [w=pondih] if (ipcf_ae>=0), ncuantiles(10)  orden_aux(id componente relacion edad) generate(dipcf_ae)

				label variable pipcf_m  "Percentiles del ingreso per cápita familiar por miembros"
				*label variable pipcf_ae "Percentiles del ingreso per cápita familiar por adulto equivalente*"
				label variable dipcf_m  "Deciles del ingreso per cápita familiar por miembros"
				*label variable dipcf_ae "Deciles del ingreso per cápita familiar por adulto equivalente"

				*Trabajadores Privados/Públicos*

				generate privado=.
				replace privado=0 if (pp04a==1 | pp04a==3 | pp04a==9)
				replace privado=1 if (pp04a==2)

				label variable privado "=1 si trabajador privado"
				label define   privado 0 "Trabajador público u otro" 1 "Trabajador privado"
				label values   privado privado

				*Trabajadores Informales/Formales*

				generate informal_1=.
				replace informal_1=0 if (ocupado==1)
				replace informal_1=1 if (ocupado==1 & (rel_lab==2 & desc_jubi==0))

				generate informal_2=.
				replace informal_2=0 if (ocupado==1)
				replace informal_2=1 if (ocupado==1 & ((rel_lab==2 & desc_jubi==0) | (rel_lab==3 & dipcf_m<=6)))

				generate informal_3=.
				replace informal_3=0 if (ocupado==1)
				replace informal_3=1 if (ocupado==1 & ((rel_lab==2 & desc_jubi==0) | (rel_lab==3 & nivel_educ!=6)))

				forvalues a=1(1)3 {
					label variable informal_`a' "=1 si trabajador informal"
					label define   informal_`a' 0 "Trabajador formal" 1 "Trabajador informal"
					label values   informal_`a' informal_`a'
				}

				*Variables de Empleo*
				generate pet=.
        		replace pet=1 if edad>=10
        		replace pet=0 if edad<10
				label variable pet "Dummy de Población en Edad de Trabajar - mayores de 10 años"

        		generate pea=.
        		replace pea=1 if estado==1 | estado==2
        		replace pea=0 if estado==3 | estado==4 | estado==0 
				label variable pea "Dummy de Población Economicamente Activa - Ocupados + Desocupados"

        		generate ocupados=.
        		replace ocupados=1 if estado==1
        		replace ocupados=0 if estado==2 | estado==3 | estado==4 | estado==0 
				label variable ocupados "Dummy de Población Ocupada - variable estado=1"

        		generate desocupados=.
        		replace desocupados=1 if estado==2
        		replace desocupados=0 if estado==1  
				label variable desocupados "Dummy de Población Desocupada - variable estado=2"

        		generate inactivos=.
        		replace inactivos=1 if estado==3 
        		replace inactivos=0 if estado==1 | estado==2 | estado==4 | estado==0 
				label variable inactivos "Dummy de Población Inactiva - variables estado=3"

				generate menor_10=.
				replace menor_10=1 if estado==4
				replace menor_10=0 if estado==1 | estado==2 | estado==3 | estado==0
				label variable menor_10 "Dummy de Población fuera de la edad de trabajar - variable estado=4"

				*Guardado de Base Procesada*
				noi display in yellow "GUARDANDO BASE EPHC AÑO 20`i' SEMESTRE `k' PARA CALCULO DE COEFICIENTE DE GINI"
				save "$path_datain\EPH\Bases Procesadas\Finales\EPHC_20`i'_S`k'_proc.dta", replace
 			}
		}
	}
}


* BASES EPH PUNTUAL 

quietly {
	**************************************************************************************************************************************
	*                                               EPH PUNTUAL
	**************************************************************************************************************************************
	
	foreach i in $año_puntual {
		foreach o in $onda {
			
			*Apertura de Bases*

			if `i' == 95 capture use "$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_19`i'_O`o'_B", clear

			if `i' == 96 | `i' == 97 | `i' == 98 | `i' == 99 														///
			capture use "$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_19`i'_O`o'_A", clear

			if `i' == 00 | `i' == 01 | `i' == 02 | (`i' == 03 & `o' == 1) 											///
			capture use "$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_20`i'_O`o'_A", clear

			if (`i' == 03 & `o' == 3) | `i' == 04 | `i' == 05 | `i' == 06 											///
			capture use "$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_20`i'_O`o'_B", clear

			if _rc==601{

	    		if  `i' == 95 | `i' == 96 | `i' == 97 | `i' == 98 | `i' == 99 										///
				noi display in red "NO EXISTE BASE 19`i'_O`o' - PASANDO A SIGUIENTE BASE..."

				if  `i' == 00 | `i' == 01 | `i' == 02 | `i' == 03 | `i' == 04 | `i' == 05 | `i' == 06 				///
				noi display in red "NO EXISTE BASE 20`i'_O`o' - PASANDO A SIGUIENTE BASE..."
		    }

	    	if _rc!=601 {
				
				if  `i' == 95 | `i' == 96 | `i' == 97 | `i' == 98 | `i' == 99 										///
				noi display in yellow "EXISTE BASE 19`i'_O`o' - CREANDO VARIABLES NECESARIAS..."

				if  `i' == 00 | `i' == 01 | `i' == 02 | `i' == 03 | `i' == 04 | `i' == 05 | `i' == 06 				///
				noi display in yellow "EXISTE BASE 20`i'_O`o' - CREANDO VARIABLES NECESARIAS..."

				*Variable de Aglomerado*

				if `i' == 96 | `i' == 97 | `i' == 98 | `i' == 99 | `i' == 00 | `i' == 01 | `i' == 02 | (`i' == 03 & `o' == 1) {

					rename aglomerado aglo_nac
					rename agloreal aglomerado
					label var aglo_nac 		"Aglomerado Nacional - 45"
					label var aglomerado 	"Aglomerado"
				}
			
				*Provincias*

				generate prov=""
				label variable prov "Nombre Provincia"
				
				replace prov="Buenos Aires" 		 if aglomerado==2 | aglomerado==3 | aglomerado==33 | aglomerado==34 | aglomerado==38 
				replace prov="Ciudad Autonoma de BA" if aglomerado==32 
				replace prov="Cordoba" 				 if aglomerado==13 | aglomerado==36  
				replace prov="Santa Fe" 			 if aglomerado==4 | aglomerado==5 
				replace prov="La Pampa" 			 if aglomerado==30

				replace prov="Mendoza" 				 if aglomerado==10 
				replace prov="San Juan" 			 if aglomerado==27  
				replace prov="San Luis" 			 if aglomerado==26

				replace prov="Chaco" 				 if aglomerado==8  
				replace prov="Corrientes" 			 if aglomerado==12  
				replace prov="Entre Rios" 			 if aglomerado==6 | aglomerado==14 
				replace prov="Formosa" 				 if aglomerado==15  
				replace prov="Misiones" 			 if aglomerado==7  

				replace prov="Catamarca" 			 if aglomerado==22
				replace prov="Jujuy" 				 if aglomerado==19
				replace prov="La Rioja" 			 if aglomerado==25
				replace prov="Salta" 				 if aglomerado==23
				replace prov="Santiago del Estero" 	 if aglomerado==18 
				replace prov="Tucuman" 				 if aglomerado==29

				replace prov="Rio Negro" 			 if aglomerado==93 
				replace prov="Neuquen" 				 if aglomerado==17
				replace prov="Chubut" 				 if aglomerado==9 | aglomerado==91
				replace prov="Santa Cruz" 			 if aglomerado==20
				replace prov="Tierra del Fuego" 	 if aglomerado==31 
				
				*Codigo de Provincia*

				generate nprov=.
				label variable nprov "Código Provincia"

				replace nprov=1  if prov=="Buenos Aires" 
				replace nprov=5  if prov=="Ciudad Autonoma de BA"
				replace nprov=6  if prov=="Cordoba" 
				replace nprov=21 if prov=="Santa Fe" 
				replace nprov=11 if prov=="La Pampa"

				replace nprov=13 if prov=="Mendoza" 
				replace nprov=18 if prov=="San Juan"  
				replace nprov=19 if prov=="San Luis"

				replace nprov=3  if prov=="Chaco"   
				replace nprov=7  if prov=="Corrientes"  
				replace nprov=8  if prov=="Entre Rios" 
				replace nprov=9  if prov=="Formosa"  
				replace nprov=14 if prov=="Misiones"

				replace nprov=2  if prov=="Catamarca" 
				replace nprov=10 if prov=="Jujuy" 
				replace nprov=12 if prov=="La Rioja" 
				replace nprov=17 if prov=="Salta" 
				replace nprov=22 if prov=="Santiago del Estero" 
				replace nprov=24 if prov=="Tucuman"

				replace nprov=16 if prov=="Rio Negro" 
				replace nprov=15 if prov=="Neuquen" 
				replace nprov=4  if prov=="Chubut" 
				replace nprov=20 if prov=="Santa Cruz" 
				replace nprov=23 if prov=="Tierra del Fuego"

				*Regiones* 
				
				if (`i'==95 | (`i'==03 & `o'==3) | `i'==04 | `i'==05 | `i'==06) {

					gen region = .
					replace region = 40 if nprov==2 | nprov==10 | nprov==12 | nprov==17 | nprov==22 | nprov==24
					replace region = 41 if nprov==3 | nprov==7 | nprov==8 | nprov==9 | nprov==14
					replace region = 42 if nprov==13 | nprov==18 | nprov==19
					replace region = 43 if nprov==1 | nprov==6 | nprov==11 | nprov==21
					replace region = 44 if nprov==4 | nprov==15 | nprov==16 | nprov==20 | nprov==23 
					replace region = 1  if aglomerado==32 | aglomerado==33 
				}

				* variable de nreg (unimos gba y pampeana en pampeana)
				gen nreg = .
				replace nreg = 1 if region == 1 | region == 43
				replace nreg = 2 if region == 42
				replace nreg = 3 if region == 41
				replace nreg = 4 if region == 40
				replace nreg = 5 if region == 44
			
				*Ponderadores*

				local pondera="pondii pondih pondiio"
				foreach pond in `pondera' {

					capture summarize `pond'
					if (_rc==111) clonevar `pond'=pondera
				}

				*Identificador del hogar*

				sort codusu
				egen id=group(codusu)

				label variable id "Identificador del hogar"

				*Año*

				if `i' == 95 {
					gen aux = 1900
					gen ano4 = aux + ano
					drop aux
				}
				generate año=ano4
				label variable año "Año"

				*Relación de parentesco*

				generate relacion=.
				replace relacion=1 if (h08==1)
				replace relacion=2 if (h08==2)
				replace relacion=3 if (h08==3)
				replace relacion=4 if (h08==8)
				replace relacion=5 if (h08==4 | h08==6 | h08==5 | h08==7 | h08==9)
				replace relacion=6 if (h08==10 | h08==11 | h08==12)

				label variable relacion "Relación de parentesco"
				label define relacion 	1 "Jefe/a" 2 "Cónyuge / Pareja" 3 "Hijo/a / Hijastro/a" 4 "Madre / Padre - Suegro/a" 	///
										5 "Yerno/Nuera - Nieto/a - Hermano/a - Otros Familiares" 								///
										6 "No Familiares - Servicio doméstico / Pensionistas"
				label values relacion relacion
			
				*Relación de parentesco estandarizada*

				generate relacion_est=""
				replace relacion_est=" 1 - Jefe/a                           " if (h08==1)
				replace relacion_est=" 2 - Cónyuge / Pareja                 " if (h08==2)
				replace relacion_est=" 3 - Hijo/a / Hijastro/a              " if (h08==3)
				replace relacion_est=" 4 - Yerno/Nuera                      " if (h08==4)
				replace relacion_est=" 5 - Hermano/a                        " if (h08==5)
				replace relacion_est=" 6 - Nieto/a		                    " if (h08==6)
				replace relacion_est=" 7 - Cuñado	                        " if (h08==7)
				replace relacion_est=" 8 - Madre / Padre - Suegro/a         " if (h08==8)
				replace relacion_est=" 9 - Otros Familiares                 " if (h08==9)
				replace relacion_est="10 - Servicio Domestico               " if (h08==10)
				replace relacion_est="11 - Otros Componentes				" if (h08==11 | h08==12)

				encode relacion_est, generate(aux)
				drop relacion_est
				rename aux relacion_est

				label variable relacion_est "Relación de parentesco estandarizada"

				*Miembros de hogares secundarios*Es posible que no esté del todo ok

				generate hogar_sec=0
				replace hogar_sec=1 if (relacion_est==11)

				label variable hogar_sec "=1 si miembro de un hogar secundario"
				label define   hogar_sec 0 "Miembro de un hogar principal" 1 "Miembro de un hogar secundario"
				label values   hogar_sec hogar_sec

				*Número de miembros del hogar principal*

				generate aux=1
				egen miembros=sum(aux) if (hogar_sec==0 | relacion!=.), by(id)
				drop aux

				label variable miembros "Número de miembros del hogar principal"

				*Identifica al jefe de hogar*

				generate jefe=1 if (relacion==1)
				replace jefe=0 if (relacion!=1)
				replace jefe=. if (relacion==. | hogar_sec==1)

				label variable jefe "=1 si jefe de hogar"
				label define   jefe 0 "No jefe de hogar" 1 "Jefe de hogar"
				label values   jefe jefe

				*Identifica al cónyuge*

				generate conyuge=1 if (relacion==2)
				replace conyuge=0 if (relacion!=2)
				replace conyuge=. if (relacion==. | hogar_sec==1)

				label variable conyuge "=1 si cónyuge"
				label define   conyuge 0 "No cónyuge" 1 "Cónyuge"
				label values   conyuge conyuge

				*Identifica a los hijos del hogar principal*

				generate hijo=1 if (relacion==3)
				replace hijo=0 if (relacion!=3)
				replace hijo=. if (relacion==. | hogar_sec==1)

				label variable hijo "=1 si hijo"
				label define   hijo 0 "No hijo" 1 "Hijo"
				label values   hijo hijo

				*Número de hijos menores de 18 años en el hogar principal*

				generate aux=1 if (hijo==1 & h12<18)
				egen double nro_hijos=sum(aux), by(id)
				replace nro_hijos=. if (jefe!=1 & conyuge!=1)
				drop aux

				label variable nro_hijos "Número de hijos menores de 18 años en el hogar principal"

				*Edad*

				generate edad=h12
				replace edad=0 if (edad==-1)
				replace edad=. if (edad==99)

				generate edad2=edad*edad

				label variable edad  "Edad"
				label variable edad2 "Edad al cuadrado"

				*Grupos de edad*

				generate g_edad_1=.
				replace g_edad_1=1 if (edad>=0 & edad<=17)
				replace g_edad_1=2 if (edad>=18 & edad<=64)
				replace g_edad_1=3 if (edad>=65 & edad!=.)

				generate g_edad_2=.
				replace g_edad_2=1 if (edad>=0 & edad<=17)
				replace g_edad_2=2 if (edad>=18 & edad<=40)
				replace g_edad_2=3 if (edad>=41 & edad<=64)
				replace g_edad_2=4 if (edad>=65 & edad!=.)

				generate g_edad_3=.
				replace g_edad_3=1 if (edad>=0 & edad<=17)
				replace g_edad_3=2 if (edad>=18 & edad<=24)
				replace g_edad_3=3 if (edad>=25 & edad<=40)
				replace g_edad_3=4 if (edad>=41 & edad<=64)
				replace g_edad_3=5 if (edad>=65 & edad!=.)

				label variable g_edad_1 "Grupos de edad 1"
				label define   g_edad_1 1 "[0,17]" 2 "[18,64]" 3 "[65+]"
				label values   g_edad_1 g_edad_1

				label variable g_edad_2 "Grupos de edad 2"
				label define   g_edad_2 1 "[0,17]" 2 "[18,40]" 3 "[41,64]" 4 "[65+]"
				label values   g_edad_2 g_edad_2

				label variable g_edad_3 "Grupos de edad 3"
				label define   g_edad_3 1 "[0,17]" 2 "[18,24]" 3 "[25,40]"  4 "[41,64]" 5 "[65+]"
				label values   g_edad_3 g_edad_3
			
				*Género*

				generate hombre=.
				replace hombre=0 if (h13==2)
				replace hombre=1 if (h13==1)

				generate genero=.
				replace genero=1 if (hombre==1)
				replace genero=2 if (hombre==0)

				label variable hombre "=1 si hombre"
				label define   hombre 0 "Mujer" 1 "Hombre" 
				label values   hombre hombre

				label variable genero "Género"
				label define   genero 1 "Hombre" 2 "Mujer" 
				label values   genero genero

				*Género jefe de hogar*

				generate aux=.
				replace aux=1 if (genero==1 & jefe==1)
				replace aux=2 if (genero==2 & jefe==1)
				egen genero_jefe=max(aux), by(id)
				drop aux

				label variable genero_jefe "Género jefe de hogar"
				label define   genero_jefe 1 "Jefe hombre" 2 "Jefe mujer"
				label values   genero_jefe genero_jefe

				*Niños en el hogar*

				generate aux=0
				replace aux=1 if (edad<18 & (relacion_est==3 | relacion_est==6))
				egen niños=max(aux), by(id)
				drop aux

				label variable niños "=1 si niños en el hogar"
				label define   niños 0 "Hogar sin niños" 1 "Hogar con niños"
				label values   niños niños

				*Género y niños en el hogar*

				generate genero_niños=.
				replace genero_niños=1 if (genero==1 & niños==0)
				replace genero_niños=2 if (genero==1 & niños==1)
				replace genero_niños=3 if (genero==2 & niños==0)
				replace genero_niños=4 if (genero==2 & niños==1)

				label variable genero_niños "Género y niños en el hogar"
				label define   genero_niños 1 "Hombre sin niños" 2 "Hombre con niños"  3 "Mujer sin niños" 4 "Mujer con niños"
				label values   genero_niños genero_niños

				*Género jefe de hogar y niños en el hogar*

				generate generojefe_niños=.
				replace generojefe_niños=1 if (genero_jefe==1 & niños==0)
				replace generojefe_niños=2 if (genero_jefe==1 & niños==1)
				replace generojefe_niños=3 if (genero_jefe==2 & niños==0)
				replace generojefe_niños=4 if (genero_jefe==2 & niños==1)

				label variable generojefe_niños 	"Género jefe de hogar y niños en el hogar"
				label define   generojefe_niños  	1 "Jefe hombre sin niños" 2 "Jefe hombre con niños"  						///
													3 "Jefe mujer sin niños" 4 "Jefe mujer con niños"
				label values   generojefe_niños generojefe_niños

				*Estado civil*

				generate casado=.
				replace casado=0 if (h14==1 | h14==4 | h14==5)
				replace casado=1 if (h14==2 | h14==3)

				generate soltero=.
				replace soltero=0 if (h14>=2 & h14<=5)
				replace soltero=1 if (h14==1)

				label variable casado "=1 si casado"
				label define   casado 0 "No casado" 1 "Casado"
				label values   casado casado

				label variable soltero "=1 si soltero"
				label define   soltero 0 "No soltero" 1 "Soltero"
				label values   soltero soltero

				*Nivel educativo*

				destring p56, gen(aux_nivel_educ) force
				generate nivel_educ=.
				replace nivel_educ=1 if (aux_nivel_educ==0 | aux_nivel_educ==. | (aux_nivel_educ==1 & p58!=1))
				replace nivel_educ=2 if (aux_nivel_educ==1 & p58==1)
				replace nivel_educ=3 if ((aux_nivel_educ==2 | aux_nivel_educ==3 | aux_nivel_educ==4 | aux_nivel_educ==5 | aux_nivel_educ==6) & p58!=1)
				replace nivel_educ=4 if ((aux_nivel_educ==2 | aux_nivel_educ==3 | aux_nivel_educ==4 | aux_nivel_educ==5 | aux_nivel_educ==6) & p58==1)
				replace nivel_educ=5 if ((aux_nivel_educ==7 | aux_nivel_educ==8) & p58!=1)
				replace nivel_educ=6 if ((aux_nivel_educ==7 | aux_nivel_educ==8) & p58==1)

				label variable nivel_educ 	"Nivel educativo"
				label define   nivel_educ 	1 "Primario Incompleto / Sin Instrucción" 2 "Primario Completo" 					///
											3 "Secundario Incompleto" 4 "Secundario Completo" 									///
											5 "Superior Universitario Incompleto" 6 "Superior Universitario Completo"
				label values   nivel_educ nivel_educ
				drop aux_nivel_educ

				*Dummies de nivel educativo*

				generate prii=0 
				replace prii=1 if (nivel_educ==1)

				generate pric=0 
				replace pric=1 if (nivel_educ==2)

				generate seci=0 
				replace seci=1 if (nivel_educ==3)

				generate secc=0 
				replace secc=1 if (nivel_educ==4)

				generate supi=0 
				replace supi=1 if (nivel_educ==5)

				generate supc=0 
				replace supc=1 if (nivel_educ==6)

				label variable prii "=1 si primario incompleto"
				label define   prii 0 "!= primario incompleto" 1 "== primario incompleto"
				label values   prii prii

				label variable pric "=1 si primario completo"
				label define   pric 0 "!= primario completo" 1 "== primario completo"
				label values   pric pric

				label variable seci "=1 si secundario incompleto"
				label define   seci 0 "!= secundario incompleto" 1 "== secundario incompleto"
				label values   seci seci

				label variable secc "=1 si secundario completo"
				label define   secc 0 "!= secundario completo" 1 "== secundario completo"
				label values   secc secc

				label variable supi "=1 si superior incompleto"
				label define   supi 0 "!= superior incompleto" 1 "== superior incompleto"
				label values   supi supi

				label variable supc "=1 si superior completo"
				label define   supc 0 "!= superior completo" 1 "== superior completo"
				label values   supc supc

				*Condiciones de actividad laboral*

				generate ocupado=.
				replace ocupado=0 if (estado==2 | estado==3)
				replace ocupado=1 if (estado==1)

				generate desocupado=.
				replace desocupado=0 if (estado==1 | estado==3)
				replace desocupado=1 if (estado==2)

				generate inactivo=.
				replace inactivo=0 if (estado==1 | estado==2)
				replace inactivo=1 if (estado==3)

				label variable ocupado "=1 si ocupado"
				label define   ocupado 0 "No ocupado" 1 "Ocupado"
				label values   ocupado ocupado

				label variable desocupado "=1 si desocupado"
				label define   desocupado 0 "No desocupado" 1 "Desocupado"
				label values   desocupado desocupado

				label variable inactivo "=1 si inactivo"
				label define   inactivo 0 "No inactivo" 1 "Inactivo"
				label values   inactivo inactivo

				*Relación laboral*

				generate rel_lab=.
				replace rel_lab=1 if (p17==1)
				replace rel_lab=2 if (p17==3)
				replace rel_lab=3 if (p17==2)
				replace rel_lab=4 if (p17==4)
				replace rel_lab=5 if (desocupado==1)

				label variable rel_lab 			"Relación laboral"
				label define   rel_lab_label 	1 "Patrón" 2 "Obrero o empleado" 3 "Cuenta propia" 						///
												4 "Trabajador familiar sin remuneración" 5 	"Desocupado"
				label values   rel_lab rel_lab_label

				
				*Trabajadores domésticos* /* No hay variable de trabajo domestico en EPHP*/

				/*
				*if (`i'==21) replace pp04b1="." if pp04b1=="NA"
				*destring pp04b1, replace
				generate trab_dom=.
				replace trab_dom=0 if (pp04b1==2)
				replace trab_dom=1 if (pp04b1==1)

				label variable trab_dom "=si trabajador doméstico"
				label define trab_dom 0 "No trabajador doméstico" 1 "Trabajador doméstico"
				label values trab_dom trab_dom
				*/

				*Descuento jubilatorio* /* Forma de calcularlo sacado de registro indec: p23 dividido el codigo por dos, 		*/
										/* si el modulo es mayor o igual al codigo es porque lo tiene 							*/
										/* (igual para aguinaldo, obra social, vaciones, seguro etc.) 							*/

				*if (`i'==21) replace pp07h="." if pp07h=="NA"
				*destring pp07h, replace

				gen aux_desc_jubi=mod(p23,4)
				generate desc_jubi=.
				replace desc_jubi=0 if (aux_desc_jubi<2)
				replace desc_jubi=1 if (aux_desc_jubi>=2)
				drop aux_desc_jubi

				label variable desc_jubi "=1 si descuento jubilatorio"
				label define desc_jubi 0 "Sin descuento jubilatorio" 1 "Con descuento jubilatorio"
				label values desc_jubi desc_jubi

				
				*Cobertura médica*

				gen aux_cober_med=mod(p23,2)
				generate cober_med=.
				replace cober_med=0 if (aux_cober_med<1)
				replace cober_med=1 if (aux_cober_med>=1)

				label variable cober_med "=1 si cobertura médica"
				label define cober_med 0 "Sin cobertura médica" 1 "Con cobertura médica"
				label values cober_med cober_med
				
				
				*Regiones*

				generate gba=.
				replace gba=1 if (region==1)
				replace gba=0 if (region!=1)

				generate noa=.
				replace noa=1 if (region==40)
				replace noa=0 if (region!=40)

				generate nea=.
				replace nea=1 if (region==41)
				replace nea=0 if (region!=41)

				generate cuyo=.
				replace cuyo=1 if (region==42)
				replace cuyo=0 if (region!=42)

				generate pampeana=.
				replace pampeana=1 if (region==43)
				replace pampeana=0 if (region!=43)

				generate patagonica=.
				replace patagonica=1 if (region==44)
				replace patagonica=0 if (region!=44)

				label variable gba        "=1 si región gba"
				label variable noa        "=1 si región noa"
				label variable nea        "=1 si región nea"
				label variable cuyo       "=1 si región cuyo"
				label variable pampeana   "=1 si región pampeana"
				label variable patagonica "=1 si región patagónica"

				*Líneas de pobreza (extremas y moderadas) oficiales*

				*label variable lp_extrema  "Línea de pobreza extrema oficial"
				*label variable lp_moderada "Línea de pobreza moderada oficial"

				*Coeficientes adulto equivalente*	/* ver si lo necesito, pero creeria que no */
				
				*label variable ae  "Adulto equivalente"
				*label variable aef "Adulto equivalente familiar"

				*Ingreso laboral*

				/*
				loc var = "pp06c pp06d pp08d1 pp08f1 pp08f2 pp08j1 pp08j2 pp08j3 tot_p12"
				foreach v in `var' {

					destring `v', replace force
				}
				*/
			
				egen ing_labor=rowtotal(p47_1 p47_2 p47_3 p47_4)

				/*
				pp06c 	-->	p47_3 & p47_4	:	"ingreso de patrones y cuenta propia sin socios"
				pp06d 	-->	p47_3 & p47_4	:	"ingreso de patrones y cuenta propia con socios"
				pp08d1 	-->	p47_1			:	"suledos, salario familiar, hs extras, tickets, etc."
				pp08f1 	-->					:	"comision por venta/produccion"
				pp08f2 	-->					:	"propinas"
				pp08j1 	-->					:	"aguinaldo"
				pp08j2 	-->	p47_2			:	"bonificaciones no habituales"
				pp08j3 	-->					:	"monto retroactivo"
				tot_p12	-->					:	"ingreso por otras ocupaciones"
				*/

				*Ingreso no laboral* /* No hay variable de ingresos no laborales así que construimos la suma igual que para laborales */

				egen ing_nolabor=rowtotal(p48_1 p48_2 p48_3 p48_4 p48_5 p48_6 p48_7 p48_8 p48_9)

				/*
				v2_m 	--> p48_1	 		:	"jubilacion o pension"
				v3_m 	--> p48_5			:	"indemnizacion por despido"
				v4_m 	--> p48_4			:	"seguro de desempleo"
				v5_m 	--> 				:	"subsidio o ayuda social"
				v8_m 	--> p48_2			:	"alquiler de su propiedad"
				v9_m 	--> p48_3			:	"ganancias de negocio"
				v10_m 	--> p48_2			:	"intereses / rentas de plazo fijo o inversiones"
				v11_m 	--> p48_6			:	"beca de estudio"
				v12_m 	--> p48_7 & p48_8	:	"ingreso de personas que no viven en el hogar (cuota alimentaria, etc.)"
				v18_m 	--> p48_9			:	"otros ingresos (limosna, juego de azar)"
				v19_am 	--> 				:	"trabajo de menores de 10 años"
				v21_m	--> 				:	"aguinaldo"
				*/

				generate rentas=p48_2
				
				*generate v22_m=ing_nolabor-ing_nolabor_aux /* No hay suma de ingresos no laborales para comparar con v22_m */
				*replace v22_m=0 if (v22_m<0)
				
				*Ingreso total individual*

				egen ing_tot=rowtotal(ing_labor ing_nolabor)
				generate ing_labor_aux=p47t-ing_tot if (p47t>ing_tot)

				egen ing_laboral=rowtotal(ing_labor ing_labor_aux)
				egen ing_nolaboral=rowtotal(ing_nolabor)
				egen ing_total=rowtotal(ing_laboral ing_nolaboral)

				drop ing_labor ing_labor_aux ing_nolabor ing_tot

				label variable ing_laboral   "Ingreso laboral"
				label variable ing_nolaboral "Ingreso no laboral"
				label variable ing_total     "Ingreso total"

				*Ingreso total familiar e Ingreso per cápita familiar*
			
				rename itf itf_indec
				rename ipcf ipcf_indec
				destring itf_indec, replace force
				destring ipcf_indec, replace force

				egen itf=sum(ing_total), by(codusu) /* En EPHP no hay variable de nro_hogar y son semestrales*/
				generate ipcf_m=itf/miembros
				*generate ipcf_ae=itf/aef
				generate lipcf_m=ln(ipcf_m)

				label variable itf     "Ingreso total familiar"
				*label variable ipcf_ae "Ingreso per cápita familiar por adulto equivalente"
				label variable ipcf_m  "Ingreso per cápita familiar por miembros"
				label variable lipcf_m "Logaritmo del ingreso per cápita familiar por miembros"
			
				*Aguinaldo* /* No hay variable de aguinaldo en eph puntual */

				*egen aguinaldo=rowtotal(pp08j1 v21_m)

				*label variable aguinaldo "Aguinaldo"

				*Ingreso por jubilaciones y pensiones*

				generate p48_1_aux=p48_1
				*replace v2_m_aux=0 if v2_m_aux<0

				*generate v21_m_aux=v21_m/6	/* No hay variable de aguinaldo en eph puntual */
				*replace v21_m_aux=0 if v21_m_aux<0
				*replace v21_m_aux=0 if v2_m_aux==0
			
				egen ing_jubi=rowtotal(p48_1_aux)
				replace ing_jubi=. if (ing_jubi==0)
				drop p48_1_aux 

				label variable ing_jubi "Ingreso por jubilaciones y pensiones"

				*Percentiles / Deciles de ingreso*

				cuantiles ipcf_m  [w=pondih] if (ipcf_m>=0) , ncuantiles(100) orden_aux(id componente relacion edad) generate(pipcf_m)
				*cuantiles ipcf_ae [w=pondih] if (ipcf_ae>=0), ncuantiles(100) orden_aux(id componente relacion edad) generate(pipcf_ae)
				cuantiles ipcf_m  [w=pondih] if (ipcf_m>=0) , ncuantiles(10)  orden_aux(id componente relacion edad) generate(dipcf_m)
				*cuantiles ipcf_ae [w=pondih] if (ipcf_ae>=0), ncuantiles(10)  orden_aux(id componente relacion edad) generate(dipcf_ae)

				label variable pipcf_m  "Percentiles del ingreso per cápita familiar por miembros"
				*label variable pipcf_ae "Percentiles del ingreso per cápita familiar por adulto equivalente*"
				label variable dipcf_m  "Deciles del ingreso per cápita familiar por miembros"
				*label variable dipcf_ae "Deciles del ingreso per cápita familiar por adulto equivalente"

				*Trabajadores Privados/Públicos*

				generate privado=.
				replace privado=0 if (p18b==1 | p18b==3 | p18b==9)
				replace privado=1 if (p18b==2)

				label variable privado "=1 si trabajador privado"
				label define   privado 0 "Trabajador público u otro" 1 "Trabajador privado"
				label values   privado privado

				*Trabajadores Informales/Formales*

				generate informal_1=.
				replace informal_1=0 if (ocupado==1)
				replace informal_1=1 if (ocupado==1 & (rel_lab==2 & desc_jubi==0))

				generate informal_2=.
				replace informal_2=0 if (ocupado==1)
				replace informal_2=1 if (ocupado==1 & ((rel_lab==2 & desc_jubi==0) | (rel_lab==3 & dipcf_m<=6)))

				generate informal_3=.
				replace informal_3=0 if (ocupado==1)
				replace informal_3=1 if (ocupado==1 & ((rel_lab==2 & desc_jubi==0) | (rel_lab==3 & nivel_educ!=6)))

				forvalues a=1(1)3 {
					label variable informal_`a' "=1 si trabajador informal"
					label define   informal_`a' 0 "Trabajador formal" 1 "Trabajador informal"
					label values   informal_`a' informal_`a'
				}

				* VARIABLES DE EMPLEO
				generate pet=.
        		replace pet=1 if edad>=10
        		replace pet=0 if edad<10
				label variable pet "Dummy de Población en Edad de Trabajar - mayores de 10 años"

        		generate pea=.
        		replace pea=1 if estado==1 | estado==2
        		replace pea=0 if estado==3 | estado==4 | estado==0 
				label variable pea "Dummy de Población Economicamente Activa - Ocupados + Desocupados"

        		generate ocupados=.
        		replace ocupados=1 if estado==1
        		replace ocupados=0 if estado==2 | estado==3 | estado==4 | estado==0 
				label variable ocupados "Dummy de Población Ocupada - variable estado=1"

        		generate desocupados=.
        		replace desocupados=1 if estado==2
        		replace desocupados=0 if estado==1  
				label variable desocupados "Dummy de Población Desocupada - variable estado=2"

        		generate inactivos=.
        		replace inactivos=1 if estado==3 
        		replace inactivos=0 if estado==1 | estado==2 | estado==4 | estado==0 
				label variable inactivos "Dummy de Población Inactiva - variables estado=3"

				generate menor_10=.
				replace menor_10=1 if estado==4
				replace menor_10=0 if estado==1 | estado==2 | estado==3 | estado==0
				label variable menor_10 "Dummy de Población fuera de la edad de trabajar - variable estado=4"

				*Guardado de Base Procesada*
				if  `i' == 95 | `i' == 96 | `i' == 97 | `i' == 98 | `i' == 99 {									
					
					noi display in yellow "GUARDANDO BASE EPHP AÑO 19`i' ONDA `o' PARA CALCULO DE COEFICIENTE DE GINI"
					save "$path_datain\EPH\Bases Procesadas\Finales\EPHP_19`i'_O`o'_proc.dta", replace
				}
				if  `i' == 00 | `i' == 01 | `i' == 02 | `i' == 03 | `i' == 04 | `i' == 05 | `i' == 06	{

					noi display in yellow "GUARDANDO BASE EPHP AÑO 20`i' ONDA `o' PARA CALCULO DE COEFICIENTE DE GINI"
					save "$path_datain\EPH\Bases Procesadas\Finales\EPHP_20`i'_O`o'_proc.dta", replace
				}				
			}
		}
	}
}
