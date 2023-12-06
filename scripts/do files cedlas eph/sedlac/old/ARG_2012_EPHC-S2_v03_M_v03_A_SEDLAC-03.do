/*=========================================================================
Country name:		Argentina
Year:			2012-S2
Survey:			EPHC
Vintage:		03M-03A
Project:		03
---------------------------------------------------------------------------
Author:			Leopoldo Tornarolli
			leopoldo.tornarolli@depeco.econo.unlp.edu.ar
Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		January, 2021
Output:			sedlac do-file template
===========================================================================*/

/*=========================================================================
                        0: Program set up
===========================================================================*/
version 10
drop _all

local country  "ARG"    // Country ISO code
local year     "2012"   // Year of the survey
local survey   "EPHC"   // Survey acronym
local vm       "03"     // Master version
local va       "03"     // Alternative version
local project  "03"     // Project version
local period   "-S2"    // Periodo, ejemplo -S1 -S2
local alterna  ""       // 
local vr       "02"     // version renta
local vsp      "01"	// version ASPIRE
include "${rootdatalib}/_git_sedlac-03/_aux/sedlac_hardcode.do"

/*================================================================================================================================================
			1: Preparacion de los datos: Variables de Primer Orden
================================================================================================================================================*/

/*(************************************************************************************************************************************************ 
			1.1: Abrir bases de datos  
************************************************************************************************************************************************)*/ 

* Abre base de datos original  
use "`base_out_nesstar_base'", clear

/*(************************************************************************************************************************************************ 
			1.2: Variables de identificacion  
************************************************************************************************************************************************)*/
destring decindr decifr deccfr, replace

* Identificador del pais:		pais
gen pais = "arg"

* Identificador del año:		ano
gen ano = 2012

* Identificador de la encuesta:		encuesta
gen encuesta = "EPHC-S2"

* Identificador del hogar:		id      
*    CODUSU: código para distinguir viviendas 
*  NROHOGAR: código para distinguir hogares
* TRIMESTRE: trimestre de la entrevista
sort            codusu nro_hogar trimestre 
egen id = group(codusu nro_hogar trimestre)   

