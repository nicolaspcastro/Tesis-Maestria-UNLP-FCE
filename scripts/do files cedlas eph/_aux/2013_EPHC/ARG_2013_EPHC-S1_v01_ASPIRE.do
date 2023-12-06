******************************************************************************************************
******************************************************************************************************
**                                                                                                  
**              ATLAS OF SOCIAL PROTECTION INDICATORS OF RESILIENCE AND EQUITY (ASPIRE)             
**                                  PROGRAM SPECIFIC FILE				                           
**           																					    
** COUNTRY:	                ARGENTINA
** COUNTRY ISO CODE:            ARG
** YEAR:	                2013 - First Semester
** SURVEY NAME:                 Encuesta Permanente de Hogares Continua (EPHC)
** SURVEY AGENCY:               Instituto Nacional de Estadísticas y Censos
** SURVEY SOURCE:               LAC Datalib/CEDLAS
** UNIT OF ANALYSIS:            Individuals and households
** INPUT DATABASES:             arg_2013_ephc-s1_v01_m_v01_a_sedlac-03_all.dta
**                              arg_2013_ephc-s1_v01_m_v01_a_sedlac-03_gmd.dta
** RESPONSIBLE:                 Leopoldo Tornarolli
** CREATED:                     12/10/2019
** NUMBER OF HOUSEHOLDS:         34,332
** NUMBER OF INDIVIDUALS:       110,156
**                                                                                                 
******************************************************************************************************
******************************************************************************************************/


/***********************************************************************************************

*  Llama bases SEDLAC

local code        = "ARG"
local countryname = "Argentina"
local year        =  2013

datalib, country(`code') year(`year') mod(all gmd) clear noppp
local survey=r(survname)
local countryname= r(countryname) 

local varlist1 "sp_* pt_* d_* aux* pensions socialsecu activelabor passivelabor cashtransfer cct socialpension inkind schoolfeed publicworks subsidies othersa domprivate interprivate"
drop `varlist1'

gen survey=r(survname)
gen countryname= "Argentina" 

***********************************************************************************************/


**************************************************************************************************
**************************************************************************************************
*** PRIMERA PARTE - VARIABLES ESPECIFICAS DE PROTECTION SOCIAL
**************************************************************************************************
**************************************************************************************************

*********************************************************************
**  ENTITLEMENT TO SOCIAL PROTECTION
*********************************************************************

/* SECCION OCUPACION PRINCIPAL DE LOS ASALARIADOS - CUESTIONARIO INDIVIDUAL
   PP7H:  Por ese trabajo tiene descuento jubilatorio? 							*/
gen       contribute_pension = 1        if  pp07h==1
replace   contribute_pension = 0        if  pp07h==2
label var contribute_pension "Contributes to an old-age pension through work, y/n (ind)"


/* SECCION CARACTERISTICAS DE LOS MIEMBROS DEL HOGAR - CUESTIONARIO INDIVIDUAL
   CH08:  Tiene algun tipo de cobertura medica por la que paga o le descuentan? 
	  1 = Obra social (incluye PAMI)
	  2 = Mutual/Prepaga/Servicio de emergencia
	  3 = Planes y seguros publicos
	  4 = No paga ni le descuentan
	  9 = NS/NR
	 12 = Obra Social y Mutual/Prepaga/Servicio de Emergencia
	 13 = Obra Social y Planes y Seguros Publicos
	 23 = Mutual/Prepaga/Servicios de Emergencia y Planes y Seguros Publicos
	123 = Obra Social, Mutual/Prepaga/Servicios de Emergencia y Planes y Seguros Publicos		*/
gen       ss_healthinsured = 0
replace   ss_healthinsured = 1	        if ch08==1 | ch08==2 | ch08==3 | ch08==12 | ch08==13 | ch08==23 | ch08==123
label var ss_healthinsured "Covered by health insurance, public or private - y/n (ind)"


*********************************************************************
**  BENEFICIARIES OF SOCIAL PROTECTION
*********************************************************************

******************************
* CUESTIONARIO INDIVIDUAL 
******************************

