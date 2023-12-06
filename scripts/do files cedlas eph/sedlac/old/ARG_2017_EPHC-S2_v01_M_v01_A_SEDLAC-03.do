/*===========================================================================
Country name:		Argentina
Year:			2017-S2
Survey:			EPHC
Vintage:		01M-01A
Project:		03
---------------------------------------------------------------------------
Author:			Leopoldo Tornarolli
			leopoldo.tornarolli@depeco.econo.unlp.edu.ar
Dependencies:		CEDLAS/UNLP -- The World Bank
Creation Date:		January, 2019
Modification Date:  
Output:			sedlac do-file template
===========================================================================*/

/*===============================================================================
                          0: Program set up
===============================================================================*/
version 10
drop _all

local country  "ARG"    // Country ISO code
local year     "2017"   // Year of the survey
local survey   "EPHC"   // Survey acronym
local vm       "01"     // Master version
local va       "01"     // Alternative version
local project  "03"     // Project version
local period   "-S2"    // Periodo, ejemplo -S1 -S2
local alterna  ""       // 
local vr       "01"     // version renta
local vsp      "01"	// version ASPIRE
include "${rootdatalib}/_git_sedlac-03/_aux/sedlac_hardcode.do"

/*==================================================================================================================================================
								1: Preparacion de los datos: Variables de Primer Orden
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.1: Abrir bases de datos  ---------------------------------------------------------
*************************************************************************************************************************************************)*/ 

* Abre base de datos original  
use "`base_out_nesstar_base'", clear

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.2: Variables de identificacion  --------------------------------------------------
*************************************************************************************************************************************************)*/

destring decindr decifr deccfr, replace

* Identificador del pais:		pais
gen pais = "ARG"

* Identificador del año:		ano
gen ano = 2017 

* Identificador de la encuesta:		encuesta
gen encuesta = "EPHC - Semestre II"

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

* Identificador del componente:		com
gen com = componen

gen double pid = componen

* Chequea posibles duplicados
duplicates report id com

* Factor de Ponderación:		pondera
* PONDERA: factor de expansión de observaciones
cap drop pondera_eph
gen pondera_eph = pondera

* Estrato:				strata
gen   strata = .
notes strata: the survey does not include information on this topic

* Unidad Primaria de Muestreo:		psu 
gen   psu = .
notes psu: the survey does not include information on this topic



/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.3: Variables demograficas  -------------------------------------------------------
*************************************************************************************************************************************************)*/

/*( Relación con el jefe de hogar:	relacion
    Categorías de la nueva variable armonizada:
		1:  jefe		
		2:  esposo/cónyuge
		3:  hijo/hija		(hijastro/hijastra)		
		4:  padre/madre		(suegro/suegra)
		5:  otro pariente	(nieto/yerno/nuera)
		6:  no pariente										)*/
/* CH03: Relación de Parentesco 
		01 = Jefe		02 = Cónyuge/Pareja
		03 = Hijo/Hijastro	04 = Yerno/Nuera
		05 = Nieto		06 = Madre/Padre
		07 = Suegro		08 = Hermano
		09 = Otros Familiares	10 = No Familiares      */
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
	  2 = mujeres										*/
gen     hombre = 0		if  ch04==2
replace hombre = 1		if  ch04==1	

* Dummy de estado civil 1:		casado
/* CH07: ¿Actualmente está:
		1 = unido?
		2 = casado?
		3 = separado ó divorciado?
		4 = viudo?	    	
		5 = soltero?									*/
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
*-------------------------------------------------------------	1.4: Variables regionales  ---------------------------------------------------------
**************************************************************************************************************************************************)*/

/* REGION:	 1 =  Gran Buenos Aires 		40 = NOA
		41 = NEA				42 = Cuyo
		43 = Pampeana				44 = Patagonia				*/

* Desagregación 1 (Región):		region_est1
rename region region_ephc
gen	      region_est1 = "1 - Gran Buenos Aires "	if  region_ephc==1			
replace	      region_est1 = "2 - Pampeana          "	if  region_ephc==43 			
replace	      region_est1 = "3 - Cuyo              "	if  region_ephc==42			
replace	      region_est1 = "4 - Noroeste Argentino"	if  region_ephc==40			 
replace	      region_est1 = "5 - Patagonia         "	if  region_ephc==44				
replace	      region_est1 = "6 - Noreste Argentino "	if  region_ephc==41			
notes         region_est1: Región

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

