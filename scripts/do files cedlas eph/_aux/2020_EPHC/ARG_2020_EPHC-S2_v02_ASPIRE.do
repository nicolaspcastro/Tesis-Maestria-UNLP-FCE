******************************************************************************************************
******************************************************************************************************
**                                                                                                  
**              ATLAS OF SOCIAL PROTECTION INDICATORS OF RESILIENCE AND EQUITY (ASPIRE)             
**                                  PROGRAM SPECIFIC FILE				                           
**           																					    
** COUNTRY:	                    ARGENTINA
** COUNTRY ISO CODE:            ARG
** YEAR:	                    2020 - Second Semester
** SURVEY NAME:                 Encuesta Permanente de Hogares Continua (EPHC)
** SURVEY AGENCY:               Instituto Nacional de Estadísticas y Censos
** SURVEY SOURCE:               LAC Datalib/CEDLAS
** UNIT OF ANALYSIS:            Individuals and households
** INPUT DATABASES:             ARG_2020_EPHC-S2_v01_M_v01_A_SEDLAC-03_ALL.dta
**                              ARG_2020_EPHC-S2_v01_M_v01_A_SEDLAC-03_GMD.dta
** RESPONSIBLE:                 Leopoldo Tornarolli
** CREATED:                     31/03/2022
** NUMBER OF HOUSEHOLDS:         
** NUMBER OF INDIVIDUALS:       
**                                                                                                 
******************************************************************************************************
******************************************************************************************************/


/*
clear all
cap log close
set more off
macro drop _all

gl baseo "S:\1- RAW DATA\LAC\Argentina\2020\Data"
cd       "S:\2- HARMONIZED DATA\Do and Ini Files for ADePT\LAC\Argentina\2020\2- Do, ini and dta files - Program Specific"


***************************************
*    SURVEY INFORMATION & WELFARE     *
***************************************

datalibweb, country(ARG) year(2020) type(GMD) vermast(01) veralt(01) survey(EPHC) module(ALL) clear
isid hhid pid

* Welfare GMD: this is per capita and annual
* Make wefare variables household total and monthly
replace welfarenom = (welfarenom*hsize)/12
replace welfaredef = (welfaredef*hsize)/12

* Label GMD variables
label var countryname "Country name"
label  var cpi2011    "CPI deflator"
label var icp2011     "ICP deflator"
label var welfarenom  "Total household income, monthly in LCU - nominal"
label var welfaredef  "Total household income, monthly in LCU - deflated"

* Define value labels
label define relation 1"Head" 2"Spouse" 3"Child" 4"Parents" 5"Other relative" 6"Non-relative"
label values relationharm relation 

label define marital  1"Married" 2"Never married" 3"Living together" 4"Divorced/Separated" 5"Widowed"
label values marital marital

label define lstatus  1"Employed" 2"Unemployed" 3"Not in labor force"
label values lstatus lstatus

label def empstat     1"Paid Employee" 2"Non-Paid Employee" 3"Employer" 4"Self-employed" 5"Other, workers not classifiable by stat"
label values empstat empstat
                    
label def industry    1"Agriculture" 2"Industry" 3"Services" 4"Other"
label values industrycat4 industry 

label def school      0"No" 1"Yes"
label values school school

label def literacy    0"No" 1"Yes"
label values literacy literacy

label def edu4        1"No education" 2"Primary (complete or incomplete)" 3"Secondary (complete or incomplete)" 4"Tertiary (complete or incomplete)"

label def edu7        1"No education" 2"Primary (complete or incomplete)" 3"Primary complete" 4"Secondary incomplete" 5"Secondary complete" 6"Post secondary but not university" 7"University incomplete or complete"
label values educat7 educat7


*keep  countryname countrycode year survname vermast veralt hhid hhid_orig pid subnatid strata psu urban weight_h weight_p hsize relationharm male age marital minlaborage lstatus empstat occup ocusec contract industrycat4 nlfreason school literacy educy educat4 educat7 welfarenom welfaredef spdef cpi2011 icp2011
*order countryname countrycode year survname vermast veralt hhid hhid_orig pid subnatid strata psu urban weight_h weight_p hsize relationharm male age marital minlaborage lstatus empstat occup ocusec contract industrycat4 nlfreason school literacy educy educat4 educat7 welfarenom welfaredef spdef cpi2011 icp2011

keep  countryname countrycode year survname hhid pid subnatid strata psu urban weight_h weight_p hsize relationharm male age marital lstatus empstat industrycat4 school literacy educy educat4 educat7 welfarenom welfaredef spdef cpi2011 icp2011 
order countryname countrycode year survname hhid pid subnatid strata psu urban weight_h weight_p hsize relationharm male age marital lstatus empstat industrycat4 school literacy educy educat4 educat7 welfarenom welfaredef spdef cpi2011 icp2011 

save temp1.dta, replace


***************************************
*     SOCIAL PROTECTION VARIABLES     *
***************************************

*  Open SEDLAC databases
local code        = "ARG"
local countryname = "Argentina"
local year        =  2020
local survey      = "EPHC"

dlw, coun(`code') y(`year') sur(`survey') t(SEDLAC-03) mod(ALL) verm(01) vera(01)  

local survey=r(survname)
local countryname= r(countryname) 

local varlist1 "sp_* pt_* d_* aux* m_* ss_healthinsured entitled_health"
drop `varlist1'
*/