/* OCUPACION PRINCIPAL DE LOS ASALARIADOS (EXCEPTO SERVICIO DOMESTICO)
   PP07E: Este trabajo es: 
		1 = un plan de empleo?
		2 = un periodo de prueba?
		3 = una beca/pasantia/aprendizaje?
		4 = ninguno de estos 
		9 = NS/NR										*/
gen       sp_pi_planempleo = 0          if  pp07e>=1 & pp07e<=4
replace   sp_pi_planempleo = 1          if  pp07e==1 
label var sp_pi_planempleo "Beneficiary of Plan de empleo - y/n (ind)"

gen       sp_pi_pasantia = 0	        if  pp07e>=1 & pp07e<=4 
replace   sp_pi_pasantia = 1            if  pp07e==3
label var sp_pi_pasantia "Beneficiary of Scholarship/Internship/Training - y/n (ind)"


****************************
* CUESTIONARIO HOGAR
****************************

/* ESTRATEGIAS DEL HOGAR
   En los últimos tres meses, las personas de este hogar han vivido... 
    V2:  de alguna jubilación o pensión?  
   V21:  de aguinaldo de alguna jubilación o  pensión  cobrada el mes anterior?    
    V4:  de seguro de desempleo?  
    V5:  de subsidio o ayuda social(en dinero)del gobierno, iglesias, etc.?    
    V6:  con mercaderías, ropa, alimentos del gobierno, iglesias, escuelas, etc.? 
    V7:  con mercaderías, ropa, alimentos de familiares, vecinos u otras personas que no viven en este hogar? 
   V11:  una beca de estudio?      
   V12:  cuotas de alimentos o  ayuda  en  dinero  de   personas que no viven en el hogar?		*/

* V2: Jubilacion o pension - Participatory						
gen       sp_ph_oldagepension = 0 
replace   sp_ph_oldagepension = 1	        if  v2==1 | v21==1 
label var sp_ph_oldagepension "Old age pension - y/n (hou)"
	
* V4: Seguro de Desempleo - Participatory						
gen       sp_ph_unemploymentbenefits = 0		
replace   sp_ph_unemploymentbenefits = 1        if  v4==1
label var sp_ph_unemploymentbenefits "Unemployment benefits - y/n (hou)"

* V5: Subsidio/Ayuda Social en dinero de Gobierno/Iglesias/Escuelas Participatory	
gen       sp_ph_subsidiocash = 0 
replace   sp_ph_subsidiocash = 1                if  v5==1
label var sp_ph_subsidiocash  "Social transfers from government, churches, etc.- y/n (hou)"

* V6: Mercaderia, Ropa, Alimentos de Gobierno/Iglesias/Escuelas Participatory		
gen       sp_ph_subsidioinkind = 0 
replace   sp_ph_subsidioinkind = 1	        if  v6==1
label var sp_ph_subsidioinkind "In kind social transfers from government, churches, etc.- y/n (hou)"

* V7: Ayuda Familiar Domestica en Especie - Participatory				
gen       pt_ph_domesticremittancesinkind = 0 
replace   pt_ph_domesticremittancesinkind = 1	if  v7==1
label var pt_ph_domesticremittancesinkind "In kind private transfers - y/n (hou)"

* V11: Becas de Estudio - Participatory							
gen       sp_ph_scholarship = 0 
replace   sp_ph_scholarship = 1		        if  v11==1
label var sp_ph_scholarship "Scholarships - y/n (hou)"

* V12: Ayudas en Dinero/Cuotas de Alimentos - Participatory			
gen       pt_ph_domesticremittances = 0 
replace   pt_ph_domesticremittances = 1	        if  v12==1
label var pt_ph_domesticremittances "Alimony, private cash transfers - y/n (hou)"
	

/* INGRESOS NO LABORALES
   En el mes, ¿cuánto cobró por:
    V2_M:  monto del ingreso por jubilación o pensión
   V21_M:  monto del ingreso por aguinaldo de jubilación o pensión
    V4_M:  monto del ingreso por seguro de desempleo
    V5_M:  monto del ingreso por de subsidio o ayuda social (en dinero) del gobierno, iglesias, etc. 
   V11_M:  monto del ingreso por beca de estudio
   V12_M:  monto del ingreso por cuotas de alimentos o ayuda en dinero de personas que no viven en el hogar	*/
 