* Desagregación 3			region_est3
gen	     region_est3 = .
label define region_est3 1 "" 2 ""
label values region_est3 region_est3

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

* Migrante (por lugar de nacimiento)
/* CH15: dónde nació
		1 = en esta localidad
		2 = en otra localidad de esta provincia
		3 = en otra provincia
		4 = en un pais limitrofe
		5 = en otro pais
		9 = NS/NR				*/
gen	migrante = 0		if  ch15==1
replace migrante = 1		if  ch15>=2 & ch15<=5

* Tipo de migración: migrante extranjero 
/* = 0 si es migrante de otro municipio del pais
   = 1 si es migrante de otro país extranjero		*/
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
		9 = NS/NR				*/
gen	migra_rec = 0		if  migrante==1 & ch16==1
replace migra_rec = 1		if  migrante==1 & ch16>=2 & ch16<=5


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.5: Vivienda e infraestructura  ---------------------------------------------------
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
	09 = Otra situación (especificar)  */
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
IV12_3 La vivienda está ubicada en villa de emergencia				*/
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
	2 =  No							*/
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
	4 =  Otra fuente							*/
gen     agua = 1		if (iv6==1 | iv6==2) & (iv7==1 | iv7==2)
replace agua = 1		if  iv7==1
replace agua = 0		if  iv7==3 | iv7==4  | iv6==3  
replace agua = .		if  relacion!=1

*==========================================================================================*

* Improved Water Recommended
gen     imp_wat_rec = 1		if  iv6==1 | iv6==2 | (iv6==3 & inlist(iv7,1,2,3)) 
replace imp_wat_rec = 0		if  iv6==3 & inlist(iv7,3,4)

* Improved Water Underestimate
gen     imp_wat_underest = 1	if  iv6==1 | iv6==2  
replace imp_wat_underest = 0	if  iv6==3 

* Improved Water Overestimate
gen     imp_wat_overest = 1	if  iv6==1 | iv6==2 | (iv6==3 & inlist(iv7,1,2,3)) 
replace imp_wat_overest = 0	if  iv6==3 & iv7==4

* All piped classification
gen     piped = 0
replace piped = 1		if  inlist(iv6,1,2)
replace piped = 1		if  iv6==3 & iv7==1

* Piped to premises classification 
gen     piped_to_prem = 0
replace piped_to_prem = 1	if  inlist(iv6,1,2)

* Water Source
gen     water_source = .
	
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

label var      imp_wat_rec "Access to improved drinking water-MPI & WGP - Recommended"
label var imp_wat_underest "Access to improved drinking water-MPI & WGP - Underestimate"
label var  imp_wat_overest "Access to improved drinking water-MPI & WGP - Overestimate"
label var            piped "Access to piped water"
label var    piped_to_prem "Piped water to premises"
label var     water_source "Source of drinking water"
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
	4 = A hoyo/excavación en al tierra				*/
gen     banio = 0		if  iv8==2 | iv9==3 | (iv10==2 | iv10==3)
replace banio = 1		if  iv10==1
replace banio = .		if  relacion!=1

* Cloacas:				cloacas
gen     cloacas = 1		if  banio==1 &  iv11==1 
replace cloacas = 0		if  banio==0 | (iv11>=2 & iv11<=4) 
replace cloacas = .		if  relacion!=1

*============================================================================================================*

* Improved Sanitation Recommended
gen     imp_san_rec = 1		if  iv8==1 & (inlist(iv10,1,2) & inlist(iv11,1,2,3))
replace imp_san_rec = 0		if  iv8==2 | iv10==3 | iv11==4 
replace imp_san_rec = 0		if  iv9==3

* Improved Sanitation Underestimate
gen     imp_san_underest = 1	if  iv8==1 & (inlist(iv10,1,2) & inlist(iv11,1,2))
replace imp_san_underest = 0	if  iv8==2 | iv10==3 | iv11==3 | iv11==4  
replace imp_san_underest = 0	if  iv9==3

* Improved Sanitation Overestimate
gen     imp_san_overest = 1	if  iv8==1 & (inlist(iv10,1,2) & inlist(iv11,1,2,3))
replace imp_san_overest = 0	if  iv8==2 | iv10==3 | iv11==4 

* SEWER
gen     sewer = 0
replace sewer = 1		if (inlist(iv10,1,2) & inlist(iv11,1))