**************************************************************************************************
**************************************************************************************************
*** PRIMERA PARTE - VARIABLES ESPECIFICAS DE PROTECTION SOCIAL
**************************************************************************************************
**************************************************************************************************

*********************************************************************
**  ENTITLEMENT TO SOCIAL PROTECTION
*********************************************************************

/* SECCION OCUPACION PRINCIPAL DE LOS ASALARIADOS - CUESTIONARIO INDIVIDUAL
   PP7H:  Por ese trabajo tiene descuento jubilatorio? 											*/
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
		9 = NS/NR																				*/
gen       sp_pi_planempleo = 0          	if  pp07e>=1 & pp07e<=4
replace   sp_pi_planempleo = 1         	if  pp07e==1 
label var sp_pi_planempleo "Beneficiary of Plan de empleo - y/n (ind)"

gen       sp_pi_pasantia = 0	        	if  pp07e>=1 & pp07e<=4 
replace   sp_pi_pasantia = 1            	if  pp07e==3
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
replace   sp_ph_oldagepension = 1	            if  v2==1 | v21==1 
label var sp_ph_oldagepension "Old age pension - y/n (hou)"
	
* V4: Seguro de Desempleo - Participatory						
gen       sp_ph_unemploymentbenefits = 0		
replace   sp_ph_unemploymentbenefits = 1   	if  v4==1
label var sp_ph_unemploymentbenefits "Unemployment benefits - y/n (hou)"

* V5: Subsidio/Ayuda Social en dinero de Gobierno/Iglesias/Escuelas Participatory	
gen       sp_ph_subsidiocash = 0 
replace   sp_ph_subsidiocash = 1          	if  v5==1
label var sp_ph_subsidiocash  "Social transfers from government, churches, etc.- y/n (hou)"

* V6: Mercaderia, Ropa, Alimentos de Gobierno/Iglesias/Escuelas Participatory		
gen       sp_ph_subsidioinkind = 0 
replace   sp_ph_subsidioinkind = 1	     	if  v6==1
label var sp_ph_subsidioinkind "In kind social transfers from government, churches, etc.- y/n (hou)"

* V7: Ayuda Familiar Domestica en Especie - Participatory				
gen       pt_ph_domesticremittancesinkind = 0 
replace   pt_ph_domesticremittancesinkind = 1	if  v7==1
label var pt_ph_domesticremittancesinkind "In kind private transfers - y/n (hou)"

* V11: Becas de Estudio - Participatory							
gen       sp_ph_scholarship = 0 
replace   sp_ph_scholarship = 1		       	if  v11==1
label var sp_ph_scholarship "Scholarships - y/n (hou)"

* V12: Ayudas en Dinero/Cuotas de Alimentos - Participatory			
gen       pt_ph_domesticremittances = 0 
replace   pt_ph_domesticremittances = 1	  	if  v12==1
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
egen 	  sp_mi_oldagepension = rsum(v2_m_hd v21_m_hd), missing
replace   sp_mi_oldagepension = .				if  sp_mi_oldagepension==0
label var sp_mi_oldagepension "Old age pension - monthly in LCU (ind)"

* V4_M: Seguro de Desempleo - Monetary							
gen	  sp_mi_unemploymentbenefits = v4_m_hd
replace   sp_mi_unemploymentbenefits = .		if  sp_mi_unemploymentbenefits==0
label var sp_mi_unemploymentbenefit "Unemployment benefits - monthly in LCU (ind)"