* V2_M - V21_M : Jubilacion o pension - Monetary					
egen 	  sp_mi_oldagepension = rsum(v2_m v21_m), missing
replace   sp_mi_oldagepension = .		if  sp_mi_oldagepension==0
label var sp_mi_oldagepension "Old age pension - monthly in LCU (ind)"

* V4_M: Seguro de Desempleo - Monetary							
gen	  sp_mi_unemploymentbenefits = v4_m
replace   sp_mi_unemploymentbenefits = .		if  sp_mi_unemploymentbenefits==0
label var sp_mi_unemploymentbenefit "Unemployment benefits - monthly in LCU (ind)"

* V5_M: Subsidio/Ayuda Social en dinero de Gobierno/Iglesias - Monetary			
gen       sp_mi_subsidiocash = v5_m		
replace   sp_mi_subsidiocash = .			if  sp_mi_subsidiocash==0
label var sp_mi_subsidiocash "Social transfers from government, churches, etc. - monthly in LCU (ind)"
	
* V11_M: Becas de Estudio - Monetary							
gen       sp_mi_scholarship = v11_m		
replace   sp_mi_scholarship = .			if  sp_mi_scholarship==0	
label var sp_mi_scholarship "Scholarships - monthly in LCU (ind)"

* V12_M: Ayudas en Dinero/Cuotas de Alimentos Monetary					
gen       pt_mi_domesticremittances = v12_m		
replace   pt_mi_domesticremittances = .			if  pt_mi_domesticremittances==0
label var pt_mi_domesticremittances "Alimony, private cash transfers - monthly in LCU (ind)"