* OPEN DEFECATION
gen     open_def = 0
replace open_def = 1		if iv8==2	

* Sanitation Source
gen     sanitation_source = .

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

label var         imp_san_rec "Access to improved sanitation facilities - Recommended"
label var    imp_san_underest "Access to improved sanitation facilities - Underestimate"
label var     imp_san_overest "Access to improved sanitation facilities - Overestimate"
label var               sewer "Access to toilet facility with sewer connection"
label var            open_def "Open defecation"
label var   sanitation_source "Source of sanitation"
label var sanitation_original "Original sanitation variable"

*============================================================================================================*

* Electricidad en la vivienda:		elect
gen   elect = .
notes elect: the survey does not include information on this topic

* Teléfono:				telef
gen   telef = .
notes telef: the survey does not include information on this topic


/*(************************************************************************************************************************************************* 
*------------------------------------------------------------ 1.6: Bienes durables y servicios  ----------------------------------------------------
*************************************************************************************************************************************************)*/

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
notes televisor: there is not information the survey to define this variable

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


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.7: Variables educativas  ---------------------------------------------------------
*************************************************************************************************************************************************)*/

* Alfabeto:				alfabeto
/* CH09: Sabe leer y escribir? 
		1 = Sí
		2 = No
		3 = Menor de 2 años										*/
gen     alfabeto = 1		if  ch09==1
replace alfabeto = 0		if  ch09==2
replace alfabeto = .		if  edad<5
notes   alfabeto: variable defined for individuals 5-years-old and older

* Asiste a la educación formal:		asiste
/* CH10: Asiste o asistió a algún establecimiento educativo?(colegio, escuela, universidad) 
		1 = Si, asiste
                2 = No asiste, pero asistió
                3 = Nunca asistió										*/
gen     asiste = 0		if  ch10>=0 & ch10<=3
replace asiste = 1		if  ch10==1
replace asiste = .		if  edad<5
notes   asiste: variable defined for individuals 5-years-old and older

* Establecimiento educativo público:	edu_pub
/* CH11: Ese establecimiento es: 
		1 = público
		2 = privado
		9 = ns/nr 											*/
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
	       98 = Educación especial		99 = Ns./ Nr.					*/
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
		7 = Sin instrucción								*/
gen	nivel = nivel_ed
replace nivel = 0		if  nivel_ed==7


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.8: Variables Salud  --------------------------------------------------------------
*************************************************************************************************************************************************)*/

* Seguro de salud			seguro_salud
/* CH08: Tiene algún tipo de cobertura médica por la que paga o le descuentan?
                 1 = Obra social (incluye PAMI)
                 2 = Mutual/Prepaga/Servicio de emergencia
                 3 = Planes y seguros públicos
                 4 = No paga ni le descuentan
                 9 = Ns/Nr  
		12 = Obra Social y Mutual/Prepaga/Servicio de Emergencia
		13 = Obra Social y Planes y seguros públicos
		23 = Mutual/Prepaga/Servicios de Emergencia y Planes y seguros públicos
	       123 = Obra Social y Mutual/Prepaga/Servicio de Emergencia y Planes y seguros públicos		*/
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
*------------------------------------------------------------- 1.9: Variables laborales ------------------------------------------------------------
*************************************************************************************************************************************************)*/
* ARG 2017: Personas de 10 y más años de edad

* Ocupado:				ocupado
/* ESTADO: Condición de Actividad (para las personas de 10 años y más)
		0=missing
		1= Ocupado
                2= Desocupado
		3= Inactivo 
		4= no corresponde (menos de 9 años)								 */
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

* Edad mínima de preguntas laborales
gen   edad_min = 10
notes edad_min: people aged 10 and older answer the labor module

* Duración del desempleo (en meses):	durades
/* PP10A: Cuánto hace que está buscando trabajo?
		1 = menos de 1 mes?
                2 = de 1 a 3 meses?
                3 = más de 3 a 6 meses?
                4 = más de 6 a 12 meses?
                5 = más de 1 año?										*/
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
	PP04B3_DIA: Cantidad de días 										*/
* Antiguedad (definida de forma continua)
gen   antigue = .
notes antigue: there is not information on the survey to define this variable (it could be defined by categories)

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
		9 = Ns/Nr											*/
gen     relab = 1		if  cat_ocup==1
replace relab = 2		if  cat_ocup==3
replace relab = 3		if  cat_ocup==2
replace relab = 4		if  cat_ocup==4
replace relab = 5		if  desocupa==1