* V5_M: Subsidio/Ayuda Social en dinero de Gobierno/Iglesias - Monetary			
gen       sp_mi_subsidiocash = v5_m_hd		
replace   sp_mi_subsidiocash = .				if  sp_mi_subsidiocash==0
label var sp_mi_subsidiocash "Social transfers from government, churches, etc. - monthly in LCU (ind)"
	
* V11_M: Becas de Estudio - Monetary							
gen       sp_mi_scholarship = v11_m_hd		
replace   sp_mi_scholarship = .				if  sp_mi_scholarship==0	
label var sp_mi_scholarship "Scholarships - monthly in LCU (ind)"

* V12_M: Ayudas en Dinero/Cuotas de Alimentos Monetary					
gen       pt_mi_domesticremittances = v12_m_hd		
replace   pt_mi_domesticremittances = .		if  pt_mi_domesticremittances==0
label var pt_mi_domesticremittances "Alimony, private cash transfers - monthly in LCU (ind)"


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

egen      aux_pensions = max(sp_ph_oldagepension), by(id)

gen     d_pensions = 0		
replace d_pensions = 1 			if  aux_pensions==1
replace d_pensions = 1			if  m_pensions>0 & m_pensions<.
drop aux_pensions


***** 02 - OTHER SOCIAL INSURANCE
* No existe información sobre ingresos en esta categoría
gen m_socialsecu = .

gen d_socialsecu = .	  


**********************************************
******* LABOR MARKET 
**********************************************

***** 03 - LABOR MARKET POLICY MEASURES (ACTIVE LM PROGRAMS)
* No existe información sobre ingresos en esta categoría
gen     m_activelabor = .

egen     aux_pasantia = max(sp_pi_pasantia), by(id)

gen     d_activelabor = 0	 
replace d_activelabor = 1			if  aux_pasantia==1
replace d_activelabor = 1			if  m_activelabor>0 & m_activelabor<.
drop aux_pasantia


***** 04 - LABOR MARKET POLICY SUPPORT (PASSIVE LM PROGRAMS)
by id: 	egen m_passivelabor = sum(sp_mi_unemploymentbenefits), missing

egen  aux_unemploymentbenefits = max(sp_ph_unemploymentbenefits), by(id)

gen     d_passivelabor = 0	
replace d_passivelabor = 1		if  aux_unemploymentbenefits==1
replace d_passivelabor = 1		if  m_passivelabor>0 & m_passivelabor<.  
drop aux_unemploymentbenefits


**********************************************
******* SOCIAL ASSISTANCE 
**********************************************
  
***** 05 - UNCONDITIONAL CASH TRANSFERS	
by id: egen m_cashtransfer = sum(sp_mi_subsidiocash), missing

egen      aux_subsidiocash = max(sp_ph_subsidiocash), by(id)

gen     d_cashtransfer = 0		   
replace d_cashtransfer = 1		if  aux_subsidiocash==1
replace d_cashtransfer = 1		if  m_cashtransfer>0 & m_cashtransfer<.    
drop aux_subsidiocash


***** 06 - CONDITIONAL CASH TRANSFERS
* No existe información sobre ingresos en esta categoría
gen m_cct = .

gen d_cct = .            


***** 07 - SOCIAL PENSIONS (NON-CONTRIBUTORY)	
gen	m_socialpension = .

gen d_socialpension = .	  


***** 08 - FOOD AND IN KIND TRANSFERS
* No existe información sobre ingresos en esta categoría
gen     m_inkind = .

egen  aux_inkind = max(sp_ph_subsidioinkind), by(id) 

gen     d_inkind = 0	    
replace d_inkind = 1				if  aux_inkind==1    
replace d_inkind = 1				if  m_inkind>0 & m_inkind<.         
drop aux_inkind


***** 09 - SCHOOL FEEDING 
* No existe información sobre ingresos en esta categoría
gen m_schoolfeed = .

gen d_schoolfeed = .	      


***** 10 - PUBLIC WORKS, WORKFARE AND DIRECT JOB CREATION  
* No existe información sobre ingresos en esta categoría
gen     m_publicworks = .

egen   aux_planempleo = max(sp_pi_planempleo), by(id)

gen     d_publicworks = 0
replace d_publicworks = 1			if  aux_planempleo==1	   
replace d_publicworks = 1			if  m_publicworks>0 & m_publicworks<.   
drop aux_planempleo