* Asignación Universal por Hijo (AUH) (http://jorgevega.com.ar/laboral/284-asignaciones-familiares-anses-abril-2015.html)
*				      (https://www.anses.gob.ar/informacion/datos-abiertos-asignaciones-universales)
/* 
From 09/2012 to 05/2013 
AUH/Embarazo:
$ 340 (General) - $ 733 (Chubut, Santa Cruz, Tierra del Fuego) - $ 680 (algunos departamentos mineros de Salta, Jujuy y Catamarca)
Hijo con Discapacidad: 
$ 1200 (General) - $ 1800 (Chubut) - $ 2400 (Santa Cruz, Tierra del Fuego, algunos departamentos mineros de Salta, Jujuy y Catamarca)

From 06/2013 to 05/2014
AUH/Embarazo:
$ 460 (General) - $ 992 (Chubut, Santa Cruz, Tierra del Fuego) - $ 920 (algunos departamentos mineros de Salta, Jujuy y Catamarca)
Hijo con Discapacidad: 
$ 1500 (General) - $ 2250 (Chubut) - $ 3000 (Santa Cruz, Tierra del Fuego, algunos departamentos mineros de Salta, Jujuy y Catamarca)	*/
gen       sp_mi_auh = 0
replace   sp_mi_auh = v5_m              if  v5_m>=270 & v5_m<=1400
label var sp_mi_auh "Asignacion Universal por Hijo - monthly in LCU (ind)"


**************************************************************************************************
**************************************************************************************************
*** SEGUNDA PARTE - VARIABLES ARMONIZADAS DE PROTECTION SOCIAL
**************************************************************************************************
**************************************************************************************************
sort id com


**********************************************
******* SOCIAL INSURANCE 
**********************************************

***** 01 - CONTRIBUTORY PENSIONS   	
by id: egen m_pensions =  sum(sp_mi_oldagepension), missing

egen       aux_pensions = max(sp_ph_oldagepension), by(id)

gen     d_pensions = 0		
replace d_pensions = 1 		if  aux_pensions==1
replace d_pensions = 1		if  m_pensions>0 & m_pensions<.
drop aux_pensions


***** 02 - OTHER SOCIAL INSURANCE
* No existe información sobre ingresos en esta categoría
gen     m_socialsecu = .

gen     d_socialsecu = .	  


**********************************************
******* LABOR MARKET 
**********************************************

***** 03 - LABOR MARKET POLICY MEASURES (ACTIVE LM PROGRAMS)
* No existe información sobre ingresos en esta categoría
gen     m_activelabor = .

egen    aux_pasantia = max(sp_pi_pasantia), by(id)

gen     d_activelabor = 0	 
replace d_activelabor = 1	if  aux_pasantia==1
replace d_activelabor = 1	if  m_activelabor>0 & m_activelabor<.
drop aux_pasantia


***** 04 - LABOR MARKET POLICY SUPPORT (PASSIVE LM PROGRAMS)
by id: 	egen m_passivelabor = sum(sp_mi_unemploymentbenefits), missing

egen  aux_unemploymentbenefits = max(sp_ph_unemploymentbenefits), by(id)

gen     d_passivelabor = 0	
replace d_passivelabor = 1	if  aux_unemploymentbenefits==1
replace d_passivelabor = 1	if  m_passivelabor>0 & m_passivelabor<.  
drop aux_unemploymentbenefits


**********************************************
******* SOCIAL ASSISTANCE 
**********************************************
  
***** 05 - UNCONDITIONAL CASH TRANSFERS	
by id: egen m_cashtransfer = sum(sp_mi_subsidiocash), missing

egen    aux_subsidiocash = max(sp_ph_subsidiocash), by(id)

gen     d_cashtransfer = 0	   
replace d_cashtransfer = 1	if  aux_subsidiocash==1
replace d_cashtransfer = 1	if  m_cashtransfer>0 & m_cashtransfer<.    
drop aux_subsidiocash


***** 06 - CONDITIONAL CASH TRANSFERS	
by id: egen m_cct = sum(sp_mi_auh), missing

gen     d_cct = 0		            
replace d_cct = 1		if  m_cct>0 & m_cct<.            


***** 07 - SOCIAL PENSIONS (NON-CONTRIBUTORY)	
gen	m_socialpension = .

gen     d_socialpension = .	  


***** 08 - FOOD AND IN KIND TRANSFERS
* No existe información sobre ingresos en esta categoría
gen      m_inkind = .

egen  aux_inkind = max(sp_ph_subsidioinkind), by(id) 

gen     d_inkind = 0	    
replace d_inkind = 1	if  aux_inkind==1    
replace d_inkind = 1	if  m_inkind>0 & m_inkind<.         
drop aux_inkind


***** 09 - SCHOOL FEEDING 
* No existe información sobre ingresos en esta categoría
gen     m_schoolfeed = .

gen     d_schoolfeed = .	      


***** 10 - PUBLIC WORKS, WORKFARE AND DIRECT JOB CREATION  
* No existe información sobre ingresos en esta categoría
gen     m_publicworks = .

egen    aux_planempleo = max(sp_pi_planempleo), by(id)

gen     d_publicworks = 0
replace d_publicworks = 1	if  aux_planempleo==1	   
replace d_publicworks = 1	if  m_publicworks>0 & m_publicworks<.   
drop aux_planempleo


***** 11 - FEE WAIVERS AND SUBSIDIES 	
* No existe información sobre ingresos en esta categoría
gen     m_subsidies = . 

gen     d_subsidies = .		     


***** 12 - OTHER SOCIAL ASSISTANCE	
by id: egen m_othersa = sum(sp_mi_scholarship), missing

egen    aux_othersa = max(sp_ph_scholarship), by(id) 

gen     d_othersa = 0		       
replace d_othersa = 1	if  aux_othersa==1  
replace d_othersa = 1	if  m_othersa>0 & m_othersa<.    
drop aux_othersa


**********************************************
******* PRIVATE TRANSFERS
**********************************************

***** 13 - DOMESTIC PRIVATE TRANSFERS 
by id: egen m_domprivate = sum(pt_mi_domesticremittances), missing

egen        aux_domesticremittances = max(pt_ph_domesticremittances), by(id) 
egen  aux_domesticremittancesinkind = max(pt_ph_domesticremittancesinkind), by(id) 

gen     d_domprivate = 0	  
replace d_domprivate = 1	if  aux_domesticremittances==1  
replace d_domprivate = 1	if  aux_domesticremittancesinkind==1    
replace d_domprivate = 1	if  m_domprivate>0 & m_domprivate<.    
drop aux_domesticremittances*


***** 14 - INTERNATIONAL PRIVATE TRANSFERS 	
gen     m_interprivate = . 

gen     d_interprivate = 0	  
replace d_interprivate = 1	if  m_interprivate>0 & m_interprivate<. 


/* LABEL VARIABLES */	 
label var m_pensions      "Contributory pensions - monthly in LCU (HH)"
label var m_socialsecu    "Other social insurance - monthly in LCU (HH)"
label var m_passivelabor  "Passive labor market programs - monthly in LCU (HH)"
label var m_activelabor   "Active labor market programs - monthly in LCU (HH)"
label var m_cashtransfer  "Cash transfers,last resort programs - monthly in LCU (HH)"
label var m_cct           "Conditional cash transfer programs - monthly in LCU (HH)"
label var m_socialpension "Non-contributory social pensions - monthly in LCU (HH)"
label var m_inkind        "Food and in-kind transfers - monthly in LCU (HH)"
label var m_schoolfeed    "School feeding - monthly in LCU (HH)"
label var m_publicworks   "Public works & food for work - monthly in LCU (HH)"
label var m_subsidies     "Fee waivers and targeted subsidies - monthly in LCU (HH)" 
label var m_othersa       "Other social assistance programs - monthly in LCU (HH)"
label var m_domprivate    "Domestic private transfers - monthly in LCU (HH)"
label var m_interprivate  "International private transfers - monthly in LCU (HH)"

label var d_pensions      "Contributory pensions - y/n (HH)"
label var d_socialsecu    "Other social insurance - y/n (HH)"
label var d_passivelabor  "Passive labor market programs - y/n (HH)"
label var d_activelabor   "Active labor market programs - y/n (HH)"
label var d_cashtransfer  "Cash transfers,last resort programs - y/n (HH)"
label var d_cct           "Conditional cash transfer programs - y/n (HH)"
label var d_socialpension "Non-contributory social pensions - y/n (HH)"
label var d_inkind        "Food and in-kind transfers - y/n (HH)"
label var d_schoolfeed    "School feeding - y/n (HH)"
label var d_publicworks   "Public works & food for work - y/n (HH)"
label var d_subsidies     "Fee waivers and targeted subsidies - y/n (HH)" 
label var d_othersa       "Other social assistance programs - y/n (HH)"
label var d_domprivate    "Domestic private transfers - y/n (HH)"
label var d_interprivate  "International private transfers - y/n (HH)"


/***********************************************************************************************************

* Label GMD variables
label var hhid        "Household unique identifier - GMD"
label var pid         "Identifier of household member - GMD"
label var survey      "Survey name"
label var countryname "Country name"
label var pais        "Country code WDI"
label var ano         "Survey year"
label var welfare     "Household total income, monthly in LCU - deflated"
label var welfarenom  "Household total income, monthly in LCU - nominal"


* Se queda con variables necesarias (comunes a todas las bases y especificas de cada encuesta)
sort id com
keep survey countryname pais ano encuesta_ocaux hhid pid id com pondera strata psu relacion_est hombre edad gedad1 miembros estado_civil raza region_est1 ///
urbano alfabeto asiste edu_pub aedu nivel tipo_ocaux ocupado desocupa pea edad_min hstrt relab relab_s empresa sector1d contrato ///
contribute_pension ss_healthinsured seguro_salud welfare welfarenom itf itf_sin_ri lp_extrema lp_moderada sp_* pt_* d_* m_*

* Ordena la base de datos
order pais countryname ano survey encuesta_ocaux hhid pid id com strata psu region_est1 urbano pondera miembros relacion_est hombre edad gedad1 miembros ///
estado_civil raza alfabeto asiste edu_pub aedu nivel tipo_ocaux ocupado desocupa pea edad_min hstrt relab relab_s empresa sector1d ///
contrato contribute_pension ss_healthinsured seguro_salud welfare welfarenom itf itf_sin_ri lp_extrema lp_moderada sp_* pt_* d_* m_*

* Guarda base de datos procesada
saveold "S:\2- HARMONIZED DATA\Do and Ini Files for ADePT\LAC\Argentina\2013\2- Do, ini and dta files - Program Specific\arg13_sp.dta", replace


*****************************************************  END OF FILE ******************************************************************/