gen   relab_s = .
notes relab_s: the survey does not include information on this topic

gen   relab_o = .
notes relab_o: the survey does not include information on this topic

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
		 9 = ns/nr											*/
gen	empresa = 1		if (pp04c>=6 & pp04c<=12) | pp04c99==2 | pp04c99==3
replace empresa = 2		if (pp04c>=1 & pp04c<=5)  | pp04c99==1
replace empresa = 2		if  pp04b1==1
replace empresa = 3		if  pp04a==1 
notes   empresa: 1,739 observations ocupado=1 without information on empresa

* Sector de actividad:			sector1d
rename pp04b_cod rama

gen	sector1d = 1		if  (rama>=1 & rama<=2)  | (rama>=101 & rama<=200) | (rama==8102)
replace sector1d = 2		if   rama==3 | rama==300
replace sector1d = 3		if (rama>=5  & rama<=9)  | (rama>=500 & rama<=900)
replace sector1d = 4		if (rama>=10 & rama<=33) |  rama==58  | (rama>=1001 & rama<=3300) | rama==5800 | rama==9502
replace sector1d = 5		if (rama>=35 & rama<=36) | (rama>=3501 & rama<=3600)
replace sector1d = 6		if  rama==40 | rama==4000
replace sector1d = 7		if (rama>=45 & rama<=48) |  rama==95  | (rama>=4501 & rama<=4811) | rama==9503
replace sector1d = 8		if (rama>=55 & rama<=56) | (rama>=5500 & rama<=5602)
replace sector1d = 9		if (rama>=49 & rama<=53) |  rama==61  |  rama==79  | (rama>=4901 & rama<=5300) | rama==6100 | rama==7900
replace sector1d = 10		if (rama>=64 & rama<=66) | (rama>=6400 & rama<=6600)
replace sector1d = 11		if  rama==62 | (rama>=68 & rama<=74) | (rama>=77 & rama<=78) | (rama>=80 & rama<=82) | rama==6200 | (rama>=6800 & rama<=7400) | (rama>=7701 & rama<=7800) | (rama>=8000 & rama<=8101) | (rama==8200) | rama==9501
replace sector1d = 12		if (rama>=83 & rama<=84) | (rama>=8300 & rama<=8403)
replace sector1d = 13		if  rama==85 | (rama>=8501 & rama<=8509)
replace sector1d = 14		if  rama==75 | (rama>=86 & rama<=88) | rama==7500 | (rama>=8600 & rama<=8800)
replace sector1d = 15		if (rama>=37 & rama<=39) | (rama>=59 & rama<=60) | rama==63 | (rama>=90 & rama<=94) | rama==96 | (rama>=3700 & rama<=3900) | (rama>=5900 & rama<=6000) | rama==6300 | (rama>=9000 & rama<=9409) | (rama>=9601 & rama<=9609)
replace sector1d = 16		if (rama>=97 & rama<=98) | (rama>=9700 & rama<=9800)
replace sector1d = 17		if  rama==99 | rama==9900 
replace sector1d = .		if  ocupado!=1

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
      10 = Servicio domestico                                    */
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

* Ocupación realiza:			tarea
* PP04D_COD: Código de Ocupación (Ver documento Clasificador de Ocupaciones - CNO'91)
gen   tarea = pp04d_cod

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
		4 = ninguno de éstos										*/
gen     ocuperma = 1		if  pp07c==2
replace ocuperma = 0		if  pp07c==1
replace ocuperma = 0		if  pp07c==9 & (pp07e>=1 & pp07e<=4)
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
      PP07G_59: no tiene ninguno										*/
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
		4 = ninguno de éstos										*/
gen	prog_empleo = 1		if  pp07e==1 
replace prog_empleo = 0		if  ocupado==1 & pp07e~=1

* Numero de miembros ocupados en el hogar principal
gen     aux = ocupado
replace aux = 0			if  hogarsec==1
egen n_ocu_h=sum(aux),		by(id)
drop aux


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.10: Programas sociales  ----------------------------------------------------------
*************************************************************************************************************************************************)*/

* Plan asistencia social:	asistencia
* = 1 si el hogar recibe algun plan de asistencia social

/* PP07E:  recibe plan de empleo  
    V5_M:  monto del ingreso por SUBSIDIO O AYUDA SOCIAL (EN DINERO) DEL GOBIERNO, IGLESIAS, ETC.		*/