***** 11 - FEE WAIVERS AND SUBSIDIES 	
* No existe información sobre ingresos en esta categoría
gen m_subsidies = . 

gen d_subsidies = .		     


***** 12 - OTHER SOCIAL ASSISTANCE	
by id: egen m_othersa = sum(sp_mi_scholarship), missing

egen      aux_othersa = max(sp_ph_scholarship), by(id) 

gen     d_othersa = 0		       
replace d_othersa = 1			if  aux_othersa==1  
replace d_othersa = 1			if  m_othersa>0 & m_othersa<.    
drop aux_othersa


**********************************************
******* PRIVATE TRANSFERS
**********************************************

***** 13 - DOMESTIC PRIVATE TRANSFERS 
by id: egen m_domprivate = sum(pt_mi_domesticremittances), missing

egen        aux_domesticremittances = max(pt_ph_domesticremittances), by(id) 
egen  aux_domesticremittancesinkind = max(pt_ph_domesticremittancesinkind), by(id) 

gen     d_domprivate = 0	  
replace d_domprivate = 1			if  aux_domesticremittances==1  
replace d_domprivate = 1			if  aux_domesticremittancesinkind==1    
replace d_domprivate = 1			if  m_domprivate>0 & m_domprivate<.    
drop aux_domesticremittances*


***** 14 - INTERNATIONAL PRIVATE TRANSFERS 	
gen     m_interprivate = . 

gen     d_interprivate = 0	  
replace d_interprivate = 1		if  m_interprivate>0 & m_interprivate<. 


/* LABEL VARIABLES */	 
label var m_pensions      	"Contributory pensions - monthly in LCU (HH)"
label var m_socialsecu    	"Other social insurance - monthly in LCU (HH)"
label var m_passivelabor  	"Passive labor market programs - monthly in LCU (HH)"
label var m_activelabor   	"Active labor market programs - monthly in LCU (HH)"
label var m_cashtransfer  	"Cash transfers,last resort programs - monthly in LCU (HH)"
label var m_cct           	"Conditional cash transfer programs - monthly in LCU (HH)"
label var m_socialpension 	"Non-contributory social pensions - monthly in LCU (HH)"
label var m_inkind        	"Food and in-kind transfers - monthly in LCU (HH)"
label var m_schoolfeed    	"School feeding - monthly in LCU (HH)"
label var m_publicworks   	"Public works & food for work - monthly in LCU (HH)"
label var m_subsidies     	"Fee waivers and targeted subsidies - monthly in LCU (HH)" 
label var m_othersa       	"Other social assistance programs - monthly in LCU (HH)"
label var m_domprivate    	"Domestic private transfers - monthly in LCU (HH)"
label var m_interprivate  	"International private transfers - monthly in LCU (HH)"

label var d_pensions      	"Contributory pensions - y/n (HH)"
label var d_socialsecu    	"Other social insurance - y/n (HH)"
label var d_passivelabor  	"Passive labor market programs - y/n (HH)"
label var d_activelabor   	"Active labor market programs - y/n (HH)"
label var d_cashtransfer  	"Cash transfers,last resort programs - y/n (HH)"
label var d_cct           	"Conditional cash transfer programs - y/n (HH)"
label var d_socialpension 	"Non-contributory social pensions - y/n (HH)"
label var d_inkind        	"Food and in-kind transfers - y/n (HH)"
label var d_schoolfeed    	"School feeding - y/n (HH)"
label var d_publicworks   	"Public works & food for work - y/n (HH)"
label var d_subsidies     	"Fee waivers and targeted subsidies - y/n (HH)" 
label var d_othersa       	"Other social assistance programs - y/n (HH)"
label var d_domprivate    	"Domestic private transfers - y/n (HH)"
label var d_interprivate  	"International private transfers - y/n (HH)"

/*
keep  hhid pid lp_extrema lp_moderada ss_healthinsured entitled_health sp_* pt_* d_* m_*
order hhid pid lp_extrema lp_moderada ss_healthinsured entitled_health sp_* pt_* d_* m_*

sort hhid pid 
save temp2.dta, replace

***********************************************************************************************************

* Merge databases		
use   temp1.dta, clear
merge 1:1 hhid pid using temp2.dta
tab  _merge
drop if _merge==2
drop _merge

* Save procesed database
sort hhid pid
save arg20_sp.dta, replace

erase temp1.dta
erase temp2.dta

***********************************************************************************************************/