local vars "codusu nro_hogar trimestre"     
if "`vars'"!="" {
	gen hhid = ""
	local zero "0"
	
	foreach var of local vars { // vars
		tempvar str`var' actd`var' nzer`var'
		local type: type `var'
		if strpos("`type'", "str")!=0  gen `str`var'' = `var' // if string
		
		else { // if not string
			
			local i = 0
			while 1 { // exponent
				local a = 10^`i'
				local minran = 1*`a'
				local maxran = 10*`a'-1
				qui sum `var'
				if  inrange(`r(max)', `minran',`maxran') {
					local maxd `=`i'+1' // number of max digits
					continue, break
				}
				else local ++i
			}
			
			tostring `var', gen(`str`var'')  usedisplayformat `force' // if not string (usedisplay format for chl2011)
			gen `actd`var'' = strlen(`str`var'')  // actual num of digits 
			gen `nzer`var'' = `maxd'-`actd`var''  // number of zeros
			local num ""
			foreach z of numlist 1(1)`maxd' {
				local num "`zero'`num'"
				local num`z' "`num'"
				replace `str`var'' = "`num`z''"+ `str`var'' if `nzer`var'' == `z' 
			} // z loop
		} //else 
		replace hhid = hhid + `str`var''
	} // vars loop
} // if vars exist
notes hhid: original variables used were: codusu, nro_hogar, and trimestre 

* Identificador del componente:		com
gen com = componen

gen double pid = componen
notes pid: original variable used was: componen 

* Chequea posibles duplicados
duplicates report id com

* Factor de Ponderación:		pondera
* PONDERA: factor de expansión de observaciones
rename pondera pondera_eph
gen  pondera = pondera_eph

* Estrato:				strata
gen   strata = .
notes strata: the survey does not include information on this topic

* Unidad Primaria de Muestreo:		psu 
gen   psu = .
notes psu: the survey does not include information on this topic


/*(************************************************************************************************************************************************* 
			1.3: Variables demograficas  
*************************************************************************************************************************************************)*/

/*  Relación con el jefe de hogar:	relacion
    Categorías de la nueva variable armonizada:
		1:  jefe		
		2:  esposo/cónyuge
		3:  hijo/hija		(hijastro/hijastra)		
		4:  padre/madre		(suegro/suegra)
		5:  otro pariente	(nieto/yerno/nuera)
		6:  no pariente										
    
    CH03: Relación de Parentesco 
		01 = Jefe		02 = Cónyuge/Pareja
		03 = Hijo/Hijastro	04 = Yerno/Nuera
		05 = Nieto		06 = Madre/Padre
		07 = Suegro		08 = Hermano
		09 = Otros Familiares	10 = No Familiares				*/
gen     relacion = 1		if  ch03==1
replace relacion = 2		if  ch03==2
replace relacion = 3		if  ch03==3  
replace relacion = 4		if  ch03==6  |  ch03==7
replace relacion = 5		if  ch03==4  |  ch03==5  | ch03==8 | ch03==9
replace relacion = 6		if  ch03==10 | (nro_hogar>=51 & nro_hogar<=91) | componen==51

* Estandarizada
gen     relacion_est = " 1 - Household Head                   "	if  ch03==1
replace relacion_est = " 2 - Spouse                           "	if  ch03==2
replace relacion_est = " 3 - Son/Daughter/Stepson/Stepdaughter"	if  ch03==3
replace relacion_est = " 4 - Son/Daughter in-law              "	if  ch03==4
replace relacion_est = " 5 - Grandchild                       "	if  ch03==5
replace relacion_est = " 6 - Father/Mother                    "	if  ch03==6
replace relacion_est = " 7 - Father/Mother in-law             "	if  ch03==7
replace relacion_est = " 8 - Brother/Sister                   "	if  ch03==8
replace relacion_est = " 9 - Other Relatives                  "	if  ch03==9
replace relacion_est = "10 - Other non Relatives              "	if  ch03==10
replace relacion_est = "11 - Domestic Worker and Family       "	if  (nro_hogar>=51 & nro_hogar<=91) | componen==51

* Miembros de hogares secundarios:	hogarsec
gen     hogarsec = 0
replace hogarsec = 1		if  relacion_est== "11 - Domestic Worker and Family       "
notes   hogarsec: following the definition used by INDEC, non-familiars were included as part of the household, while domestic workers and their families were excluded

* Identificador de hogares:		hogar
gen hogar = 1			if  relacion==1

* Hogares con miembros secundarios:	presec		
tempvar aux
egen `aux' = sum(hogarsec), by(id)
gen       presec = 0
replace   presec = 1		if  `aux'>0  
replace   presec = .		if  relacion~=1

* Numero de miembros del hogar:		miembros
tempvar uno
gen `uno' = 1
egen miembros = sum(`uno')	if  hogarsec==0 & relacion~=., by(id)

* CH06: ¿cuántos años cumplidos tiene? 
gen 	edad = ch06 
replace edad = 0		if  edad==-1 
replace edad = .		if  edad==99 
notes edad: range of the variable: 0 - 98+

* Dummy de hombre:			hombre 
/* CH04: sexo
          1 = hombres
	  2 = mujeres									*/
gen     hombre = 0		if  ch04==2
replace hombre = 1		if  ch04==1	

* Dummy de estado civil 1:		casado
/* CH07: ¿Actualmente está:
		1 = unido?
		2 = casado?
		3 = separado ó divorciado?
		4 = viudo?	    	
		5 = soltero?								*/
gen     casado = 0		if  ch07>=1 & ch07<=5
replace casado = 1		if  ch07==1 | ch07==2

* Dummy de estado civil 2:		soltero 
gen     soltero = 0		if  ch07>=1 & ch07<=5
replace soltero = 1		if  ch07==5

* Estado Civil
/* 1 = married
   2 = never married
   3 = living together
   4 = divorced/separated
   5 = widowed										*/
gen     estado_civil = 1	if  ch07==2
replace estado_civil = 2	if  ch07==5
replace estado_civil = 3	if  ch07==1
replace estado_civil = 4	if  ch07==3
replace estado_civil = 5	if  ch07==4

* Raza o etnicidad:			raza 
gen   raza = .
notes raza: the survey does not include information on this topic

gen          raza_est = . 
label define raza_est 1 "" 2 ""
label values raza_est raza_est

* Lengua:				lengua
gen   lengua = .
notes lengua: the survey does not include information on this topic

gen          lengua_est = . 
label define lengua_est 1 "" 2 ""
label values lengua_est lengua_est


/*(************************************************************************************************************************************************* 
			1.4: Variables regionales  
**************************************************************************************************************************************************)*/

/* REGION:	 1 =  Gran Buenos Aires 		
		40 = NOA
		41 = NEA				
		42 = Cuyo
		43 = Pampeana				
		44 = Patagonia								*/

* Desagregación 1 (Región):		region_est1
rename  region region_ephc
gen	region_est1 = "1 - Gran Buenos Aires "			if  region_ephc==1			
replace	region_est1 = "2 - Pampeana          "			if  region_ephc==43 			
replace	region_est1 = "3 - Cuyo              "			if  region_ephc==42			
replace	region_est1 = "4 - Noroeste Argentino"			if  region_ephc==40			 
replace	region_est1 = "5 - Patagonia         "			if  region_ephc==44				
replace	region_est1 = "6 - Noreste Argentino "			if  region_ephc==41			
notes   region_est1: Region
notes   region_est1: Representative

* Desagregación 2 (Aglomerado):		region_est2
gen	region_est2 = " 2 - Gran La Plata                 "	if  aglomerado==2
replace region_est2 = " 3 - Bahia Blanca-Cerri            "	if  aglomerado==3
replace region_est2 = " 4 - Gran Rosario                  "	if  aglomerado==4
replace region_est2 = " 5 - Gran Santa Fe                 "	if  aglomerado==5
replace region_est2 = " 6 - Gran Parana                   "	if  aglomerado==6
replace region_est2 = " 7 - Posadas                       "	if  aglomerado==7
replace region_est2 = " 8 - Gran Resistencia              "	if  aglomerado==8
replace region_est2 = " 9 - Comodoro Rivadavia-Rada Tilly "	if  aglomerado==9
replace region_est2 = "10 - Gran Mendoza                  "	if  aglomerado==10
replace region_est2 = "12 - Corrientes                    "	if  aglomerado==12
replace region_est2 = "13 - Gran Cordoba                  "	if  aglomerado==13
replace region_est2 = "14 - Concordia                     "	if  aglomerado==14
replace region_est2 = "15 - Formosa                       "	if  aglomerado==15
replace region_est2 = "17 - Neuquen-Plottier              "	if  aglomerado==17
replace region_est2 = "18 - Santiago del Estero-La Banda  "	if  aglomerado==18
replace region_est2 = "19 - Jujuy-Palpala                 "	if  aglomerado==19
replace region_est2 = "20 - Rio Gallegos                  "	if  aglomerado==20
replace region_est2 = "22 - Gran Catamarca                "	if  aglomerado==22
replace region_est2 = "23 - Salta                         "	if  aglomerado==23
replace region_est2 = "25 - La Rioja                      "	if  aglomerado==25
replace region_est2 = "26 - San Luis-El Chorrillo         "	if  aglomerado==26
replace region_est2 = "27 - Gran San Juan                 "	if  aglomerado==27
replace region_est2 = "29 - Gran Tucuman-Tafi Viejo       "	if  aglomerado==29
replace region_est2 = "30 - Santa Rosa-Toay               "	if  aglomerado==30
replace region_est2 = "31 - Ushuaia-Rio Grande            "	if  aglomerado==31
replace region_est2 = "32 - Ciudad de Buenos Aires        "	if  aglomerado==32
replace region_est2 = "33 - Partidos del GBA              "	if  aglomerado==33
replace region_est2 = "34 - Mar del Plata-Batan           "	if  aglomerado==34
replace region_est2 = "36 - Rio Cuarto                    "	if  aglomerado==36
replace region_est2 = "38 - San Nicolas-Villa Constitucion"	if  aglomerado==38
replace region_est2 = "91 - Rawson-Trelew                 "	if  aglomerado==91
replace region_est2 = "93 - Viedma-Carmen de Patagones    "	if  aglomerado==93
notes   region_est2: Aglomerado (urban cities with more than 100,000 inhabitants)
notes   region_est2: Representative

* Desagregación 3			region_est3
gen	region_est3 = ""
notes   region_est3: the survey does not include information to define this variable


*************************************************************************************************************
* Desagregación 1 (Región):		region_est1_prev
gen	region_est1_prev = "1 - Gran Buenos Aires "			if  aglomerado==32 | aglomerado==33			
replace	region_est1_prev = "2 - Pampeana          "			if  aglomerado==2  | aglomerado==3  | aglomerado==4  | aglomerado==5 | aglomerado==6  | aglomerado==13 | aglomerado==14 | aglomerado==30 | aglomerado==34 | aglomerado==36			
replace	region_est1_prev = "3 - Cuyo              "			if  aglomerado==10 | aglomerado==26 | aglomerado==27		
replace	region_est1_prev = "4 - Noroeste Argentino"			if  aglomerado==18 | aglomerado==19 | aglomerado==22 | aglomerado==23 | aglomerado==25 | aglomerado==29		 
replace	region_est1_prev = "5 - Patagonia         "			if  aglomerado==9  | aglomerado==17 | aglomerado==20 | aglomerado==31	
replace	region_est1_prev = "6 - Noreste Argentino "			if  aglomerado==7  | aglomerado==8  | aglomerado==12 | aglomerado==15	
notes   region_est1_prev: Region
notes   region_est1_prev: Representative 
notes   region_est1_prev: Does not include aglomerados included since 2006 (San Nicolas-Villa Constitucion, Rawson-Trelew and Viedma-Carmen de Patagones)

* Desagregación 2 (Aglomerado):		region_est2_prev
gen	region_est2_prev = " 2 - Gran La Plata                 "	if  aglomerado==2
replace region_est2_prev = " 3 - Bahia Blanca-Cerri            "	if  aglomerado==3
replace region_est2_prev = " 4 - Gran Rosario                  "	if  aglomerado==4
replace region_est2_prev = " 5 - Gran Santa Fe                 "	if  aglomerado==5
replace region_est2_prev = " 6 - Gran Parana                   "	if  aglomerado==6
replace region_est2_prev = " 7 - Posadas                       "	if  aglomerado==7
replace region_est2_prev = " 8 - Gran Resistencia              "	if  aglomerado==8
replace region_est2_prev = " 9 - Comodoro Rivadavia-Rada Tilly "	if  aglomerado==9
replace region_est2_prev = "10 - Gran Mendoza                  "	if  aglomerado==10
replace region_est2_prev = "12 - Corrientes                    "	if  aglomerado==12
replace region_est2_prev = "13 - Gran Cordoba                  "	if  aglomerado==13
replace region_est2_prev = "14 - Concordia                     "	if  aglomerado==14
replace region_est2_prev = "15 - Formosa                       "	if  aglomerado==15
replace region_est2_prev = "17 - Neuquen-Plottier              "	if  aglomerado==17
replace region_est2_prev = "18 - Santiago del Estero-La Banda  "	if  aglomerado==18
replace region_est2_prev = "19 - Jujuy-Palpala                 "	if  aglomerado==19
replace region_est2_prev = "20 - Rio Gallegos                  "	if  aglomerado==20
replace region_est2_prev = "22 - Gran Catamarca                "	if  aglomerado==22
replace region_est2_prev = "23 - Salta                         "	if  aglomerado==23
replace region_est2_prev = "25 - La Rioja                      "	if  aglomerado==25
replace region_est2_prev = "26 - San Luis-El Chorrillo         "	if  aglomerado==26
replace region_est2_prev = "27 - Gran San Juan                 "	if  aglomerado==27
replace region_est2_prev = "29 - Gran Tucuman-Tafi Viejo       "	if  aglomerado==29
replace region_est2_prev = "30 - Santa Rosa-Toay               "	if  aglomerado==30
replace region_est2_prev = "31 - Ushuaia-Rio Grande            "	if  aglomerado==31
replace region_est2_prev = "32 - Ciudad de Buenos Aires        "	if  aglomerado==32
replace region_est2_prev = "33 - Partidos del GBA              "	if  aglomerado==33
replace region_est2_prev = "34 - Mar del Plata-Batan           "	if  aglomerado==34
replace region_est2_prev = "36 - Rio Cuarto                    "	if  aglomerado==36
notes   region_est2_prev: Aglomerado (urban cities with more than 100,000 inhabitants)
notes   region_est2_prev: Representative
notes   region_est2_prev: Does not include aglomerados included since 2006 (San Nicolas-Villa Constitucion, Rawson-Trelew and Viedma-Carmen de Patagones)

* Desagregación 3			region_est3
gen	region_est3_prev = ""
notes   region_est3_prev: the survey does not include information to define this variable

* Small Level Representative
gen     region_survey = aglomerado
notes   region_survey: dominios de estudio para los cuales la muestra es representativa: nacional, regional y por aglomerado

*************************************************************************************************************

* Dummy urbano-rural:			 urbano 
gen   urbano = 1	
notes urbano: The Argentinean EPHC is a survey carried out in urban areas

*** GAUL VARIABLES

******* GAUL 1 (Administrative: Provincia)
gen     gaul_1 = 429		if  aglomerado==2  | aglomerado==3
replace gaul_1 = 430		if  aglomerado==32
replace gaul_1 = 431		if  aglomerado==22
replace gaul_1 = 432		if  aglomerado==8
replace gaul_1 = 433		if  aglomerado==9  | aglomerado==91
replace gaul_1 = 434		if  aglomerado==13 | aglomerado==36
replace gaul_1 = 435		if  aglomerado==12
replace gaul_1 = 436		if  aglomerado==6  | aglomerado==14 | aglomerado==33 | aglomerado==34 | aglomerado==38
replace gaul_1 = 437		if  aglomerado==15
replace gaul_1 = 438		if  aglomerado==19
replace gaul_1 = 439		if  aglomerado==30
replace gaul_1 = 440		if  aglomerado==25
replace gaul_1 = 441		if  aglomerado==10
replace gaul_1 = 442		if  aglomerado==7
replace gaul_1 = 443		if  aglomerado==17
replace gaul_1 = 444		if  aglomerado==93
replace gaul_1 = 445		if  aglomerado==23
replace gaul_1 = 446		if  aglomerado==27
replace gaul_1 = 447		if  aglomerado==26
replace gaul_1 = 448		if  aglomerado==20
replace gaul_1 = 449		if  aglomerado==4  | aglomerado==5
replace gaul_1 = 450		if  aglomerado==18
replace gaul_1 = 451		if  aglomerado==31
replace gaul_1 = 452		if  aglomerado==29

******* GAUL 2 (Administrative: Ciudad?)
gen     gaul_2 = .
			
******* GAUL 3 (Administrative: Barrio?)
gen     gaul_3 = .

* Dummies regionales 
* Gran Buenos Aires
gen     gba = 1			if  region_ephc==1
replace gba = 0			if  region_ephc!=1
notes   gba: Dummy GBA region

* Pampeana
gen     pampa = 1		if  region_ephc==43
replace pampa = 0		if  region_ephc!=43
notes   pampa: Dummy Pampeana region

* Cuyo
gen     cuyo = 1		if  region_ephc==42
replace cuyo = 0		if  region_ephc!=42
notes   cuyo: Dummy Cuyo region

* NOA
gen     noa = 1			if  region_ephc==40
replace noa = 0			if  region_ephc!=40
notes   noa: Dummy NOA region

* Patagonia
gen     pata = 1		if  region_ephc==44
replace pata = 0		if  region_ephc!=44
notes   pata: Dummy Patagonia region

* NEA
gen     nea = 1			if  region_ephc==41
replace nea = 0			if  region_ephc!=41
notes   nea: Dummy NEA region

* Areas no incluidas en años previos:	nuevareg
gen     nuevareg = 1		if  region_ephc==1
replace nuevareg = 2		if  region_ephc>=40 & region_eph<=44
replace nuevareg = 3		if  aglomerado==3  | aglomerado==4  | aglomerado==7 | aglomerado==8 | aglomerado==10 | aglomerado==12 | aglomerado==14 | aglomerado==15 | aglomerado==22 | aglomerado==25 | aglomerado==29 | aglomerado==34 | aglomerado==36 
replace nuevareg = 4		if  aglomerado==38 | aglomerado==91 | aglomerado==93   
notes   nuevareg: = 1 for regions included in the survey since 1974; = 2 for regions included in the survey since 1992; = 3 for regions included in the survey since 1998; = 4 for region included in the survey since 2006

***************************************************************************************************************************************************

* Discapacidad Visual
gen   dis_visual = .
notes dis_visual: the survey does not include information on this topic

* Discapacidad Auditiva
gen   dis_auditiva = .
notes dis_auditiva: the survey does not include information on this topic

* Discapacidad Caminar
gen   dis_caminar = .
notes dis_caminar: the survey does not include information on this topic

* Discapacidad Concentrarse/Recordar
gen   dis_concent = .
notes dis_concent: the survey does not include information on this topic

* Discapacidad Cuidado
gen   dis_cuidado = .
notes dis_cuidado: the survey does not include information on this topic

* Discapacidad Hablar
gen   dis_leng = .
notes dis_leng: the survey does not include information on this topic 


***************************************************************************************************************************************************

* Migrante (por lugar de nacimiento)
/* CH15: dónde nació
		1 = en esta localidad
		2 = en otra localidad de esta provincia
		3 = en otra provincia
		4 = en un pais limitrofe
		5 = en otro pais
		9 = NS/NR								*/
gen	migrante = 0		if  ch15==1
replace migrante = 1		if  ch15>=2 & ch15<=5

* Tipo de migración: migrante extranjero 
/* = 0 si es migrante de otro municipio del pais
   = 1 si es migrante de otro país extranjero						*/
gen	migra_ext = 0		if  ch15>=2 & ch15<=3 & migrante==1
replace migra_ext = 1		if  ch15>=4 & ch15<=5 & migrante==1

* Migrantes internos (urbano-rural):	migra_rur
gen   migra_rur = .
notes migra_rur: the survey does not include information on this topic

* Años de residencia del migrante:	anios_residencia
gen   anios_residencia = .
notes anios_residencia: the survey does not include information on this topic

* Migrante reciente: migra_rec
/* CH16: dónde vivía hace 5 años? 
		1 = en esta localidad
		2 = en otra localidad de esta provincia
		3 = en otra provincia
		4 = en un pais limitrofe
		5 = en otro pais
		6 = no había nacido
		9 = NS/NR								*/
gen	migra_rec = 0		if  migrante==1 & ch16==1
replace migra_rec = 1		if  migrante==1 & ch16>=2 & ch16<=5


/*(************************************************************************************************************************************************* 
			1.5: Vivienda e infraestructura  
*************************************************************************************************************************************************)*/

* Propiedad de la vivienda:		propieta
/* II7: Régimen de tenencia 
	01 = Propietario de la vivienda y el terreno	
	02 = Propietario de la vivienda solamente
	03 = Inquilino/arrendatario de la vivienda
	04 = Ocupante por pago de impuestos/expensas
	05 = Ocupante en relación de dependencia
	06 = Ocupante gratuito (con permiso)
	07 = Ocupante de hecho (sin permiso)
	08 = Esta en sucesión?
	09 = Otra situación (especificar)						*/
gen     propieta = 1		if  ii7==1 | ii7==2
replace propieta = 0		if  ii7>=3 & ii7<=9
replace propieta = .		if  relacion!=1

* Habitaciones, contando baño y cocina: habita
*   II1: ¿cuántos ambientes/habitaciones tiene este hogar para su uso exclusivo? (sin contar baño, cocina, garage, pasillos)
* II4_1: ¿tiene cuarto de cocina?
*   II9:  baño de uso exclusivo del hogar
gen	habita = ii1		if  ii1<90
replace habita = habita + 1	if  ii4_1==1
replace habita = habita + 1	if  ii9==1
replace habita = .		if  relacion!=1 | habita==0

* Dormitorios de uso exclusivo:		dormi
*   II2: ¿de esos, cuántos usan habitualmente para dormir?
* II5_1:  número de otros cuartos que utiliza para dormir
gen	dormi = ii2 + ii5_1	if  ii2<90
replace dormi = .		if  relacion!=1

* Vivienda en lugar precario:		precaria
/* IV1:  tipo de vivienda
		1 = Casa
		2 = Departamento
		3 = Pieza de Inquilinato
		4 = Pieza en hotel o pensión
		5 = Local no construido para habitacion 
IV12_3 La vivienda está ubicada en villa de emergencia					*/
gen     precaria = 1		if (iv1>=3 & iv1<=6) | iv12_3==1
replace precaria = 0		if (iv1==1 | iv1==2) & iv12_3==2
replace precaria = .		if  relacion!=1

* Material de construcción precario:	matpreca
/* IV3 Los pisos interiores son principalmente de:
	1 =  Mosaico/baldosa/madera/cerámica/alfombra
	2 =  Cemento/ladrillo fijo
	3 =  Ladrillo suelto/tierra
	4 =  Otra

   IV4  La cubierta exterior del techo es de:
	1 =  Membrana/cubierta asfáltica
	2 =  Baldosa/losa sin cubierta
	3 =  Pizarra/teja
	4 =  Chapa de metal sin cubierta
	5 =  Chapa de fibrocemento/plástico
	6 =  Chapa de cartón
	7 =  Caña/tabla/paja con barro/paja sola
	9 =  N/S. Depto en propiedad horizontal

   IV5 El techo tiene cielorraso/revestimiento interior?
	1 =  Si 
	2 =  No										*/
gen     matpreca = 1		if  (iv3>=3 & iv3<=4) |  (iv4>=6 & iv4<=7)
replace matpreca = 0		if  (iv3>=1 & iv3<=2) & ((iv4>=1 & iv4<=5) | iv4==9)
replace matpreca = .		if  relacion!=1

* Instalacion de agua corriente:	agua
/* IV6  Tiene agua:
	1 =  Por cañería dentro de la vivienda
	2 =  Fuera de la vivienda pero dentro del terreno
	3 =  Fuera del terreno

   IV7  El agua es de:
	1 =  Red pública (agua corriente)
	2 =  Perforación con bomba a motor
	3 =  Perforación con bomba manual	
	4 =  Otra fuente								*/
gen     agua = 1		if (iv6==1 | iv6==2) & (iv7==1 | iv7==2)
replace agua = 0		if  iv7==3 | iv7==4  | iv6==3  
replace agua = .		if  relacion!=1

*==========================================================================================*

* Drinking Water Source
gen     water_source =  1	if  iv6==1			/* Piped water into dwelling	*/
replace water_source =  2	if  iv6==2			/* Piped water to yard/plot	*/
replace water_source =  3	if  iv6==3 & iv7==1 		/* Public tap or standpipe	*/
replace water_source =  4	if  iv6==2 & iv7>=2 & iv7<=3	/* Tubewell or borehole		*/
replace water_source =  5	if  iv6==3 & iv7==2		/* Protected dug well		*/
*replace water_source =  6	if  				/* Protected spring		*/
*replace water_source =  7	if  				/* Bottled water		*/
*replace water_source =  8	if  				/* Rainwater			*/
*replace water_source =  9	if  				/* Unprotected spring		*/
replace water_source = 10	if  iv6==3 & iv7==3		/* Unprotected dug well		*/
*replace water_source = 11	if  				/* Cart with small tank/drum	*/
*replace water_source = 12	if  				/* Tanker-truck			*/
*replace water_source = 13	if  				/* Surface water		*/	
replace water_source = 14	if (iv6==2 | iv6==3) & iv7==4 	/* Other			*/

* All piped classification
gen     piped = 0
replace piped = 1		if  inlist(water_source,1,2,3)

* Piped to premises classification 
gen     piped_to_prem = 0
replace piped_to_prem = 1	if  inlist(water_source,1,2)

* Distance to the improved water source
gen   w_30m = .
notes w_30m: the survey does not include information on this topic 

* Availability of improved water 24/7 
gen   w_avail = .
notes w_avail: the survey does not include information on this topic 

* Improved Water Recommended
gen     imp_wat_rec = .
replace imp_wat_rec = 1			if  inlist(iv7,1,2) & inlist(iv6,1,2,3)
replace imp_wat_rec = 0			if  inlist(iv7,3,4,.)

* Improved Water Underestimate
gen     imp_wat_underest = .
replace imp_wat_underest = 1		if  inlist(iv7,1,2) & inlist(iv6,1,2,3) 
replace imp_wat_underest = 0		if  inlist(iv7,3,4,.)

* Improved Water Overestimate
gen     imp_wat_overest = .
replace imp_wat_overest = 1		if  inlist(iv7,1,2) & inlist(iv6,1,2,3) 
replace imp_wat_overest = 0		if  inlist(iv7,3,4,.) 

* Type of question on water
gen     watertype_quest = 2		/* general question about water	*/

* Water Original
gen     water_original = " 1 - Running water piped inside the house                  "	if  iv7==1 & iv6==1
replace water_original = " 2 - Running water inside the yard                         "	if  iv7==1 & iv6==2
replace water_original = " 3 - Running water outside the yard                        "	if  iv7==1 & iv6==3
replace water_original = " 4 - Water drilled with motor pump, piped inside the house "	if  iv7==2 & iv6==1
replace water_original = " 5 - Water drilled with motor pump, inside the yard        "	if  iv7==2 & iv6==2
replace water_original = " 6 - Water drilled with motor pump, outside the yard       "	if  iv7==2 & iv6==3
replace water_original = " 7 - Water drilled with manual pump, piped inside the house"	if  iv7==2 & iv6==1
replace water_original = " 8 - Water drilled with manual pump, inside the yard       "	if  iv7==2 & iv6==2
replace water_original = " 9 - Water drilled with manual pump, outside the yard      "	if  iv7==2 & iv6==3
replace water_original = "10 - Another source, piped inside the house                "	if  iv7==2 & iv6==1
replace water_original = "11 - Another source, inside the yard                       "	if  iv7==2 & iv6==2
replace water_original = "12 - Another source, outside the yard                      "	if  iv7==2 & iv6==3

label define  improved_water 1 "Yes" 0 "No"
label val      imp_wat_rec improved_water
label val imp_wat_underest improved_water
label val  imp_wat_overest improved_water
label val            piped improved_water
label val    piped_to_prem improved_water

label var     water_source "Source of drinking water"
label var            piped "Access to piped water"
label var    piped_to_prem "Piped water to premises"
label var            w_30m "Improved water source within 30 minutes"
label var          w_avail "Availability of improved water source 24/7"
label var      imp_wat_rec "Access to improved drinking water-MPI & WGP - Recommended"
label var imp_wat_underest "Access to improved drinking water-MPI & WGP - Underestimate"
label var  imp_wat_overest "Access to improved drinking water-MPI & WGP - Overestimate"
label var  watertype_quest "Type of question on water" 
label var   water_original "Original water variable"

*============================================================================================================*

* Baño con arrastre de agua:		banio
/* IV8  Tiene baño/letrina?
   IV9  El baño o letrina está:
	1 = Dentro de la vivienda
	2 = Fuera de la vivienda pero dentro del terreno
	3 = Fuera del terreno
  IV10  El baño tiene:
	1 = Inodoro con botón/mochila/cadena y arrastre de agua
	2 = Inodoro sin botón/cadena y con arrastre de agua (a balde)
	3 = Letrina (sin arrastre de agua)				
  IV11  El desague del baño es:
	1 = A red pública (cloaca)
	2 = A cámara séptica y pozo ciego
	3 = Sólo a pozo ciego
	4 = A hoyo/excavación en al tierra						*/
gen     banio = 0		if  iv8==2 | iv9==3 | (iv10==2 | iv10==3)
replace banio = 1		if  iv10==1
replace banio = .		if  relacion!=1

* Cloacas:				cloacas
gen     cloacas = 1		if  banio==1 &  iv11==1 
replace cloacas = 0		if  banio==0 | (iv11>=2 & iv11<=4) 
replace cloacas = .		if  relacion!=1

*============================================================================================================*

* Sanitation Source
gen     sanitation_source =  1	if  iv10==1				/* A flush toilet		         IMP	*/
replace sanitation_source =  2	if (iv10==1 | iv10==2) & iv11==1	/* A piped sewer system		         IMP	*/
replace sanitation_source =  3	if (iv10==1 | iv10==2) & iv11==2	/* A septic tank		         IMP	*/
replace sanitation_source =  4	if (iv10==1 | iv10==2) & iv11==3	/* Pit latrine			         IMP	*/
*replace sanitation_source =  5	if					/* Ventilated improved pit latrine (VIP) IMP	*/
*replace sanitation_source =  6	if					/* Pit latrine with slab		 IMP	*/
*replace sanitation_source =  7	if					/* Composting toilet		         IMP	*/
*replace sanitation_source =  8	if					/* Special case					*/
replace sanitation_source =  9	if  (iv10==1 | iv10==2) & iv11==4	/* A flush/pour flush to elsewhere		*/
replace sanitation_source = 10	if  iv10==3				/* A pit latrine without slab			*/
*replace sanitation_source = 11	if					/* Bucket					*/
*replace sanitation_source = 12	if					/* Hanging toilet or hanging latrine		*/
replace sanitation_source = 13	if  iv8==2				/* No facilities or bush or field		*/
*replace sanitation_source = 14	if					/* Other					*/

* Sewer
gen     sewer = 0
replace sewer = 1		if  sanitation_source==2

* Open defecation
gen     open_def = 0
replace open_def = 1		if  sanitation_source==13

* Improved Sanitation Recommended
gen     imp_san_rec = .
replace imp_san_rec = 1	        if  iv8==1 & (inlist(iv10,1,2) & inlist(iv11,1,2,3))    
replace imp_san_rec = 0		    if  iv8==2 | (iv8==1 & iv10==1 & iv11==4)   

* Improved Sanitation Underestimate
gen     imp_san_underest = .	   
replace imp_san_underest = 1	if  iv8==1 & (inlist(iv10,1,2) & inlist(iv11,1,2,3))
replace imp_san_underest = 0	if  iv8==2 | (iv8==1 & iv10==1 & iv11==4)     

* Improved Sanitation Overestimate
gen     imp_san_overest = .
replace imp_san_overest = 1	    if  iv8==1 & (inlist(iv10,1,2) & inlist(iv11,1,2,3))
replace imp_san_overest = 0	    if  iv8==2 | (iv8==1 & iv10==1 & iv11==4)

* Access to flushed toilet
gen     toilet_acc = 0		if   iv8==2 | iv10==2 | iv10==3	/* No						*/
replace toilet_acc = 1		if  iv10==1 &  iv9>=1 &	iv9<=2	/* Yes, in premise				*/
replace toilet_acc = 2		if  iv10==1 & iv9==3	 	/* Yes, but not in premises			*/
*replace toilet_acc = 3		if				/* Yes, unestated whether in or outside premises*/

* Sanitation Original
gen     sanitation_original = " 1 - Flush toilet to sewerage        "	if  iv8==1 & iv10==1 & iv11==1
replace sanitation_original = " 2 - Flush toilet to septic tank     "	if  iv8==1 & iv10==1 & iv11==2
replace sanitation_original = " 3 - Flush toilet to cesspool        "	if  iv8==1 & iv10==1 & iv11==3
replace sanitation_original = " 4 - Flush toilet to elsewhere       "	if  iv8==1 & iv10==1 & iv11==4
replace sanitation_original = " 5 - Pour flush toilet to sewerage   "	if  iv8==1 & iv10==2 & iv11==1
replace sanitation_original = " 6 - Pour flush toilet to septic tank"	if  iv8==1 & iv10==2 & iv11==2
replace sanitation_original = " 7 - Pour flush toilet to cesspool   "	if  iv8==1 & iv10==2 & iv11==3
replace sanitation_original = " 8 - Pour flush toilet to elsewhere  "	if  iv8==1 & iv10==2 & iv11==4
replace sanitation_original = " 9 - Pit latrine to elsewhere        "	if  iv8==1 & iv10==3 & iv11==4
replace sanitation_original = "10 - No facilities                   "	if  iv8==2

label define improved_sanitation 1 "Yes" 0 "No"
label val         imp_san_rec improved_sanitation
label val    imp_san_underest improved_sanitation
label val     imp_san_overest improved_sanitation
label val               sewer improved_sanitation
label val            open_def improved_sanitation

label var   sanitation_source "Source of sanitation"
label var               sewer "Access to toilet facility with sewer connection"
label var            open_def "Open defecation"
label var         imp_san_rec "Access to improved sanitation facilities - Recommended"
label var    imp_san_underest "Access to improved sanitation facilities - Underestimate"
label var     imp_san_overest "Access to improved sanitation facilities - Overestimate"
label var          toilet_acc "Access to flushed toilet" 
label var sanitation_original "Original sanitation variable"

*============================================================================================================*

* Electricidad en la vivienda:		elect
gen   elect = .
notes elect: the survey does not include information on this topic

* Teléfono:				telef
gen   telef = .
notes telef: the survey does not include information on this topic

* Types of Dwelling
/*	 1 = Detached house
	 2 = Multi-family house
	 3 = Separate apartment 
	 4 = Communal apartment 
	 5 = Room in a larger dwelling 
	 6 = Several buildings connected 
	 7 = Several separate buildings 
	 8 = Improvised housing unit 
	99 = Other									

    IV1: Tipo de vivienda:
		 1. Casa 
		 2. Departamento
		 3. Pieza de inquilinato
		 4. Pieza en hotel/pensión
		 5. Local no construido para habitación
		 6. Otro								*/
gen     dweltyp = .
replace dweltyp = 1		if  iv1==1
*replace dweltyp = 2		if  iv1==
replace dweltyp = 3		if  iv1==2
*replace dweltyp = 4		if  iv1==
replace dweltyp = 5		if  iv1==3 | iv1==4
*replace dweltyp = 6		if  iv1== 
*replace dweltyp = 7		if  iv1==
replace dweltyp = 8		if  iv1==5
replace dweltyp = 99		if  iv1==6

* Techo
/*	 1 = Adobe, zarzo, lodo
	 2 = Paja
	 3 = Madera
	 4 = Hierro/Láminas de metal
	 5 = Cemento
	 6 = Mosaicos/Ladrillos                    
	 7 = Asbesto
	99 = Other									
  
  IV4: La cubierta exterior del techo es de?
		1. Membrana/Cubierta Asfaltica
		2. Baldosa/Losa sin Cubierta
		3. Pizarra/Teja
		4. Chapa de Material sin Cubierta
		5. Chapa de Fibrocemento/Plástico
		6. Chapa de Cartón
		7. Caña/Tabla/Paja con Barro/Paja Sola
		9. N/S - Departamento en Propiedad Horizontal				*/
gen     techo = .
*replace techo = 1		if  iv4==
replace techo = 2		if  iv4==7
*replace techo = 3		if  iv4==
replace techo = 4		if  iv4==4 | iv4==5
replace techo = 5		if  iv4==1 | iv4==2 
replace techo = 6		if  iv4==3 
*replace techo = 7		if  iv4==
replace techo = 99		if  iv4==6 | iv4==9
notes   techo: other includes "chapa de carton" and "dont know/dont answer"

* Pared
/*	 1 = Adobe, zarzo, lodo                      
	 2 = Paja
	 3 = Madera
	 4 = Hierro/Láminas de metal
	 5 = Cemento                                      
	 6 = Ladrillos                                        
	 7 = Asbesto
	99 = Other									*/
gen   pared = .
notes pared: the survey does not include information on this topic

* Piso
/*	 1 = Tierra
	 3 = Madera
	 4 = Madera pulida/mosaicos
	 5 = Cemento                                      
	 6 = Ladrillos
	 7 = Asbesto
	99 = Other									
  IV3: Los pisos interiores son principalmente de:
		1. Mosaico/Baldosa/Madera/Cerámica/Alfombra
		2. Cemento/Ladrillo fijo
		3. Ladrillo Suelto/Tierra
		4. Otro									*/
gen     piso = .
replace piso = 1		if  iv3==3
*replace piso = 3		if  iv3==
replace piso = 4		if  iv3==1 
replace piso = 5		if  iv3==2 
*replace piso = 6		if  iv3==
*replace piso = 7		if  iv3==
replace piso = 99		if  iv3==4
notes   piso: other (= 99) includes "otro"
notes   piso: tierra (= 1) includes "tierra" but also "ladrillo suelto"
notes   piso: madera pulida/mosaicos (= 4) includes "madera/mosaico" but also "baldosa/ceramica/alfombra"
notes   piso: cemento (= 5) includes "cemento" but also "ladrillo fijo"

* Kitchen (yes/no)
* II4_1: tiene cuarto de cocina?
gen     kitchen = .
replace kitchen = 0		if  ii4_1==2
replace kitchen = 1		if  ii4_1==1

* Bath (yes/no)
* IV8: Tiene baño/letrina?
gen     bath = .
replace bath = 0		if  iv8==2
replace bath = 1		if  iv8==1

* Rooms
* HOGAR
*   II1: Cuantos ambientes/habitaciones tiene su hogar para uso exclusivo?
* II4_1: Tiene además cuarto de cocina?
* II4_2: Tiene además lavadero?
* II4_3: Tiene además garage?
* VIVIENDA
* IV2: Cuantos ambientes/habitaciones tiene la vivienda en total (sin contar baño/cocina/pasillo/lavadero/garage)?
* IV8: Tiene baño/letrina? - IV9: El baño/letrina está: 1 = dentro de la vivienda
gen     rooms = ii1		if  ii1<=99
replace rooms = rooms+1		if  ii4_1==1
replace rooms = rooms+1		if  ii4_2==1
replace rooms = rooms+1		if  ii4_3==1

* Acquisition of House 
/*	 1 = Comprada – totalmente pagada
	 2 = Comprada - pagando
	 3 = Heredada
	 4 = Alquilada/rentada
	 5 = Regalada/cedida
	 6 = Recibida por servicios de trabajo
	99 = Other									
   
   II7: Regimen de tenencia de la vivienda?
		 1. Propietario de la vivienda y el terreno
		 2. Propietario de la vivienda solamente
		 3. Inquilino/Arrendatario de la vivienda
		 4. Ocupante por pago de impuestos/expensas
		 5. Ocupante en relación de dependencia
		 6. Ocupante gratuito (con permiso)
		 7. Ocupante de hecho (sin permiso)
		 8. Está en sucesión
		 9. Otra situación							*/
gen     adq_house = .
replace adq_house = 1		if  ii7==1 | ii7==2
*replace adq_house = 2		if  ii7==
replace adq_house = 3		if  ii7==8
replace adq_house = 4		if  ii7==3
replace adq_house = 5		if  ii7==6
replace adq_house = 6		if  ii7==5
replace adq_house = 99		if  ii7==4 | ii7==7 | ii7==9
notes   adq_house: other includes "ocupante por pago de impuestos/expensas", "ocupante de hecho (sin permiso)" and "otra situación"
notes   adq_house: it is not possible to identify who are the ones still paying for the house 

* Acquisition of Residential Land 
gen   adq_land = .
notes adq_land: the survey does not include information on this topic

* Legal Title of Ownership
gen   dwelownlti = .
notes dwelownlti: the survey does not include information on this topic

* Legal Title of Ownership - Female
gen   fem_dwelownlti = .
notes fem_dwelownlti: the survey does not include information on this topic

* Type of ownership title
gen   dwelownti	= .
notes dwelownti: the survey does not include information on this topic

* Right to sell dwelling
gen   selldwel = .
notes selldwel: the survey does not include information on this topic	

* Right to transfer dwelling
gen   transdwel = .
notes transdwel: the survey does not include information on this topic	

* Ownership of land
gen   ownland = .
notes ownland: the survey does not include information on this topic

* Legal documentation for residential land
gen   doculand = .
notes doculand: the survey does not include information on this topic

* Legal documentation for residential land - Female
gen   fem_doculand = .
notes fem_doculand: the survey does not include information on this topic	

* Land ownership
gen   landownti = .
notes landownti: the survey does not include information on this topic

* Right to sell land
gen   selland = .
notes selland: the survey does not include information on this topic

* Right to transfer land
gen   transland = .
notes transland: the survey does not include information on this topic

* Types of living quarters
gen   typlivqrt = .
notes typlivqrt: the survey does not include information on this topic	

* Year the dwelling was built
gen   ybuilt = .
notes ybuilt: the survey does not include information on this topic

* Area (square meters)
/* V12: Cuántos metros cuadrados tiene la vivienda?
		1. Menos de 30 m2
		2. De 30 a 40 m2
		3. De 41 a 60 m2
		4. De 61 a 100 m2
		5. De 101 a 150 m2
		6. Más de 150 m2
		9. No sabe Estimar metros cuadrados totales de la vivienda		*/
gen     areaspace = .
notes   areaspace: the survey does not include information on this topic

* Main Types of Solid Waste Disposal
/*	 1 = Solid waste collected on a regular basis by authorized collectors
	 2 = Solid waste collected on an irregular basis by authorized collectors
	 3 = Solid waste collected by self-appointed collectors
	 4 = Occupants dispose of solid waste in a local dump supervised by authorities
	 5 = Occupants dispose of solid waste in a local dump not supervised by authorities
	 6 = Occupants burn solid waste
	 7 = Occupants bury solid waste
	 8 = Occupants dispose solid waste into river, sea, creek, pond
	 9 = Occupants compost solid waste
	10 = Other arrangement								*/
gen   waste = .
notes waste: the survey does not include information on this topic 

* Connection to Gas
/*	0 = No 
	1 = Yes, piped gas (LNG)
	2 = Yes, bottled gas (LPG)
	3 = Yes, but don't know or other						
	
   II8: Combustible utilizado para cocinar:
	1. Gas de red
	2. Gas de tubo/garrafa
	3. Kerosene/leña/carbón								*/
gen     gas = .
replace gas = 1			if  ii8==1
replace gas = 2			if  ii8==2
replace gas = 0			if  ii8==3

* Main Cooking Fuel
/*	1 = Firewood
	2 = Kerosene
	3 = Charcoal
	4 = Electricity
	5 = Gas
	9 = Other									
	
   II8: Combustible utilizado para cocinar:
	1. Gas de red
	2. Gas de tubo/garrafa
	3. Kerosene/leña/carbón								*/
gen     cooksource = .
replace cooksource = 1		if  ii8==2
replace cooksource = 5		if  ii8==1 | ii8==2
notes   cooksource: firewood (1) includes "firewood + kerosene + charcoal"

* Main Source of Lighting
/*	1 = Electricity 
	2 = Kerosene
	3 = Candles
	4 = Gas
	9 = Other									*/
gen   lightsource = .
notes lightsource: the survey does not include information on this topic (almost all household are connected to the electricity grid)

* Connection to Electricity
/*	1 = Yes, public/quasi public
	2 = Yes, private 
	3 = Yes, source unstated
	4 = No										*/
gen   elec_acc = .
notes elec_acc: the survey does not include information on this topic (almost all household are connected to the electricity grid)

* Electricity Availability
* Horas diarias
gen   elechr_acc = .
notes elechr_acc: the survey does not include information on this topic 

* Type of Lightning/Electricity
/*	1 = Electricity 
	2 = Gas 
	3 = Lamp
	4 = Others									*/
gen   electyp = .
notes electyp: the survey does not include information on this topic 


/*(*********************************************************************************************************************************************** 
			1.6: Bienes durables y servicios 
***********************************************************************************************************************************************)*/

* Heladera (con o sin freezer):				heladera
gen   heladera = .
notes heladera: the survey does not include information on this topic

* Lavarropas:						lavarropas
gen   lavarropas = .
notes lavarropas: the survey does not include information on this topic

* Aire acondicionado:					aire
gen   aire = .
notes aire: the survey does not include information on this topic

* Calefacción fija:					calefaccion_fija
gen   calefaccion_fija = .
notes calefaccion_fija: the survey does not include information on this topic

* Teléfono fijo:					telefono_fijo
gen   telefono_fijo = .
notes telefono_fijo: the survey does not include information on this topic

* Teléfono móvil (hogar):				celular
gen   celular = .
notes celular: the survey does not include information on this topic

* Teléfono movil (individual):				celular_ind
gen   celular_ind = .
notes celular_ind: the survey does not include information on this topic

* Televisor:						televisor
gen   televisor = .
notes televisor: there is not information the survey on this topic

* TV por cable o satelital:				tv_cable
gen   tv_cable = .
notes tv_cable: the survey does not include information on this topic

* VCR o DVD:						video 
gen   video = .
notes video: the survey does not include information on this topic

* Computadora:						computadora
gen   computadora = .
notes computadora: the survey does not include information on this topic

* Conexión a Internet en la casa:			internet_casa
gen   internet_casa = .
notes internet_casa: the survey does not include information on this topic

* Uso de Internet:					uso_internet
gen   uso_internet = .
notes uso_internet: the survey does not include information on this topic

* Auto 
gen   auto = .
notes auto: the survey does not include information on this topic

* Antiguedad del auto (en años):			ant_auto
gen   ant_auto = .
notes ant_auto: the survey does not include information on this topic

* Auto nuevo (5 o menos años):				auto_nuevo
gen   auto_nuevo = .
notes auto_nuevo: the survey does not include information on this topic

* Moto:							moto
gen   moto = .
notes moto: the survey does not include information on this topic

* Bicicleta:						bici
gen   bici = .
notes bici: the survey does not include information on this topic

* Sewing Machine
gen   sewmach = .
notes sewmach: the survey does not include information on this topic

* Stove or Cooker
gen   stove = .
notes stove: the survey does not include information on this topic

* Rice Cooker
gen   ricecook = .
notes ricecook: the survey does not include information on this topic

* Fan
gen   fan = .
notes fan: the survey does not include information on this topic

* Electronic Tablet
gen   etablet = .
notes etablet: the survey does not include information on this topic
notes etablet: there is a variable capturing any type of computer (PC, notebook, laptop, tablet)

* Electric Water Pump
gen   ewpump = .
notes ewpump: the survey does not include information on this topic

* Animal Cart/Oxcart
gen   oxcart = .
notes oxcart: the survey does not include information on this topic

* Boat
gen   boat = .
notes boat: the survey does not include information on this topic

* Canoes
gen   canoe = .
notes canoe: the survey does not include information on this topic


/*(************************************************************************************************************************************************* 
			1.7: Variables educativas  
*************************************************************************************************************************************************)*/

* Alfabeto:				alfabeto
/* CH09: Sabe leer y escribir? 
		1 = Sí
		2 = No
		3 = Menor de 2 años							*/
gen     alfabeto = 1		if  ch09==1
replace alfabeto = 0		if  ch09==2
replace alfabeto = .		if  edad<5
notes   alfabeto: variable defined for individuals 5-years-old and older

* Asiste a la educación formal:		asiste
/* CH10: Asiste o asistió a algún establecimiento educativo?(colegio, escuela, universidad) 
		1 = Si, asiste
                2 = No asiste, pero asistió
                3 = Nunca asistió							*/
gen     asiste = 0		if  ch10>=0 & ch10<=3
replace asiste = 1		if  ch10==1
replace asiste = .		if  edad<5
notes   asiste: variable defined for individuals 5-years-old and older

* Establecimiento educativo público:	edu_pub
/* CH11: Ese establecimiento es: 
		1 = público
		2 = privado
		9 = ns/nr 								*/
gen     edu_pub = 1		if  ch11==1
replace edu_pub = 0		if  ch11==2 
replace edu_pub = .		if  asiste!=1

* Educación en años:			aedu
/* CH12: ¿Cuál es el nivel más alto que cursa o cursó? 
		0 = (contestan la mayoría de los menores de 5)
		1 = Jardín/Preescolar  		 2 = Primario 
		3 = EGB 			 4 = Secundario 
		5 = Polimodal			 6 = Terciario 
		7 = Universitario		 8 = Posgrado Univ. 
		9 = Educación especial (discapacitado) 
   CH13: ¿Finalizó ese nivel? 
		1 = Si 
		2 = No 
		
   CH14: ¿Cuál fue el último año que aprobó? 
		0 = Ninguno			 1 = Primero 
		2 = Segundo			 3 = Tercero
		4 = Cuarto			 5 = Quinto 
		6 = Sexto			 7 = Séptimo 
		8 = Octavo			 9 = Noveno 
	       98 = Educación especial		99 = Ns./ Nr.				*/
destring ch14, replace

gen	aedu = .
* Sin primario 
replace aedu = 0		if  ch10==3 | ch12==0 | ch12==1
* Primario - EGB
replace aedu = ch14		if (ch12==2 | ch12==3) & ch13==2 
replace aedu = 3		if (ch12==2 | ch12==3) & ch13==2 & (ch14==99 | ch14==98)
replace aedu = 7		if  ch12==2 & ch13==1
replace aedu = 9		if  ch12==3 & ch13==1
* Secundario
replace ch14 = 5		if  ch14>=6 & ch14<=9 & ch12==4
replace aedu = ch14+7		if  ch12==4 & ch13==2 
replace aedu = 9		if  ch12==4 & ch13==2 & (ch14==99 | ch14==98)
replace aedu = 12		if  ch12==4 & ch13==1 
* Polimodal
replace ch14 = 3		if  ch14>=3 & ch14<=9 & ch12==5
replace aedu = ch14+9		if  ch12==5 & ch13==2
replace aedu = 11		if  ch12==5 & ch13==2 & (ch14==99 | ch14==98)
replace aedu = 12		if  ch12==5 & ch13==1 
* Terciario 
replace aedu = ch14+12		if  ch12==6 & ch13==2 
replace aedu = 14		if  ch12==6 & ch13==2 & (ch14==99 | ch14==98)
replace aedu = 15		if  ch12==6 & ch13==2 &  ch14>=4  & ch14<=9
replace aedu = 15		if  ch12==6 & ch13==1 
* Universitario 
replace aedu = ch14+12		if  ch12==7 & ch13==2
replace aedu = 14		if  ch12==7 & ch13==2 & (ch14==99 | ch14==98)
replace aedu = 17		if  ch12==7 & ch13==2 &  ch14>=5  & ch14<=9
replace aedu = 17		if  ch12==7 & ch13==1 
* Posgrado universitario
replace aedu = ch14+17		if  ch12==8 & ch13==2 
replace aedu = 18		if  ch12==8 & ch13==2 & (ch14==99 | ch14==98)
replace aedu = 20		if  ch12==8 & ch13==2 &  ch14>=3  & ch14<=9
replace aedu = 19		if  ch12==8 & ch13==1 

* Nivel educativo:			nivel
/*   0 = nunca asistió        1 = primario incompleto
     2 = primario completo    3 = secundario incompleto
     4 = secundario completo  5 = superior incompleto 
     6 = superior completo											
     
NIVEL-ED: Nivel Educativo
		1 = Primaria Incompleta (incluye educación especial)
		2 = Primaria Completa
		3 = Secundaria Incompleta
		4 = Secundaria Completa
		5 = Superior Universitaria Incompleta
		6 = Superior Universitaria Completa 
		7 = Sin instrucción							*/
gen	nivel = nivel_ed
replace nivel = 0		if  nivel_ed==7


/*(*********************************************************************************************************************************************** 
			1.8: Variables Salud  
***********************************************************************************************************************************************)*/

* Seguro de salud			seguro_salud
/* CH08: Tiene algún tipo de cobertura médica por la que paga o le descuentan?
	1 = Obra social (incluye PAMI)
        2 = Mutual/Prepaga/Servicio de Emergencia
        3 = Plan/Seguro Público
        4 = No paga ni le descuentan
        9 = NS/NR
       12 = Obra Social+Mutual/Prepaga/Servicio de Emergencia
       13 = Obra Social+Plan/Seguro Público
       23 = Mutual/Prepaga/Servicios de Emergencia+Plan/Seguro Público
      123 = Obra Social+Mutual/Prepaga/Servicio de Emergencia+Plan/Seguro Público	*/
gen     seguro_salud = 1	if  ch08>=1 & ch08<=123
replace seguro_salud = 0	if  ch08==4 
replace seguro_salud = .	if  ch08==.

* Tipo de seguro de salud:		tipo_seguro
*	0 = publico o vinculado al trabajo (obra social)
*	1 = privado
gen     tipo_seguro = 0		if  ch08>=1 & ch08<=123
replace tipo_seguro = 1		if  ch08==2 | ch08==12 | ch08==23 | ch08==123
replace tipo_seguro = .		if  ch08==4 | ch08==.

* Estuvo enfermo en últimas 4 semanas?:	enfermo 
gen   enfermo = .
notes enfermo: the survey does not include information on this topic

* Visitó médico en últimas 4 semanas?:	visita 
gen   visita = .
notes visita: the survey does not include information on this topic


/*(************************************************************************************************************************************************* 
			1.9: Variables laborales 
*************************************************************************************************************************************************)*/
* ARG 2012: Personas de 10 y más años de edad

* Ocupado:				ocupado
/* ESTADO: Condición de Actividad (para las personas de 10 años y más)
		0=missing
		1= Ocupado
                2= Desocupado
		3= Inactivo 
		4= no corresponde (menos de 9 años)					*/
gen     ocupado = 1		if  estado==1 
replace ocupado = 0		if  estado==2 | estado==3
replace ocupado = 0		if  edad<10
notes   ocupado: period of reference: last week

* Desocupado:				desocupa
gen     desocupa = 0		if  estado==1 | estado==3
replace desocupa = 1		if  estado==2
replace desocupa = 0		if  edad<10
notes   desocupa: period of reference: last week

* Población económicamente activa:	pea
gen	pea = 0			if  ocupado==0 & desocupa==0
replace pea = 1			if  ocupado==1 | desocupa==1
replace pea = 0			if  edad<10
notes   pea: period of reference: last week

/* Razon por la que no pertenece a la fuerza de trabajo
	 1 = Student					 2 = Housekeeping
	 3 = Retired					 4 = Disabled 
	 5 = Waiting for the work season		 6 = Do not have the economic means 
	 7 = Do not have the legal means / Illegal	 8 = Too old/young to work
	 9 = Do not have the need to work		10 = Forbidden by a family member
	11 = Illness					12 = Exhausted to be looking for a job
	13 = Believe none will give him/her a job       14 = Wages are too low
	99 = Other									
  
  CAT_INAC: Categoría de Inactividad
		1. Jubilado/Pensionado
		2. Rentista
		3. Estudiante
		4. Ama de Casa
		5. Menor de 6 años
		6. Discapacitado
		7. Otros								
  PP02E: Durante los últimos 30 días no buscó trabajo porque?
		1. está suspendido
		2. ya tiene trabajo asegurado
		3. se cansó de buscar trabajo
		4. hay poco trabajo en esta época del año
		5. por otras razones							*/
gen     nfl = .
replace nfl = 1		if  cat_inac==3
replace nfl = 2		if  cat_inac==4
replace nfl = 3		if  cat_inac==1
replace nfl = 4		if  cat_inac==6
replace nfl = 5		if  pp02e==4
*replace nfl = 6	if  cat_inac==
*replace nfl = 7	if  cat_inac==
replace nfl = 8		if  cat_inac==5
replace nfl = 9		if  cat_inac==2
*replace nfl = 10	if  cat_inac==
*replace nfl = 11	if  cat_inac==
replace nfl = 12	if  pp02e==3
*replace nfl = 13	if  cat_inac==
*replace nfl = 14	if  cat_inac==
replace nfl = 99	if  pp02e==1 | pp02e==2 | pp02e==5
notes   nfl: nfl = 

* Numero Total de Trabajos
/* PP03C: La semana pasada tenía:
		1 = un solo empleo/actividad/ocupación
		2 = mas de un empleo/actividad/ocupación
   PP03D: Cantidad de ocupaciones							*/
gen     njobs = .
replace njobs = 1	if  ocupado==1 & pp03c==1
replace njobs = pp03d	if  ocupado==1 & pp03c==2

* Edad mínima de preguntas laborales
gen   edad_min = 10
notes edad_min: people aged 10 and older answer the labor module

* Duración del desempleo (en meses):	durades
/* PP10A: Cuánto hace que está buscando trabajo?
		1 = menos de 1 mes?
                2 = de 1 a 3 meses?
                3 = más de 3 a 6 meses?
                4 = más de 6 a 12 meses?
                5 = más de 1 año?							*/
gen	durades = 1		if  pp10a==1
replace durades = 2		if  pp10a==2
replace durades = 4		if  pp10a==3
replace durades = 9		if  pp10a==4
replace durades = 18		if  pp10a==5
replace durades = .		if  desocupa!=1
notes   durades: original variable is categorical (by intervals), durades is defined using the center of the interval (example: 9 if interval is 6 to 12 months) 

* Horas en el trabajo principal:	hstrp 
* PP3E_TOT: Total de horas que trabajó en la semana en la ocupación principal
replace pp3e_tot = .		if  pp3e_tot==999

egen    hstrp = rsum (pp3e_tot), missing
replace hstrp = .		if  ocupado!=1 | hstrp>150

* Horas en todos los empleos:		hstrt
* PP3F_TOT: Total de horas que trabajó en la semana en otras ocupaciones  
replace pp3f_tot = .		if  pp3f_tot==999

egen    hstrs = rsum (pp3f_tot), missing
replace hstrs = .		if  ocupado!=1 | hstrs>150

* Horas trabajadas totales en todos los empleos
egen    hstrt = rsum(hstrp hstrs), missing
replace hstrt = .		if  ocupado!=1 | hstrt>150

* Deseo otro trabajo o más horas:	deseo_emp
* PP03I:  En los últimos treinta días, ¿buscó trabajar más horas? 
* PP03J:  Aparte de este/os trabajo/s, ¿estuvo buscando algún empleo/ocupación/actividad? 
gen     deseo_emp = 0		if  pp03i==2 & pp03j==2
replace deseo_emp = 1		if  pp03i==1 | pp03j==1
replace deseo_emp = .		if  ocupado!=1

* Antiguedad en el trabajo (años):	antigue
/* Patrones
	PP05H: ¿durante cuánto tiempo ha estado en ese empleo en forma continua?  
   Asalariados
	PP07A: ¿durante cuánto tiempo ha estado en ese empleo en forma continua? 		
		1 = menos de 1 mes
		2 = de 1 a 3 meses
		3 = más de 3 a 6 meses
		4 = más de 6 meses a 1 año
		5 = más de 1 a 5 años
		6 = más de 5 años
		9 = ns/nr
   Cuentapropistas
	¿cuánto tiempo ha estado en ese empleo en forma continua?
	PP05B2_MES: Cantidad de meses
	PP05B2_ANO: Cantidad de años
	PP05B2_DIA: Cantidad de días
   Empleados Domesticos
	PP04B3_MES: Cantidad de meses
	PP04B3_ANO: Cantidad de años
	PP04B3_DIA: Cantidad de días 							*/
* Antiguedad (definida de forma continua)
gen   antigue = .
notes antigue: there is not information on the survey on this topic (it could be defined by categories)

* Relacion laboral:			relab 
/*		1 = empleador (patron)
		2 = empleado asalariado
		3 = independiente (cuentapropista)
		4 = sin salario
		5 = desocupado

   CAT_OCUP: Categoría Ocupacional en el empleo principal
		1 = Patrón
		2 = Cuenta propia
		3 = Obrero o empleado,
   		4 = Trabajador familiar sin remuneración
		9 = Ns/Nr								*/
gen     relab = 1		if  cat_ocup==1
replace relab = 2		if  cat_ocup==3
replace relab = 3		if  cat_ocup==2
replace relab = 4		if  cat_ocup==4
replace relab = 5		if  desocupa==1

gen   relab_s = .
notes relab_s: the survey does not include information on this topic

gen   relab_o = .
notes relab_o: the survey does not include information on this topic

* Sector of Activity
/*	1 = Public Sector, Central Government, Army
	2 = Private, NGO
	3 = State Owned 
	4 = Public or State-owned, but cannot distinguish				

PP04A: El negocio/empresa/institución/actividad en la que trabaja es...(se refiere al que trabaja más  horas semanales)
        1 = estatal? 
	2 = privada? 
	3 = de otro tipo? (especificar)							*/
* Main Job
gen     occusec = .
replace occusec = 2	if  pp04a==2
replace occusec = 4	if  pp04a==1
replace occusec = .	if  ocupado!=1
notes   occusec: pp04a==3 is "another type", it doesn´t specify if public or private

* Secondary Job
gen     occusec_s = .
notes   occusec_s: the survey does not include information on this topic

* Other Job
gen     occusec_o = .
notes   occusec_o: the survey does not include information on this topic

* Tipo de empresa:			empresa 
*	1 = Grande			(+ de 5 empleados)
*	2 = Chica			(5 o menos empleados)
*	3 = Estatal o sector publico
/* PP04A: El negocio/empresa/institución/actividad en la que trabaja es...(se refiere al que trabaja más  horas semanales)
               1 = estatal? 
	       2 = privada? 
	       3 = de otro tipo? (especificar)

  PP04B1: Si presta servicio doméstico en hogares particulares, marque
	       1 = casa de familia

   PP04C: ¿Cuántas personas, incluido...trabajan allí en total?
		 1 = 1 persona			 2 = 2 personas
		 3 = 3 personas			 4 = 4 personas
		 5 = 5 personas			 6 = de 6 a 10 personas
		 7 = de 11 a 25 personas	 8 = de 26 a 40 personas
		 9 = de 41 a 100 personas       10 = de 101 a 200 personas
		11 = de 201 a 500 personas      12 = más de 500 personas

 PP04C99: NS/NR en la pregunta anterior (pp04c=99)
		 1 = hasta 5
		 2 = de 6 a 40
		 3 = más de 40
		 9 = ns/nr								*/
gen	empresa = 1		if (pp04c>=6 & pp04c<=12) | pp04c99==2 | pp04c99==3
replace empresa = 2		if (pp04c>=1 & pp04c<=5)  | pp04c99==1
replace empresa = 2		if  pp04b1==1
replace empresa = 3		if  pp04a==1 
notes   empresa: 1,739 observations ocupado=1 without information on empresa
 
** Firm size (lower bracket)
* Main Job
gen     firmsize_l = .
replace firmsize_l = 1		if  pp04c==1 | pp04c99==1 | pp04b1==1
replace firmsize_l = 2		if  pp04c==2
replace firmsize_l = 3		if  pp04c==3
replace firmsize_l = 4		if  pp04c==4
replace firmsize_l = 5		if  pp04c==5
replace firmsize_l = 6		if  pp04c==6 | pp04c99==2
replace firmsize_l = 11		if  pp04c==7
replace firmsize_l = 26		if  pp04c==8
replace firmsize_l = 41		if  pp04c==9 | pp04c99==3
replace firmsize_l = 101	if  pp04c==10
replace firmsize_l = 201	if  pp04c==11
replace firmsize_l = 501	if  pp04c==12

* Secondary Job
gen     firmsize_l_s = .
notes   firmsize_l_s: the survey does not include information on this topic

* Other Job
gen     firmsize_l_o = .
notes   firmsize_l_o: the survey does not include information on this topic
 
** Firm size (upper bracket)
* Main Job
gen     firmsize_u = .
replace firmsize_u = 1		if  pp04c==1 | pp04b1==1
replace firmsize_u = 2		if  pp04c==2
replace firmsize_u = 3		if  pp04c==3
replace firmsize_u = 4		if  pp04c==4
replace firmsize_u = 5		if  pp04c==5 | pp04c99==1 
replace firmsize_u = 10		if  pp04c==6 
replace firmsize_u = 25		if  pp04c==7
replace firmsize_u = 40		if  pp04c==8 | pp04c99==2
replace firmsize_u = 100	if  pp04c==9 
replace firmsize_u = 200	if  pp04c==10
replace firmsize_u = 500	if  pp04c==11
replace firmsize_u = .		if  pp04c==12

* Secondary Job
gen     firmsize_u_s = .
notes   firmsize_u_s: the survey does not include information on this topic

* Other Job
gen     firmsize_u_o = .
notes   firmsize_u_o: the survey does not include information on this topic

* Sector de actividad:			sector1d
/* PP04B_CAES: CODIGO DE ACTIVIDAD PARA OCUPADOS CAES 1.0
   A partir de T1/2011, INDEC pone en vigencia la clasificación de Actividades Económicas para encuestas del MERCOSUR 1.0 (CAES 1.0) 
   basada en la CIIU Revisión 4 de las Naciones Unidas					*/
destring pp04b_caes, gen(rama) force

gen	sector1d = 1		if (rama>=1  & rama<=2)  | (rama>=101  &  rama<=200) | rama==8102
replace sector1d = 2		if  rama==3  | rama==300
replace sector1d = 3		if (rama>=5  & rama<=9)  | (rama>=500  &  rama<=900)
replace sector1d = 4		if (rama>=10 & rama<=33) |  rama==58   | (rama>=1001 & rama<=3300) | rama==5800 | rama==9502
replace sector1d = 5		if (rama>=35 & rama<=36) | (rama>=3501 &  rama<=3600)
replace sector1d = 6		if  rama==40 | rama==4000
replace sector1d = 7		if (rama>=45 & rama<=48) |  rama==95   | (rama>=4501 & rama<=4811) | rama==9503
replace sector1d = 8		if (rama>=55 & rama<=56) | (rama>=5500 &  rama<=5602)
replace sector1d = 9		if (rama>=49 & rama<=53) |  rama==61   |  rama==79   | (rama>=4901 & rama<=5300) | rama==6100 | rama==7900
replace sector1d = 10		if (rama>=64 & rama<=66) | (rama>=6400 &  rama<=6600)
replace sector1d = 11		if  rama==62 | (rama>=68 &  rama<=74)  | (rama>=77 & rama<=78) | (rama>=80 & rama<=82) | rama==6200 |  ///
                                   (rama>=6800 & rama<=7400) | (rama>=7701 & rama<=7800) | (rama>=8000 & rama<=8101) | rama==8200 | rama==9501
replace sector1d = 12		if (rama>=83 & rama<=84) | (rama>=8300 & rama<=8409)
replace sector1d = 13		if  rama==85 | (rama>=8501 & rama<=8509)
replace sector1d = 14		if  rama==75 | (rama>=86 & rama<=88) | rama==7500 | (rama>=8600 & rama<=8800)
replace sector1d = 15		if (rama>=37 & rama<=39) | (rama>=59 & rama<=60) | rama==63 | (rama>=90 & rama<=94) | rama==96 | ///
                                   (rama>=3700 & rama<=3900) | (rama>=5900 & rama<=6000) | rama==6300 | (rama>=9000 & rama<=9409) | (rama>=9601 & rama<=9609)
replace sector1d = 16		if (rama>=97 & rama<=98) | (rama>=9700 & rama<=9800)
replace sector1d = 17		if  rama==99 | rama==9900 
replace sector1d = .		if  ocupado!=1
notes   sector1d: there are 151 missings observations with ocupado==1 in the variable sector1d

* Secondary Job
gen   sector1d_s = .
notes sector1d_s: the survey does not include information on this topic

* Other Job
gen   sector1d_o = .
notes sector1d_o: the survey does not include information on this topic

* Country-Specific Industry Codes
* Main Job
gen   sector_orig = pp04b_caes

* Secondary Job
gen   sector_orig_s = .
notes sector_orig_s: the survey does not include information on this topic

* Other Job
gen   sector_orig_o = .
notes sector_orig_o: the survey does not include information on this topic

* Sector de actividad (clasificacion propia):	sector
/* Idealmente formar estos 9 sectores: 
       1 = Agricola, actividades primarias
       2 = Industrias de baja tecnologia (industria alimenticia, bebidas y tabaco, textiles y confecciones) 
       3 = Resto de industria manufacturera
       4 = Construccion
       5 = Comercio minorista y mayorista, restaurants, hoteles, reparaciones
       6 = Electricidad, gas, agua, transporte, comunicaciones
       7 = Bancos, finanzas, seguros, servicios profesionales
       8 = Administracion publica y defensa
       9 = Educacion, salud, servicios personales 
      10 = Servicio domestico								*/
gen     sector = 1		if  sector1d>0 & sector1d<4
replace sector = 2		if (rama>9  & rama<17) | (rama>1000 & rama<1601) | (rama>30   & rama<33)   | (rama>3099  & rama<3201)
replace sector = 3		if (rama>16 & rama<31) |  rama==33  | rama==58   | (rama>1701 & rama<3010) |  rama==3300 | rama==5800 | rama==9502
replace sector = 4		if  sector1d==6
replace sector = 5		if  sector1d==7  |  sector1d==8
replace sector = 6		if  sector1d==5  |  sector1d==9
replace sector = 7		if  sector1d==10 | sector1d==11
replace sector = 8		if  sector1d==12 | sector1d==17 
replace sector = 9		if  sector1d>=13 & sector1d<=15
replace sector = 10		if  sector1d==16 
replace sector = .		if  ocupado!=1
notes   sector: there are 151 missings observations with ocupado==1 in the variable sector

* Ocupación realiza:			tarea
* PP04D_COD: Código de Ocupación (Ver documento Clasificador de Ocupaciones - CNO'91)
gen   tarea = pp04d_cod

* Occupational Classification
/*	 1 = Managers 
	 2 = Professionals 
	 3 = Technicians and associate professionals 
	 4 = Clerical support workers 
	 5 = Service and sales workers 
	 6 = Skilled agricultural, forestry and fishery workers
	 7 = Craft and related trades workers
	 8 = Plant and machine operators, and assemblers 
	 9 = Elementary occupations 
	10 = Armed forces occupations 
	99 = Other/unspecified								*/

** CLASIFICADOR NACIONAL DE OCUPACIONES 2001 - ARGENTINA
** https://www.indec.gob.ar/ftp/cuadros/menusuperior/eph/EPHcontinua_CNO2001_reducido_09.pdf
destring pp04d_cod, gen(ofi)  
gen ramita = round(rama/100)

gen     oficio1 = .
replace oficio1 =  1    if  ofi==49311 | ofi==49312 | ofi==49322 | ofi==49331 | ofi==49332 
replace oficio1 =  2	if  ofi==49313 | ofi==49323 | ofi==49333 
replace oficio1 =  3	if  ofi==49314
replace oficio1 = 11	if  ofi==1 | ofi==1001 | ofi==3001 | ofi==4001 
replace oficio1 = 12	if  ofi==7001
replace oficio1 = 13	if  ofi==5001 | ofi==6001
replace oficio1 = 14    if  ofi==5002
replace oficio1 = 21    if  ofi==35111 | ofi==35201 | ofi==35311 | ofi==36111 | ofi==36311 | ofi==44111 | ofi==44131 | ofi==44201 | ofi==44311 | ofi==44331 |  ofi==50131 |  ofi==50331 | ofi==60111 | ofi==60131 | ofi==60201 | ofi==60311 | ofi==60331 | ofi==61131 | ofi==62111 | ofi==62201 |  ofi==62311 |  ofi==63111 |  ofi==63311 | ofi==64311 
replace oficio1 = 22	if  ofi==40111 | ofi==40131 | ofi==40201 | ofi==40311 | ofi==40321 | ofi==40331 | ofi==61111 | ofi==61201 | ofi==61311 
replace oficio1 = 23	if  ofi==41111 | ofi==41112 | ofi==41131 | ofi==41132 | ofi==41201 | ofi==41202 | ofi==41311 | ofi==41312 | ofi==41331 | ofi==41332 
replace oficio1 = 24	if  ofi==10111 | ofi==10201 | ofi==10311 | ofi==10331 | ofi==20111 | ofi==20131 | ofi==20201 | ofi==20311 | ofi==20331 | ofi==30111 | ofi==30131 | ofi==30201 | ofi==30311 | ofi==30331 | ofi==31111 | ofi==31131 | ofi==31311 | ofi==31331 | ofi==32111 | ofi==32131 | ofi==32201 | ofi==32311 | ofi==32331 | ofi==54111 | ofi==54131 | ofi==54311 | ofi==54331 
replace oficio1 = 25	if  ofi==35131 | ofi==45131 | ofi==45331 | ofi==47131 | ofi==47331 | ofi==81131 | ofi==81201 | ofi==81331 | ofi==92131 | ofi==92331 |  ofi==2001 | ofi==11111 | ofi==11131 | ofi==11201 | ofi==11311 | ofi==11331 | ofi==45111 | ofi==45112 | ofi==45201 | ofi==45202 | ofi==45311 | ofi==45312 | ofi==46111 | ofi==46201 | ofi==46311 | ofi==46331 | ofi==50111 | ofi==50201 | ofi==50311 
replace oficio1 = 31	if  ofi==34121 | ofi==34122 | ofi==34131 | ofi==34201 | ofi==34202 | ofi==34311 | ofi==34312 | ofi==34321 | ofi==34322 | ofi==34331 | ofi==34332 | ofi==36112 | ofi==36202 | ofi==36312 | ofi==36332 | ofi==44132 | ofi==44323 | ofi==44332 | ofi==48331 | ofi==60112 | ofi==60132 | ofi==60202 | ofi==60312 | ofi==60322 | ofi==61112 | ofi==61312 | ofi==62112 | ofi==62202 | ofi==62312 | ofi==62322 | ofi==62332 | ofi==63112 | ofi==63202 | ofi==63312 | ofi==64202 | ofi==64312 | ofi==65112 | ofi==70112 | ofi==70122 | ofi==70132 | ofi==70202 | ofi==70312 | ofi==70322 | ofi==70332 | ofi==71202 | ofi==71203 | ofi==71312 | ofi==71313 | ofi==71322 | ofi==71323 | ofi==71332 | ofi==71333 | ofi==72112 | ofi==72132 | ofi==72202 | ofi==72312 | ofi==72322 | ofi==72332 | ofi==80202 | ofi==80322 | ofi==80332 | ofi==82132 | ofi==82202 | ofi==82332 | ofi==90112 | ofi==90202 | ofi==90312 | ofi==90332 | ofi==91202 | ofi==91312 | ofi==91313 | ofi==92202 
replace oficio1 = 32    if  ofi==40112 | ofi==40112 | ofi==40132 | ofi==40202 | ofi==40312 | ofi==40322 | ofi==40323 | ofi==40332 | ofi==40333 
replace oficio1 = 33	if  ofi==10112 | ofi==10132 | ofi==10202 | ofi==10312 | ofi==10322 | ofi==20112 | ofi==20132 | ofi==20202 | ofi==20312 | ofi==30112 | ofi==30132 | ofi==30202 | ofi==30312 | ofi==30332 | ofi==31112 | ofi==31132 | ofi==31202 | ofi==31312  | ofi==31332 | ofi==32112 | ofi==32202 | ofi==32312 | ofi==32332 | ofi==47202 | ofi==47312 | ofi==48311 | ofi==48312 | ofi==48332
replace oficio1 = 34	if  ofi==10332 | ofi==11112 | ofi==11202 | ofi==11312 | ofi==11332 | ofi==46112 | ofi==46113 | ofi==46202 |  ofi==46203 |  ofi==46312 |  ofi==46313 |  ofi==46332 |  ofi==46333 | ofi==50112 | ofi==50113 | ofi==50202 | ofi==50312 | ofi==50313 | ofi==51112 | ofi==51202 | ofi==51203 | ofi==51312 | ofi==52112 | ofi==52113 | ofi==52122 | ofi==52123 | ofi==52133 | ofi==52202 | ofi==52312 | ofi==52313 | ofi==52322 | ofi==52323 | ofi==52333 | ofi==53111 | ofi==53112 | ofi==53202 | ofi==53312 | ofi==58112 | ofi==58132 | ofi==58202 | ofi==58312 
replace oficio1 = 35    if  ofi==35112 | ofi==35132 | ofi==35202 | ofi==35312 | ofi==35322 | ofi==35332 | ofi==45132 | ofi==45313 | ofi==45322 | ofi==45323 | ofi==45332 | ofi==45333 | ofi==47322 | ofi==47332 | ofi==50122 | ofi==50132 | ofi==50322 | ofi==50332 | ofi==58332 | ofi==81132 | ofi==81202 | ofi==81332 | ofi==92112 | ofi==92132 | ofi==92312 | ofi==92332
replace oficio1 = 41	if  ofi==10113 | ofi==10123 | ofi==10133 | ofi==10203 | ofi==10313 | ofi==10323 | ofi==10333 | ofi==11313 | ofi==11333 | ofi==20314 | ofi==81333 | ofi==10339 
replace oficio1 = 42	if  ofi==10314 | ofi==20332 | ofi==20333 | ofi==42113 | ofi==42313 | ofi==43313 | ofi==52203 | ofi==20339 
replace oficio1 = 43	if  ofi==20113 | ofi==20203 | ofi==20313 | ofi==34203 | ofi==36113 | ofi==36203 | ofi==36313 | ofi==36333 
replace oficio1 = 44	if  ofi==35113 | ofi==35133 | ofi==35203 | ofi==35313 | ofi==35314 | ofi==35333 | ofi==42333
replace oficio1 = 51	if  ofi==34313 | ofi==51313 | ofi==53113 | ofi==53123 | ofi==53203 | ofi==53313 | ofi==53314 | ofi==53323 | ofi==53333 | ofi==54112 | ofi==54113 | ofi==54132 | ofi==54133 | ofi==54202 | ofi==54312 | ofi==54313 | ofi==54332 | ofi==54333 | ofi==55203 | ofi==55313 | ofi==56202 | ofi==56203 | ofi==57112 | ofi==57113 | ofi==57202 | ofi==57203 | ofi==57312 | ofi==57313 | ofi==57314 | ofi==58113 | ofi==58123 | ofi==58203 | ofi==58313 | ofi==58323 | ofi==58333
replace oficio1 = 52	if  ofi==30113 | ofi==30123 | ofi==30313 | ofi==30314 | ofi==30323 | ofi==30133 | ofi==30203 | ofi==30333 | ofi==31113 | ofi==31123 | ofi==31313 | ofi==31314 | ofi==31323 | ofi==31133 | ofi==31333 | ofi==32113 | ofi==32123 | ofi==32203 | ofi==32313 | ofi==32333 | ofi==33203 | ofi==30119 | ofi==30139 | ofi==30319 | ofi==30339 | ofi==31319
replace oficio1 = 53	if  ofi==40113 | ofi==40203 | ofi==40313 | ofi==40314 | ofi==41203 | ofi==41313 | ofi==41323 | ofi==41333
replace oficio1 = 54	if  ofi==44112 | ofi==44202 | ofi==44312 | ofi==47112 | ofi==47113 | ofi==47203 | ofi==47313 | ofi==47323 | ofi==47333 | ofi==48313 | ofi==48322 | ofi==48323 | ofi==48333 
replace oficio1 = 61	if  ofi==60113 | ofi==60203 | ofi==60313 | ofi==61113 | ofi==61123 | ofi==61133 | ofi==61202 | ofi==61203 | ofi==61313 | ofi==61323 | ofi==63113 | ofi==63123 | ofi==63203 | ofi==63313 
replace oficio1 = 62	if  ofi==62113 | ofi==62203 | ofi==62313 | ofi==64113 | ofi==64203 | ofi==64313 | ofi==65113 | ofi==65313 | ofi==65314 
replace oficio1 = 71	if  ofi==72113 | ofi==72203 | ofi==72313 
replace oficio1 = 72	if  ofi==82133 | ofi==82203 | ofi==82313 | ofi==82333 | ofi==90113 | ofi==90203 | ofi==90313 | ofi==90323 | ofi==90333 | ofi==92113 | ofi==92203 | ofi==92313 | ofi==92323 | ofi==92333 
replace oficio1 = 73	if  ofi==80112 
replace oficio1 = 74	if  ofi==72133 | ofi==72333 | ofi==82112 | ofi==82312 
replace oficio1 = 75	if  ofi==44113 | ofi==44122 | ofi==44313 | ofi==44322 | ofi==80113 | ofi==82123 | ofi==82323 
replace oficio1 = 81	if  ofi==70111 | ofi==70131 | ofi==70201 | ofi==70311 | ofi==70331 | ofi==71201 | ofi==71311 | ofi==71331 | ofi==72111 | ofi==72131 | ofi==72201 | ofi==72311 | ofi==72331 | ofi==80111 | ofi==80131 | ofi==80132 | ofi==80201 | ofi==80311 | ofi==80331 | ofi==82111 | ofi==90111 | ofi==90201 | ofi==90311 | ofi==90331 | ofi==91111 | ofi==91131 | ofi==91201 | ofi==91311 | ofi==91331 | ofi==92111 | ofi==92201 | ofi==92311 | ofi==70203 | ofi==70313 | ofi==70323 | ofi==70333 | ofi==80123 | ofi==80133 | ofi==80323 | ofi==80333 | ofi==56123 | ofi==56323 
replace oficio1 = 83	if  ofi==32323 | ofi==34123 | ofi==34323 | ofi==34333 | ofi==35123 | ofi==35323 | ofi==36323 | ofi==60122 | ofi==60123 | ofi==60323 | ofi==62323 | ofi==63323 | ofi==63333 | ofi==64323 | ofi==72122 | ofi==72123 | ofi==72323 
replace oficio1 = 91	if  ofi==55314 | ofi==56113 | ofi==56114 | ofi==56313 | ofi==56314 | ofi==56324 
replace oficio1 = 92	if  ofi==60114 | ofi==60314 | ofi==60324 | ofi==61314 | ofi==62314 | ofi==63314 | ofi==64314 
replace oficio1 = 93	if  ofi==32314 | ofi==34113 | ofi==34314 | ofi==34324 | ofi==36114 | ofi==36314 | ofi==70314 | ofi==70324 | ofi==71314 | ofi==71324 | ofi==72114 | ofi==72314 | ofi==80314 | ofi==80324 | ofi==82314 | ofi==90314 | ofi==92314 
replace oficio1 = 95	if  ofi==33114 | ofi==33123 | ofi==33113 | ofi==33314 
replace oficio1 = 96	if  ofi==44314 | ofi==47314 | ofi==51113 | ofi==51314 | ofi==52314 | ofi==54314 | ofi==58314 
replace oficio1 = 99	if  ofi==99997 | ofi==99999

replace oficio1 = 21    if (ofi==42111 | ofi==42131 | ofi==42201 | ofi==42311 | ofi==42331 | ofi==43111 | ofi==43131 | ofi==43201 | ofi==43311 | ofi==43331) & (ramita==71 | ramita==72 | ramita==74)
replace oficio1 = 22    if (ofi==42111 | ofi==42131 | ofi==42201 | ofi==42311 | ofi==42331 | ofi==43111 | ofi==43131 | ofi==43201 | ofi==43311 | ofi==43331) &  ramita==86 
replace oficio1 = 24    if (ofi==42111 | ofi==42131 | ofi==42201 | ofi==42311 | ofi==42331 | ofi==43111 | ofi==43131 | ofi==43201 | ofi==43311 | ofi==43331) & (ramita==70 | ramita==78)
replace oficio1 = 31    if (ofi==42112 | ofi==42202 | ofi==42312 | ofi==42332 | ofi==43112 | ofi==43132 | ofi==43312 | ofi==43332 | ofi==80312) & (ramita==71 | ramita==72 | ramita==74)
replace oficio1 = 32    if (ofi==42112 | ofi==42202 | ofi==42312 | ofi==42332 | ofi==43112 | ofi==43132 | ofi==43312 | ofi==43332 | ofi==80312) &  ramita==86
replace oficio1 = 33    if (ofi==42112 | ofi==42202 | ofi==42312 | ofi==42332 | ofi==43112 | ofi==43132 | ofi==43312 | ofi==43332 | ofi==80312) &  ramita==84
replace oficio1 = 72    if (ofi==80203 | ofi==80313 | ofi==82113) & (ramita==25 | ramita==29 | ramita==30)
replace oficio1 = 73    if (ofi==80203 | ofi==80313 | ofi==82113) & (ramita==18 | ramita==23)
replace oficio1 = 74    if (ofi==80203 | ofi==80313 | ofi==82113) &  ramita==26
replace oficio1 = 75    if (ofi==80203 | ofi==80313 | ofi==82113) & (ramita==10 | ramita==11 | ramita==12 | ramita==13 | ramita==14 | ramita==15 | ramita==16 | ramita==31)
replace oficio1 = 81    if (ofi==80203 | ofi==80313 | ofi==82113) & (ramita==17 | ramita==19 | ramita==20 | ramita==21 | ramita==22 | ramita==24)
replace oficio1 = 82    if (ofi==80203 | ofi==80313 | ofi==82113) & (ramita==27 | ramita==28)

* Main Job
gen     occup = .
replace occup = 1	if  oficio1>=11 & oficio1<=14
replace occup = 2	if  oficio1>=21 & oficio1<=26
replace occup = 3	if  oficio1>=31 & oficio1<=35
replace occup = 4	if  oficio1>=41 & oficio1<=44
replace occup = 5	if  oficio1>=51 & oficio1<=54
replace occup = 6	if  oficio1>=61 & oficio1<=63
replace occup = 7	if  oficio1>=71 & oficio1<=75
replace occup = 8	if  oficio1>=81 & oficio1<=83
replace occup = 9	if  oficio1>=91 & oficio1<=96
replace occup = 10	if   oficio1>=1 & oficio1<=3
replace occup = 99	if  oficio1>=99 & oficio1<=99

* Secondary Job
gen   occup_s = .
notes occup_s: the survey does not include information on this topic

* Other Job
gen   occup_o = .
notes occup_o: the survey does not include information on this topic

* Trabajador con contrato:	contrato 
gen   contrato = .
notes contrato: the survey does not include information on this topic

* Ocupación permanente:		ocuperma
/* PP07C: ¿Ese empleo tiene tiempo de finalización?
		1 = sí (incluye changa, trabajo transitorio, por tarea u obra, suplencia, etc;
		2 = no (incluye permanente, fijo, estable, de planta);
		9 = ns/nr 

   PP07E  ¿Ese trabajo es... 
		1 = un plan de empleo? 
		2 = un período de prueba? 
		3 = una beca/pasantía/aprendizaje? 
		4 = ninguno de éstos							*/
gen     ocuperma = 1		if  pp07c==2
replace ocuperma = 0		if  pp07c==1
replace ocuperma = 0		if  pp07c==9 & (pp07e>=1 & pp07e<=3)
notes   ocuperma: defined only for salaried workers - (not including domestic service)

* Derecho a jubilación:		djubila 
* PP07H: ¿Por ese trabajo tiene descuento jubilatorio?
gen     djubila = 0		if  pp07h==2
replace djubila = 1		if  pp07h==1
replace djubila = .		if  ocupado!=1
notes   djubila: defined only for salaried workers

* Seguro de salud del empleo:	dsegsale 
/* ¿En este trabajo tiene:
        PP07G4: obra social? 
      PP07G_59: no tiene ninguno							*/
gen	dsegsale = 1		if  pp07g4==1
replace dsegsale = 0		if  pp07g4==2 | pp07g_59==5
replace dsegsale = .		if  ocupado!=1
notes   dsegsale: defined only for salaried workers

* Derecho a aguinaldo:		daguinaldo
* PP07G2  aguinaldo? 
gen	daguinaldo = 1		if  pp07g2==1
replace daguinaldo = 0		if  pp07g2==2 | pp07g_59==5
notes   daguinaldo: defined only for salaried workers

* Derecho a vacaciones pagas:		dvacaciones  
* PP07G1  vacaciones pagas?  
gen	dvacaciones = 1		if  pp07g1==1
replace dvacaciones = 0		if  pp07g1==2 | pp07g_59==5
notes   dvacaciones: defined only for salaried workers

* Sindicalizado:			sindicato
gen     sindicato = .
notes   sindicato: the survey does not include information on this topic

* Programa de empleo:			prog_empleo 
/* PP07E ¿Ese trabajo es: 
		1 = un plan de empleo? 
		2 = un período de prueba? 
		3 = una beca/pasantía/aprendizaje? 
		4 = ninguno de éstos							*/
gen	prog_empleo = 1		if  pp07e==1 
replace prog_empleo = 0		if  ocupado==1 & pp07e~=1

* Numero de miembros ocupados en el hogar principal
gen     aux = ocupado
replace aux = 0			if  hogarsec==1
egen n_ocu_h=sum(aux),		by(id)
drop aux


/*(************************************************************************************************************************************************ 
*-------------------------------------------------------------	1.10: Programas sociales  ---------------------------------------------------------
************************************************************************************************************************************************)*/

* Plan asistencia social:	asistencia
* = 1 si el hogar recibe algun plan de asistencia social

/* PP07E:  recibe plan de empleo  
    V5_M:  monto del ingreso por SUBSIDIO O AYUDA SOCIAL DEL GOBIERNO, IGLESIAS, ETC.	*/
gen     aux_asistencia = 0
replace aux_asistencia = 1	if  pp07e==1
replace aux_asistencia = 1	if  v5_m>=150 & v5_m<=180
replace aux_asistencia = 1	if  v5_m>=200 & v5_m<=220
replace aux_asistencia = 1	if  v5_m>=270 & v5_m<=300
replace aux_asistencia = 1	if  v5_m>=430 & v5_m<=440
replace aux_asistencia = 1	if  v5_m>=540 & v5_m<=550
replace aux_asistencia = 1	if  v5_m>=640 & v5_m<=650
replace aux_asistencia = 1	if  v5_m>=800 & v5_m<=810
replace aux_asistencia = 1	if  v5_m>=850 & v5_m<=870
replace aux_asistencia = 1	if v5_m>=1080 & v5_m<=1100
replace aux_asistencia = 1	if v5_m>=1350 & v5_m<=1360
egen auxiliar = max(aux_asistencia), by(id)

gen     asistencia = 0
replace asistencia = 1		if  auxiliar==1
drop aux_asistencia auxiliar


/*(***********************************************************************************************************************************************
---------------------------------------------------------- 1.11: Variables de ingresos -----------------------------------------------------------
***********************************************************************************************************************************************)*/	

********** A. INGRESOS LABORALES **********
	
****** A.1.OCUPACION PRINCIPAL ******

* VARIABLES ORIGINALES DE LA ENCUESTA
*    P21:  Monto de ingreso de la OCUPACIÓN PRINCIPAL (PP06C + PP06D + PP08D1 + PP08F1 + PP08F2)

* PATRONES y CUENTAPROPIAS
*	  PP06C_HD: ingresos de patrones y cuenta propia sin socios
*	  PP06D_HD: ingresos de patrones y cuenta propia con socios

* ASALARIADOS
*	 PP08D1_HD: sueldos/jornales, salario familiar, horas extras, otras bonificaciones habituales y tickets, vales o similares
*	 PP08F1_HD: comisiones por venta/producción
*	 PP08F2_HD: propinas

*        PP08J1_HD: monto por aguinaldo percibido en ese mes
*        PP08J2_HD: monto por otras bonificaciones no habituales percibido en ese mes
*        PP08J3_HD: monto por retroactivos percibido en ese mes

replace pp08j1_hd = pp08j1_hd/6

****   i)  ASALARIADOS
* Monetario	
egen  iasalp_m = rsum(pp08d1_hd pp08f1_hd pp08f2_hd pp08j1_hd)	if  relab==2

* No monetario
gen   iasalp_nm = .
notes iasalp_nm: there is not information on this topic


*****  ii)  CUENTA PROPIA
* Monetario	
egen  ictapp_m = rsum(pp06c_hd pp06d_hd)			if  relab==3

* No monetario
gen   ictapp_nm = .	  
notes ictapp_nm: there is not information on this topic


***** iii)  PATRON
* Monetario	
egen  ipatrp_m = rsum(pp06c_hd pp06d_hd)			if  relab==1

* No monetario
gen   ipatrp_nm = .	
notes ipatrp_nm: there is not information on this topic


*****  vi)  OTROS NO ESPECIFICADOS (SIN RELACION LABORAL)
* Monetario	
gen   iolp_m = .

* No monetario
gen iolp_nm = .	


***** v)   EXTRAORDINARIOS
egen ila_extraord = rsum(pp08j2_hd pp08j3_hd)			if  relab==2


** Last wage payment
* PATRONES y CUENTAPROPIAS
*	  PP06C_HD: ingresos de patrones y cuenta propia sin socios
*	  PP06D_HD: ingresos de patrones y cuenta propia con socios
* ASALARIADOS
*	 PP08D1_HD: sueldos/jornales, salario familiar, horas extras, otras bonificaciones habituales y tickets, vales o similares
egen    wage_base = rsum(pp08d1_hd pp06c_hd pp06d_hd), missing
replace wage_base = 0		if  relab==4

** Bonos
*	 PP08F1_HD: comisiones por venta/producción
*	 PP08F2_HD: propinas
*        PP08J1_HD: monto por aguinaldo percibido en ese mes
egen bonos = rsum(pp08f1_hd pp08f2_hd pp08j1_hd), missing


****** A.2.OCUPACION NO PRINCIPAL ******

* VARIABLES ORIGINALES DE LA ENCUESTA
* P12_TOT_HD: Monto de ingreso de OTRAS OCUPACIONES (no se puede identificar relación laboral en las mismas) 

****   i)  ASALARIADOS
* Monetario	
gen iasalnp_m = .

* No monetario
gen iasalnp_nm = .


****  ii)  CUENTA PROPIA
* Monetario	
gen ictapnp_m  = .
	
* No monetario
gen ictapnp_nm = .


**** iii)  PATRON
* Monetario	
gen ipatrnp_m  = .

* No monetario
gen ipatrnp_nm = .

				
****  iv) SIN RELACION (todo aquel ingreso  laboral que no se pueda clasificar con las categorias anteriores)
* Monetario
gen   iolnp_m = tot_p12_hd			if  tot_p12_hd>0 & tot_p12_hd<.  
notes iolnp_m: it is not possible to identify the labor relationship in other occupations
    
* No monetario
gen iolnp_nm = .		


** Last wage payment
gen   wage_base_s = .
notes wage_base_s: the survey does not include information on this topic

gen   wage_base_o = .
notes wage_base_o: the survey does not include information on this topic

** Bonos
gen   bonos_s = .
notes bonos_s: the survey does not include information on this topic

gen   bonos_o = .
notes bonos_o: the survey does not include information on this topic


	
********** B.INGRESOS NO LABORALES  ****
		
***** B.1. INGRESOS NO LABORALES POR FUENTE *****

****   i)  JUBILACIONES Y PENSIONES 
*  V2_M_HD:  Monto del ingreso por JUBILACION O PENSION  
* V21_M_HD:  Monto por AGUINALDO DE JUBILACION

* Contributivas
gen  ijubi_con = .		

* No Contributivas
gen ijubi_ncon = .		

* No Identificables
replace   v21_m_hd = v21_m_hd/6

egen    ijubi_o = rsum(v2_m_hd v21_m_hd), missing
replace ijubi_o = .		if  ijubi_o==0
	
		
****  ii)  CAPITAL, INTERESES, ALQUILERES, RENTAS, BENEFICIOS, DIVIDENDOS 
*  V8_M_HD:  Monto del ingreso por ALQUILER (VIVIENDA , TERRENO, OFICINA, ETC.) DE SU PROPIEDAD.
*  V9_M_HD:  Monto del ingreso por GANANCIAS DE ALGUN NEGOCIO EN EL QUE NO TRABAJÓ.
* V10_M_HD:  Monto del ingreso por INTERESES O RENTAS POR PLAZOS FIJOS/INVERSIONES.
egen    icap = rsum(v8_m_hd v9_m_hd v10_m_hd), missing
replace icap = .		if  icap==0

	
**** iii)  PROGRAMAS DE ALIVIO A LA POBREZA y TRANSFERENCIAS ESTATALES

* CCT		
gen     icct = .		

* No CCT monetarias
*  V4_M_HD:  Monto del ingreso por SEGURO DE DESEMPLEO (2 obs con 14,000 - 1 obs con 40,000)
* V11_M_HD:  Monto del ingreso por BECA DE ESTUDIO
egen    inocct_m = rsum(v4_m_hd v11_m_hd), missing
replace inocct_m = .		if  inocct_m==0

* No CCT no monetarias
gen     inocct_nm = .

* Ingreso por transferencias estatales no identificable en las categorias anteriores 
* V5_M_HD:  Monto del ingreso por SUBSIDIO O AYUDA SOCIAL (EN DINERO) DEL GOBIERNO, IGLESIAS, ETC.
gen     itrane_ns = v5_m_hd
replace itrane_ns = .		if  itrane_ns==0
notes   itrane_ns: conditional cash transfers are included in this variable, but it cant be separated from other income concepts
	

**** iv)  TRANSFERENCIAS PRIVADAS 

* Del extranjero Monetario (remesas) 	 	
gen     itranext_m = .
	
* Del extanjero No Monetario
gen    itranext_nm = .

* Del interior Monetario 	
* V12_M_HD:  Monto del ingreso por CUOTAS DE ALIMENTOS O AYUDA EN DINERO DE PERSONAS QUE NO VIVEN EN EL HOGAR.
egen    itranint_m = rsum(v12_m_hd), missing 
replace itranint_m = .		if  itranint_m==0 
	
* Del interior No Monetario
gen itranint_nm = .

* No clasificable en las anteriores del punto iv
gen itranp_ns = .
		

****  v)  OTROS INGRESOS NO LABORALES
*  V18_M_HD: Monto del ingreso por OTROS INGRESOS EN EFECTIVO (LIMOSNAS, JUEGOS DE AZAR, ETC.)---> INCLUYE EXTRAORDINARIOS
* V19_AM_HD: Monto por trabajo de menores de 10 años
replace v18_m_hd = .	if  v18_m_hd>14000

egen    inla_otro = rsum(v18_m_hd v19_am_hd), missing
replace inla_otro = .	if  inla_otro==0	

gen inla_extraord = .


/*(************************************************************************************************************************************************ 
*--------------------------------------------------- 1.12: INGRESO OFICIAL ------------------------------------------------------------------------
************************************************************************************************************************************************)*/

* LINEAS DE INDIGENCIA OFICIALES ESTIMADAS A PARTIR DE VALORES INDEC DE LI-GBA DE 2006 y 2016 
gen	lp_extrema =     .	
replace lp_extrema =  567.03		if  trimestre==3 		
replace lp_extrema =  591.58		if  trimestre==4 		

* Se asumió que en 2003-2015 la relación entre LI-GBA y LI-RegionX era la misma que 2016-2017						
replace lp_extrema = lp_extre*0.9949 	if  pampa==1		/*( Pampeana	)*/
replace lp_extrema = lp_extre*0.8943	if  cuyo==1		/*( Cuyo	)*/
replace lp_extrema = lp_extre*0.8701	if  noa==1		/*( NOA		)*/
replace lp_extrema = lp_extre*1.0301	if  pata==1		/*( Patagonia	)*/
replace lp_extrema = lp_extre*0.8934	if  nea==1		/*( NEA		)*/

* LINEAS DE POBREZA OFICIALES ESTIMADAS A PARTIR DE VALORES INDEC DE LP-GBA DE 2006 y 2016 
gen	lp_moderada =     .
replace lp_moderada = 1256.10		if  trimestre==3   
replace lp_moderada = 1333.34		if  trimestre==4  

* Se asumió que en 2003-2015 la relación entre LP-GBA y LP-RegionX era la misma que en 2016-2017							
replace lp_moderada = lp_moder*0.9947 	if  pampa==1		/*( Pampeana	)*/
replace lp_moderada = lp_moder*0.9528	if  cuyo==1		/*( Cuyo	)*/
replace lp_moderada = lp_moder*0.8081	if  noa==1		/*( NOA		)*/
replace lp_moderada = lp_moder*1.1696	if  pata==1		/*( Patagonia	)*/
replace lp_moderada = lp_moder*0.8371	if  nea==1		/*( NEA		)*/


* INGRESO OFICIAL 
gen	ae = 1
replace ae = 0.315	if  edad<1 
replace ae = 0.37	if  edad==1
replace ae = 0.46	if  edad==2
replace ae = 0.51	if  edad==3
replace ae = 0.55	if  edad==4
replace ae = 0.60	if  edad==5
replace ae = 0.64	if  edad==6
replace ae = 0.66	if  edad==7
replace ae = 0.68	if  edad==8
replace ae = 0.69	if  edad==9
replace ae = 0.79	if  hombre==1 & edad==10 
replace	ae = 0.82	if  hombre==1 & edad==11 
replace ae = 0.85	if  hombre==1 & edad==12 
replace ae = 0.90	if  hombre==1 & edad==13 
replace ae = 0.96	if  hombre==1 & edad==14 
replace ae = 1		if  hombre==1 & edad==15 
replace ae = 1.03	if  hombre==1 & edad==16 
replace ae = 1.04	if  hombre==1 & edad==17 
replace ae = 0.70	if  hombre==0 & edad==10 
replace ae = 0.72	if  hombre==0 & edad==11 
replace ae = 0.74	if  hombre==0 & edad==12 
replace ae = 0.76	if  hombre==0 & edad==13 
replace ae = 0.76	if  hombre==0 & edad==14 
replace ae = 0.77	if  hombre==0 & edad==15 
replace ae = 0.77	if  hombre==0 & edad==16 
replace ae = 0.77	if  hombre==0 & edad==17 
replace ae = 1.02	if  hombre==1 & edad>=18 & edad<=29
replace ae = 1		if  hombre==1 & edad>=30 & edad<=45
replace ae = 1		if  hombre==1 & edad>=46 & edad<=60
replace ae = 0.83	if  hombre==1 & edad>=61 & edad<=75
replace ae = 0.74	if  hombre==1 & edad>=76 & edad<110
replace ae = 0.76	if  hombre==0 & edad>=18 & edad<=29
replace ae = 0.77	if  hombre==0 & edad>=30 & edad<=45
replace ae = 0.76	if  hombre==0 & edad>=46 & edad<=60
replace ae = 0.67	if  hombre==0 & edad>=61 & edad<=75
replace ae = 0.63	if  hombre==0 & edad>=76 & edad<110
egen   aef = sum(ae),   by(id) 


**********************************************************************************
**** INGRESO POBREZA OFICIAL
**********************************************************************************
capture gen v11_m_hd = v11_m
capture gen v18_m_hd = v18_m

replace pp08j1_hd = pp08j1_hd * 6
replace  v21_m_hd = v21_m_hd * 6

* Identifico a quienes agregar PJJHD
capture gen pj1_1 = 0
capture gen pj2_1 = 0
capture gen pj3_1 = 0

gen x1 = 150 if pj1_1==1 & v5_m<150 & pp08d1<150	/* PJJHD en ocup. prin. e ingreso ocup. prin. e ingreso ayuda social es menor a 150	*/
gen x2 = 150 if pj2_1==1 & v5_m<150 & tot_p12<150	/* PJJHD en ocup. secu. e ingreso ocup. secu. e ingreso ayuda social es menor a 150	*/
gen x3 = 150 if pj3_1==1 & v5_m<150			/* PJJHD para desocupado o inactivo e ingreso por ayuda social menor a 150		*/

egen jefes = rsum(x1 x2 x3)

********************** INGRESO LABORAL
egen laboral_total = rsum(pp06c pp06d pp08d1 pp08f1 pp08f2   pp08j1 pp08j2 pp08j3   tot_p12   jefes)

********************** INGRESO NO LABORAL
replace t_vi = 0	if  t_vi<0 
egen no_laboral = rsum(t_vi)

egen no_laboral_aux = rsum(v2_m v3_m v4_m v5_m v8_m v9_m v10_m v11_m v12_m v18_m v19_am v21_m)

* Genero Ingreso no Laboral que falta: V22_M: retroactivo de jubilación y pensión
gen     v22_m = (no_laboral - no_laboral_aux)
replace v22_m = 0	if  v22_m<0

********************** INGRESO TOTAL INDIVIDUAL
egen ingreso_tot = rsum(laboral_total no_laboral)

gen auxiliar_labor = (p47-ingreso_tot)	if  p47>ingreso_tot


* HOT-DECK
egen laboral_total_hd = rsum(pp06c_hd pp06d_hd pp08d1_hd pp08f1_hd pp08f2_hd   pp08j1_hd pp08j2_hd pp08j3_hd   tot_p12_hd   jefes)
egen   labor_total_hd = rsum(laboral_total_hd auxiliar_labor)	

egen    no_laboral_hd = rsum(v2_m_hd v3_m_hd v4_m_hd v5_m_hd v8_m_hd v9_m_hd v10_m_hd v11_m_hd v12_m_hd v18_m_hd v19_am v21_m_hd v22_m)

egen ingreso_total_hd = rsum(labor_total_hd no_laboral_hd)
* RESTA AGUINALDOS
replace ingreso_total_hd = ingreso_total_hd - (pp08j1_hd + v21_m_hd)

egen           itf_hd = sum(ingreso_total_hd), by(codusu nro_hogar trimestre)

gen    ing_pob_ext = itf_hd/aef
gen    ing_pob_mod = itf_hd/aef
gen ing_pob_mod_lp = ing_pob_mod / lp_moderada

drop ae aef
rename itf itf_indec
rename ipcf ipcf_indec


/*(************************************************************************************************************************************************ 
			1.13: PRECIOS 
************************************************************************************************************************************************)*/

* Mes en el que están expresados los ingresos de cada observación
gen mes_ingreso = .

* IPC del mes base
gen ipc = 160.405235290527			/*  MES BASE: promedio Junio-Noviembre	*/

gen cpiperiod = "2012m07-2012m12"
 
* Factor de ajuste para cada observación
gen     ipc_rel = 1.000
replace ipc_rel = 0.972		if  trimestre==3
replace ipc_rel = 1.028		if  trimestre==4
	
* Ajuste por precios regionales
gen     p_reg = 1
replace p_reg = 0.8695		if  urbano==0
	
foreach i of varlist iasalp_m iasalp_nm  ictapp_m ictapp_nm  ipatrp_m ipatrp_nm  iolp_m iolp_nm  iasalnp_m iasalnp_nm  ictapnp_m ictapnp_nm  ipatrnp_m ipatrnp_nm  iolnp_m iolnp_nm  ijubi_con ijubi_ncon ijubi_o  icap  icct inocct_m inocct_nm itrane_ns  itranext_m itranext_nm itranint_m itranint_nm itranp_ns  inla_otro	{
		replace `i' = `i' / p_reg 
		replace `i' = `i' / ipc_rel 
		}


/*=================================================================================================================================================
			2: Preparacion de los datos: Variables de segundo orden
=================================================================================================================================================*/
*quietly include "`do_file_aspire'"
quietly include "`do_file_1_variables'"
quietly include "`do_file_renta_implicita'"
quietly include "`do_file_2_variables'"
quietly include "`do_file_label'"
compress


/*==================================================================================================================================================
								3: Resultados
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables a Documentar Base de Datos CEDLAS --------------
*************************************************************************************************************************************************)*/

order pais ano encuesta id com pondera pondera_eph strata psu relacion relacion_est hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza raza_est lengua lengua_est region_est1 region_est2 region_est3 urbano gba pampa cuyo noa nea pata nuevareg migrante migra_ext migra_rur anios_residencia migra_rec propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp seguro_salud tipo_seguro enfermo visita ocupado desocupa pea edad_min durades hstrp hstrs hstrt deseo_emp antigue relab relab_s relab_o empresa sector1d sector tarea contrato ocuperma djubila dsegsale daguinaldo dvacaciones sindicato prog_empleo n_ocu_h asal grupo_lab categ_lab asistencia iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_con ijubi_ncon ijubi_o icap icct inocct_m inocct_nm itrane_ns itranext_m itranext_nm itranint_m itranint_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg ipc pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11_new ppp11_orig ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11  


** EXPENDITURE VARIABLES

* Total annual consumption of water supply/piped water	
gen   pwater_exp = .
notes pwater_exp: the survey does not include information on this topic

* Total annual consumption of water supply and hot water	
gen   water_exp = .
notes water_exp: the survey does not include information on this topic

* Total annual consumption of garbage collection	
gen   garbage_exp = .
notes garbage_exp: the survey does not include information on this topic

* Total annual consumption of sewage collection	
gen   sewage_exp = .
notes sewage_exp: the survey does not include information on this topic

* Total annual consumption of garbage and sewage collection	
gen   waste_exp = .
notes waste_exp: the survey does not include information on this topic

* Total annual consumption of other services relating to the dwelling	
gen   dwelothsvc_exp = .
notes dwelothsvc_exp: the survey does not include information on this topic

* Total annual consumption of electricity	
gen   elec_exp = .
notes elec_exp: the survey does not include information on this topic

* Total annual consumption of network/natural gas	
gen   ngas_exp = .
notes ngas_exp: the survey does not include information on this topic

* Total annual consumption of liquefied gas	
gen   LPG_exp = .
notes LPG_exp: the survey does not include information on this topic

* Total annual consumption of network/natural and liquefied gas	
gen   gas_exp = .
notes gas_exp: the survey does not include information on this topic

* Total annual consumption of diesel	
gen   diesel_exp = .
notes diesel_exp: the survey does not include information on this topic

* Total annual consumption of kerosene	
gen   kerosene_exp = .
notes kerosene_exp: the survey does not include information on this topic

* Total annual consumption of other liquid fuels	
gen   othliq_exp = .
notes othliq_exp: the survey does not include information on this topic

* Total annual consumption of all liquid fuels	
gen   liquid_exp = .
notes liquid_exp: the survey does not include information on this topic

* Total annual consumption of firewood	
gen   wood_exp = .
notes wood_exp: the survey does not include information on this topic

* Total annual consumption of coal	
gen   coal_exp = .
notes coal_exp: the survey does not include information on this topic

* Total annual consumption of peat	
gen   peat_exp = .
notes peat_exp: the survey does not include information on this topic

* Total annual consumption of other solid fuels	
gen   othsol_exp = .
notes othsol_exp: the survey does not include information on this topic

* Total annual consumption of all solid fuels	
gen   solid_exp = .
notes solid_exp: the survey does not include information on this topic

* Total annual consumption of all other fuels	
gen   othfuel_exp = .
notes othfuel_exp: the survey does not include information on this topic

* Total annual consumption of central heating	
gen   central_exp = .
notes central_exp: the survey does not include information on this topic

* Total annual consumption of hot water	
gen   hwater_exp = .
notes hwater_exp: the survey does not include information on this topic

* Total annual consumption of heating	
gen   heating_exp = .
notes heating_exp: the survey does not include information on this topic

* Total annual consumption of all utilities excluding telecom and other housing	
gen   utl_exp = .
notes utl_exp: the survey does not include information on this topic

* Total annual consumption of materials for the maintenance and repair of the dwelling 	
gen   dwelmat_exp = .
notes dwelmat_exp: the survey does not include information on this topic

* Total annual consumption of services for the maintenance and repair of the dwelling	
gen   dwelsvc_exp = .
notes dwelsvc_exp: the survey does not include information on this topic

* Total annual consumption of dwelling repair/maintenance 	
gen   othhousing_exp = .
notes othhousing_exp: the survey does not include information on this topic

* Total annual consumption of fuels for personal transportation	
gen   transfuel_exp = .
notes transfuel_exp: the survey does not include information on this topic

* Total annual consumption of landline phone services	
gen   landphone_exp = .
notes landphone_exp: the survey does not include information on this topic

* Total annual consumption of cell phone services	
gen   cellphone_exp = .
notes cellphone_exp: the survey does not include information on this topic

* Total consumption of all telephone services 	
gen   tel_exp = .
notes tel_exp: the survey does not include information on this topic

* Total consumption of internet services	
gen   internet_exp = .
notes internet_exp: the survey does not include information on this topic

* Total consumption of telefax services	
gen   telefax_exp = .
notes telefax_exp: the survey does not include information on this topic

* Total consumption of all telecommunication services	
gen   comm_exp = .
notes comm_exp: the survey does not include information on this topic

* Total consumption of TV broadcasting services	
gen   tv_exp = .
notes tv_exp: the survey does not include information on this topic

* Total consumption of tv, internet and telephone	
gen   tvintph_exp = .
notes tvintph_exp: the survey does not include information on this topic

save "`base_out_nesstar_cedlas'", replace
exit