gen     aux_asistencia = 0
replace aux_asistencia = 1	if  pp07e==1
replace aux_asistencia = 1	if  v5_m>=150 & v5_m<=180
replace aux_asistencia = 1	if  v5_m>=500 & v5_m<=516
replace aux_asistencia = 1	if v5_m>=1000 & v5_m<=1040
replace aux_asistencia = 1	if v5_m>=1500 & v5_m<=1560
replace aux_asistencia = 1	if v5_m>=2000 & v5_m<=2060
replace aux_asistencia = 1	if v5_m>=2500 & v5_m<=2570
egen auxiliar = max(aux_asistencia), by(id)
/*
gen     aux_asistencia = 0
replace aux_asistencia = 1	if   v5_m>=500 & v5_m<=2600
replace aux_asistencia = 1	if  v5_m>=1000 & v5_m<=1032
replace aux_asistencia = 1	if  v5_m>=1500 & v5_m<=1560
replace aux_asistencia = 1	if  v5_m>=2000 & v5_m<=2100
replace aux_asistencia = 1	if  v5_m>=2500 & v5_m<=2600
replace aux_asistencia = 1	if   pp07e==1
egen auxiliar = max(aux_asistencia), by(id)
*/
gen     asistencia = 0
replace asistencia = 1		if  auxiliar==1
drop aux_asistencia auxiliar


/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------	1.11: Variables de ingresos  -------------------------------------------------------
*************************************************************************************************************************************************)*/	

********** A. INGRESOS LABORALES **********
	
****** A.1.OCUPACION PRINCIPAL ******

* VARIABLES ORIGINALES DE LA ENCUESTA
*    P21:  Monto de ingreso de la OCUPACIÓN PRINCIPAL 

* PP08D1:  Monto por sueldos/jornales, salario familiar, horas extras, otras bonificaciones
* PP08D4:  Monto en tickets percibido en ese mes						( INCLUIDOS en PP08D1 )
* PP08F1:  Monto en pesos por comisión por venta/producción percibido en ese mes
* PP08F2:  Monto en pesos por propinas percibido en ese mes
*    P21 = PP08D1 + PP08F1 + PP08F2

* PP08J1:  Monto por aguinaldo percibido en ese mes
* PP08J2:  Monto por otras bonificaciones no habituales percibido en ese mes
* PP08J3:  Monto por retroactivos percibido en ese mes
replace    p21 = .	if     p21==-9
replace pp08d1 = .	if  pp08d1==-9
replace pp08d4 = .	if  pp08d4==-9
replace pp08f1 = .	if  pp08f1==-9
replace pp08f2 = .	if  pp08f2==-9
replace pp08j1 = .	if  pp08j1==-9
replace pp08j2 = .	if  pp08j2==-9
replace pp08j3 = .	if  pp08j3==-9

replace pp08j1 = pp08j1/6

****   i)  ASALARIADOS
* Monetario	
egen  iasalp_m = rsum(p21 pp08j1)	if  relab==2
notes iasalp_m:  relab = 2: 797 zero incomes - 0 missing observations

* No monetario
gen   iasalp_nm = .
notes iasalp_nm: there is not information to define this variable


*****  ii)  CUENTA PROPIA
* Monetario	
gen   ictapp_m = p21			if  relab==3
notes ictapp_m:  relab = 3: 227 zero incomes - 0 missing observations

* No monetario
gen   ictapp_nm = .	  
notes ictapp_nm: there is not information to define this variable


***** iii)  PATRON
* Monetario	
gen   ipatrp_m = p21			if  relab==1
notes ipatrp_m:  relab = 1: 23 zero incomes - 0 missing observations

* No monetario
gen   ipatrp_nm = .	
notes ipatrp_nm: there is not information to define this variable


*****  vi)  OTROS NO ESPECIFICADOS (SIN RELACION LABORAL)
* Monetario	
gen   iolp_m = .

* No monetario
gen iolp_nm = .	


***** v)   EXTRAORDINARIOS
gen ila_extraord = .



****** A.2.OCUPACION NO PRINCIPAL ******

* VARIABLES ORIGINALES DE LA ENCUESTA
* P12_TOT: Monto de ingreso de OTRAS OCUPACIONES (no se puede identificar relación laboral en las mismas) 

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
gen   iolnp_m = tot_p12		if  tot_p12>0 & tot_p12<.  
notes iolnp_m: it is not possible to identify the labor relationship in other occupations
    
* No monetario
gen iolnp_nm = .		

	

********** B.INGRESOS NO LABORALES  ****
		
***** B.1. INGRESOS NO LABORALES POR FUENTE *****

****   i)  JUBILACIONES Y PENSIONES 
*  V2_M: Monto del ingreso por JUBILACION O PENSION  
* V21_M: Monto por AGUINALDO DE JUBILACION
replace  v2_m = .		if   v2_m==-9
replace v21_m = .		if  v21_m==-9

* Contributivas
gen  ijubi_con = .		

* No Contributivas
gen ijubi_ncon = .		

* No Identificables
replace   v21_m = v21_m/6

egen    ijubi_o = rsum(v2_m v21_m), missing
replace ijubi_o = .		if  ijubi_o==0
	
		
****  ii)  CAPITAL, INTERESES, ALQUILERES, RENTAS, BENEFICIOS, DIVIDENDOS 
*  V8_M: Monto del ingreso por ALQUILER (VIVIENDA , TERRENO, OFICINA, ETC.) DE SU PROPIEDAD.
*  V9_M: Monto del ingreso por GANANCIAS DE ALGUN NEGOCIO EN EL QUE NO TRABAJÓ.
* V10_M: Monto del ingreso por INTERESES O RENTAS POR PLAZOS FIJOS/INVERSIONES.
replace  v8_m = .		if   v8_m==-9
replace  v9_m = .		if   v9_m==-9
replace v10_m = .		if  v10_m==-9

egen    icap = rsum(v8_m v9_m v10_m), missing
replace icap = .		if  icap==0

	
**** iii)  PROGRAMAS DE ALIVIO A LA POBREZA y TRANSFERENCIAS ESTATALES

* CCT		
gen     icct = .		

* No CCT monetarias
*  V4_M:  Monto del ingreso por SEGURO DE DESEMPLEO (2 obs con 14,000 - 1 obs con 40,000)
* V11_M:  Monto del ingreso por BECA DE ESTUDIO
replace  v4_m = .		if   v4_m==-9
replace v11_m = .		if  v11_m==-9

egen    inocct_m = rsum(v4_m v11_m), missing
replace inocct_m = .		if  inocct_m==0

* No CCT no monetarias
gen     inocct_nm = .

* Ingreso por transferencias estatales no identificable en las categorias anteriores 
* V5_M: Monto del ingreso por SUBSIDIO O AYUDA SOCIAL (EN DINERO) DEL GOBIERNO, IGLESIAS, ETC.
replace  v5_m = .		if   v5_m==-9

gen     itrane_ns = v5_m
replace itrane_ns = .		if  itrane_ns==0
notes   itrane_ns: conditional cash transfers are included in this variable, but it cant be separated from other income concepts
	

**** iv)  TRANSFERENCIAS PRIVADAS 

* Del extranjero Monetario (remesas) 	 	
gen     itranext_m = .
	
* Del extanjero No Monetario
gen    itranext_nm = .

* Del interior Monetario 	
* V12_M: Monto del ingreso por CUOTAS DE ALIMENTOS O AYUDA EN DINERO DE PERSONAS QUE NO VIVEN EN EL HOGAR.
replace v12_m = .		if  v12_m==-9

egen    itranint_m = rsum(v12_m), missing 
replace itranint_m = .		if  itranint_m==0 
	
* Del interior No Monetario
gen itranint_nm = .

* No clasificable en las anteriores del punto iv
gen itranp_ns = .
		

****  v)  OTROS INGRESOS NO LABORALES
*  V18_M: Monto del ingreso por OTROS INGRESOS EN EFECTIVO (LIMOSNAS, JUEGOS DE AZAR, ETC.)---> INCLUYE EXTRAORDINARIOS
* V19_AM: Monto por trabajo de menores de 10 años
replace  v18_m = .		if   v18_m==-9
replace v19_am = .		if  v19_am==-9

replace v18_m = .		if  v18_m>14000

egen    inla_otro = rsum(v18_m v19_am), missing
replace inla_otro = .	if  inla_otro==0	

gen inla_extraord = .


/*(*********************************************************************************************************************************************** 
*------------------------------------------------------- 1.12: INGRESO OFICIAL -------------------------------------------------------------------
***********************************************************************************************************************************************)*/

* Linea de pobreza oficial ("linea de indigencia")
gen     lp_extrema = 2018.67	if  trimestre==3 & ano==2017 & region_eph==1
replace lp_extrema = 1801.53	if  trimestre==3 & ano==2017 & region_eph==42
replace lp_extrema = 1793.25	if  trimestre==3 & ano==2017 & region_eph==41	
replace lp_extrema = 1752.61	if  trimestre==3 & ano==2017 & region_eph==40	
replace lp_extrema = 2003.65	if  trimestre==3 & ano==2017 & region_eph==43 
replace lp_extrema = 2070.33	if  trimestre==3 & ano==2017 & region_eph==44

replace	lp_extrema = 2118.45	if  trimestre==4 & ano==2017 & region_eph==1
replace lp_extrema = 1893.92	if  trimestre==4 & ano==2017 & region_eph==42
replace lp_extrema = 1888.47	if  trimestre==4 & ano==2017 & region_eph==41	
replace lp_extrema = 1845.27	if  trimestre==4 & ano==2017 & region_eph==40	
replace lp_extrema = 2109.91	if  trimestre==4 & ano==2017 & region_eph==43 
replace lp_extrema = 2183.87	if  trimestre==4 & ano==2017 & region_eph==44

* Linea de pobreza oficial moderada ("linea de pobreza")
gen     lp_moderada = 4932.17	if  trimestre==3 & ano==2017 & region_eph==1
replace lp_moderada = 4689.87	if  trimestre==3 & ano==2017 & region_eph==42
replace lp_moderada = 4106.43	if  trimestre==3 & ano==2017 & region_eph==41 
replace lp_moderada = 3978.30	if  trimestre==3 & ano==2017 & region_eph==40
replace lp_moderada = 4895.47	if  trimestre==3 & ano==2017 & region_eph==43
replace lp_moderada = 5741.60	if  trimestre==3 & ano==2017 & region_eph==44

replace	lp_moderada = 5219.20	if  trimestre==4 & ano==2017 & region_eph==1
replace lp_moderada = 4975.42	if  trimestre==4 & ano==2017 & region_eph==42
replace lp_moderada = 4362.94	if  trimestre==4 & ano==2017 & region_eph==41 
replace lp_moderada = 4226.11	if  trimestre==4 & ano==2017 & region_eph==40
replace lp_moderada = 5198.14	if  trimestre==4 & ano==2017 & region_eph==43
replace lp_moderada = 6108.55	if  trimestre==4 & ano==2017 & region_eph==44

**** Ingreso Oficial
gen	ae = 1
replace ae = 0.28
replace ae = 0.35		if  edad<1 
replace ae = 0.37		if  edad==1
replace ae = 0.46		if  edad==2
replace ae = 0.51		if  edad==3
replace ae = 0.55		if  edad==4
replace ae = 0.60		if  edad==5
replace ae = 0.64		if  edad==6
replace ae = 0.66		if  edad==7
replace ae = 0.68		if  edad==8
replace ae = 0.69		if  edad==9

replace ae = 0.79		if  hombre==1 & edad==10 
replace ae = 0.82		if  hombre==1 & edad==11 
replace ae = 0.85		if  hombre==1 & edad==12 
replace ae = 0.90		if  hombre==1 & edad==13 
replace ae = 0.96		if  hombre==1 & edad==14 
replace ae = 1			if  hombre==1 & edad==15 
replace ae = 1.03		if  hombre==1 & edad==16 
replace ae = 1.04		if  hombre==1 & edad==17 

replace ae = 0.70		if  hombre==0 & edad==10 
replace ae = 0.72		if  hombre==0 & edad==11 
replace ae = 0.74		if  hombre==0 & edad==12 
replace ae = 0.76		if  hombre==0 & edad==13 
replace ae = 0.76		if  hombre==0 & edad==14 
replace ae = 0.77		if  hombre==0 & edad==15 
replace ae = 0.77		if  hombre==0 & edad==16 
replace ae = 0.77		if  hombre==0 & edad==17 
	
replace ae = 1.02		if  hombre==1 & edad>=18 & edad<=29
replace ae = 1			if  hombre==1 & edad>=30 & edad<=45
replace ae = 1			if  hombre==1 & edad>=46 & edad<=60
replace ae = 0.83		if  hombre==1 & edad>=61 & edad<=75
replace ae = 0.74		if  hombre==1 & edad>=76 & edad<110

replace ae = 0.76		if  hombre==0 & edad>=18 & edad<=29
replace ae = 0.77		if  hombre==0 & edad>=30 & edad<=45
replace ae = 0.76		if  hombre==0 & edad>=46 & edad<=60
replace ae = 0.67		if  hombre==0 & edad>=61 & edad<=75
replace ae = 0.63		if  hombre==0 & edad>=76 & edad<110
egen   aef = sum(ae), by(id) 

ren  itf   itf_indec
ren  ipcf ipcf_indec

gen ing_pob_ext = itf_indec/aef
gen ing_pob_mod = itf_indec/aef
gen ing_pob_mod_lp = ing_pob_mod / lp_moderada

drop ae aef


/*(************************************************************************************************************************************************ 
			1.13: PRECIOS 
************************************************************************************************************************************************)*/

* Mes en el que están expresados los ingresos de cada observación
gen mes_ingreso = .
 
* IPC del mes base
gen ipc = 623.018086751302121	/*  MES BASE: promedio Julio-Diciembre	*/

gen cpiperiod = "2017m07-2017m12"
 
* Factor de ajuste para cada observación
gen     ipc_rel = 1.000
replace ipc_rel = 0.975		if  trimestre==1
replace ipc_rel = 1.025		if  trimestre==2
	
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
quietly include "`do_file_aspire'"
quietly include "`do_file_1_variables'"
quietly include "`do_file_renta_implicita'"
quietly include "`do_file_2_variables'"
quietly include "`do_file_label'"
compress

cap drop pondera_i
gen pondera_i = pondih

/*==================================================================================================================================================
								3: Resultados
==================================================================================================================================================*/

/*(************************************************************************************************************************************************* 
*-------------------------------------------------------------- 3.1 Ordena y Mantiene las Variables a Documentar Base de Datos CEDLAS --------------
*************************************************************************************************************************************************)*/

* Chequear dummies de regiones
order pais ano encuesta id com pondera pondera_eph strata psu relacion relacion_est hombre edad gedad1 jefe conyuge hijo nro_hijos hogarsec hogar presec miembros casado soltero estado_civil raza raza_est lengua lengua_est region_est1 region_est2 region_est3 urbano gba pampa cuyo noa nea pata nuevareg migrante migra_ext migra_rur anios_residencia migra_rec propieta habita dormi precaria matpreca agua banio cloacas elect telef heladera lavarropas aire calefaccion_fija telefono_fijo celular celular_ind televisor tv_cable video computadora internet_casa uso_internet auto ant_auto auto_nuevo moto bici alfabeto asiste edu_pub aedu nivel nivedu prii pric seci secc supi supc exp seguro_salud tipo_seguro enfermo visita ocupado desocupa pea edad_min durades hstrp hstrs hstrt deseo_emp antigue relab relab_s relab_o empresa sector1d sector tarea contrato ocuperma djubila dsegsale daguinaldo dvacaciones sindicato prog_empleo n_ocu_h asal grupo_lab categ_lab asistencia iasalp_m iasalp_nm ictapp_m ictapp_nm ipatrp_m ipatrp_nm iolp_m iolp_nm iasalnp_m iasalnp_nm ictapnp_m ictapnp_nm ipatrnp_m ipatrnp_nm iolnp_m iolnp_nm ijubi_con ijubi_ncon ijubi_o icap icct inocct_m inocct_nm itrane_ns itranext_m itranext_nm itranint_m itranint_nm itranp_ns inla_otro ipatrp iasalp ictapp iolp ip ip_m wage wage_m ipatrnp iasalnp ictapnp iolnp inp ipatr ipatr_m iasal iasal_m ictap ictap_m ila ila_m ilaho ilaho_m perila ijubi itranp itranp_m itrane itrane_m itran itran_m inla inla_m ii ii_m perii n_perila_h n_perii_h ilf_m ilf inlaf_m inlaf itf_m itf_sin_ri renta_imp itf cohi cohh coh_oficial ilpc_m ilpc inlpc_m inlpc ipcf_sr ipcf_m ipcf iea ilea_m ieb iec ied iee lp_extrema lp_moderada ing_pob_ext ing_pob_mod ing_pob_mod_lp p_reg ipc pipcf dipcf p_ing_ofi d_ing_ofi piea qiea pondera_i ipc05 ipc11 ppp05 ppp11_new ppp11_orig ipcf_cpi05 ipcf_cpi11 ipcf_ppp05 ipcf_ppp11  

save "`base_out_nesstar_cedlas'", replace
