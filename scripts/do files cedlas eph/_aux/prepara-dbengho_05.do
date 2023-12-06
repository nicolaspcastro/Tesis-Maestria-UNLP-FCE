clear all
local base_raw  "${rootdatalib}\_git_sedlac-03\ARG\_aux\ENGHo\2005"
local bases     "`base_raw'\dta"
set seed 357
loc Q = 10 

******* Gasto en alquiler
insheet using "`base_raw'\ENGH0405_gastos.txt", clear delimiter(|)

* 311101: Alquiler de la vivienda de uso permanente?
gen      arriendo = monto	if  articulo==311101
drop if  arriendo==.
destring arriendo, dpcomma replace
keep   clave region subregion provincia arriendo articulo expan
sort   clave
save "`bases'\ENGHo_alquileres.dta", replace

******* Personas
insheet using "`base_raw'\ENGH0405_personas.txt", clear delimiter(|)

* Caracteristicas de los individuos
gen	hombre = 1		if  cp12==1
replace hombre = 0		if  cp12==2
	
gen	jefe = 1		if  cp03==1
replace jefe = 0		if  cp03>=2 & cp03<=9

gen	conyuge = 0		if  cp03>=1 & cp03<=9
replace conyuge = 1		if  cp03==2 

gen	hogarsec = 0
replace hogarsec = 1		if  cp03==10

*  Maxima educación del hogar
/* Nivel de instrucción
	01 – Sin instrucción		02 – Preescolar
	03 – Primario incompleto	04 – Primario Completo
	05 – Secundario incompleto	06 – Secundario completo
	07 – Superior incompleto	08 – Superior completo
	09 – Universitario incompleto	10 – Universitario completo
	99 – Ns/Nr

CP15: ¿Asiste o asistió a algún establecimiento educativo?
	1 – Asiste a un establecimiento estatal
	2 – Asiste a un establecimiento privado
	3 – No asiste pero asistió
	4 – Nunca asistió
	9 – Ns/Nr
 
CP16: ¿Cuál es el nivel más alto que cursa o cursó?
	01 – Jardín			02 – Preescolar
	03 - EGB			04 – Primario
	05 - Polimodal			06 – Secundario
	07 – Superior no universitario	08 - Universitario
	09 - Posgrado universitario	98 – Educación especial
	99 - Ns/Nr
 
CP17: ¿Finalizó ese nivel? 

CP18: ¿Cuál fue el último grado o año que aprobó?  
	00 - Ninguno			01 - Primero
	02 - Segundo			03 - Tercero
	04 - Cuarto			05 - Quinto
	06 - Sexto			07 - Séptimo
	08 - Octavo			09 - Noveno
	98 - Especial			99 - Ns/Nr				*/
gen	aedu = 0	if  cp15==4 | cp16==1 | cp16==2
replace aedu = cp18	if  cp16==4 & cp17==2 
replace aedu = 3	if  cp16==4 & cp17==2 & cp18==99
replace aedu = 7	if  cp16==4 & cp17==1
replace aedu = cp18	if  cp16==3 & cp17==2 
replace aedu = 3	if  cp16==3 & cp17==2 & cp18==99	
replace aedu = 9	if  cp16==3 & cp17==1
replace aedu = 7+cp18	if  cp16==6 & cp17==2 
replace aedu = 9	if  cp16==6 & cp17==2 & cp18==99
replace aedu = 12	if  cp16==6 & cp17==1 
replace aedu = 9+cp18	if  cp16==5 & cp17==2 
replace aedu = 10	if  cp16==5 & cp17==2 & cp18==99   
replace aedu = 12	if  cp16==5 & cp17==2 & cp18>=3 & cp18<=4
replace aedu = 12	if  cp16==5 & cp17==1 
replace aedu = 12+cp18	if  cp16==7 & cp17==2 
replace aedu = 14	if  cp16==7 & cp17==2 & cp18==99
replace aedu = 15	if  cp16==7 & cp17==2 & cp18>=3 & cp18<=9
replace aedu = 15	if  cp16==7 & cp17==1 
replace aedu = 12+cp18	if  cp16==8 & cp17==2  
replace aedu = 14	if  cp16==8 & cp17==2 & (cp18==98 | cp18==99)
replace aedu = 17	if  cp16==8 & cp17==2 & cp18>=5  & cp18<=9
replace aedu = 17	if  cp16==8 & cp17==1 
replace aedu = 17+cp18	if  cp16==9 & cp17==2 
replace aedu = 18	if  cp16==9 & cp17==2 & (cp18==98 | cp18==99)
replace aedu = 20	if  cp16==9 & cp17==2 & cp18>=3  & cp18<=5
replace aedu = 19	if  cp16==9 & cp17==1 

* Maximo nivel educativo del hogar
egen    maxedu = max(aedu), by(clave)

* Edad del jefe de hogar
gen  aux = cp02			if  cp03==1
bysort clave: egen jedad= total(aux)
drop aux

* Cantidad de miembros en el hogar
 bysort clave: egen miembros = count(miembro) if cp03!=.


** Tipos de hogar
replace jefe = 0		if  jefe==.
replace conyuge = 0		if  conyuge==.

egen hog_jefe = max(jefe),	by(clave)
egen hog_cony = max(cony),	by(clave)

gen numero_jefes_con = (hog_jefe + hog_cony)

* Individuos viviendo en hogares completos
gen	tipo_hogar = 1		if  numero_jefes_con==2 
replace tipo_hogar = 2		if  numero_jefes_con==1 & miembros>1 
replace tipo_hogar = 3		if  miembros==1 

* Jefe ocupado
gen     aux_ocu = 0		if  jefe==1			
replace aux_ocu = 1		if  jefe==1 & condact==1
egen jefe_ocu = max(aux_ocu), by(clave)
drop aux_ocu

* Jefe hombre
gen	aux = 1			if  jefe==1 & cp12==1
replace aux = 0			if  jefe==1 & cp12==2
egen jhombre = max(aux), by(clave)
drop aux
save "`bases'\ENGHo_Personas.dta", replace


****** Hogares
insheet using "`base_raw'\ENGH0405_hogar.txt", clear delimiter(|)

/* CH08  El sistema de aprovisionamiento del agua que usan en el hogar es... 
		1 - por cañería dentro de la vivienda? 
		2 - fuera de la vivienda pero dentro del terreno? 
		3 - fuera del terreno?								

 CH09  La procedencia del agua es de:
		1 - red pública? 
		2 - perforación con bomba a motor? 
		3 - perforación con bomba manual? 
		4 - pozo? 
		5 - Otros									*/
gen	agua = 1		if (ch08>=1 & ch08<=2) & ch09==1
replace agua = 0		if  ch08==3 | (ch09>=2 & ch09<=5)

/* CH10  Tienen baño equipado con inodoro con arrastre de agua instalado? 
   CH11  El baño es de:
		1 - uso exclusivo del hogar
		2 - uso compartido con otros hogares
		3 - uso compartido con otras viviendas						*/
gen	banio = 0		if  ch10==2
replace banio = 1		if  ch10==1

/* CH13  El desague del inodoro, ¿es… 
		1 - a red pública? (cloaca) 
		2 - a cámara séptica y pozo ciego? 
		3 - sólo a pozo ciego? 
		4 - otros
		9 - Ns Nr?									*/								
gen	cloacas = 1		if  ch13==1           & banio==1	
replace cloacas = 0		if  ch13>=2 & ch13<=9 & banio==1
replace cloacas = 0		if  banio==0

/* CV07 ¿Dispone de cochera?
		1 - Sí, de uso común
		2 - Sí, de uso exclusivo
		3 - No										*/
gen	cochera = 1		if  cv07==1 | cv07==2
replace cochera = 0		if  cv07==3

*  CH04 ¿Cuántas habitaciones tiene la vivienda?)
gen	habita = ch04
replace habita = habita + 1	if  ch16==1
replace habita = habita + 1	if  banio==1

*  CH05  De esas, ¿cuántas habitaciones o piezas de uso exclusivo tiene este hogar? 
gen	 dormi = ch05

/* CH16 ¿Tienen ustedes cuarto de cocina
		1 – de uso exclusivo del hogar?
		2 – de uso compartido con otro hogar?
		3 – no tiene?
IMPORTANTE: no es la misma pero es similar							*/
gen	cocina = 1		if  ch16==1 | ch16==2 
replace cocina = 0		if  ch16==3

/* CH17  Para cocinar ¿utilizan principalmente… 
		1 – gas de red			2 – gas envasado en tubo
		3 – gas envasado en garrafa	4 – kerosene	
		5 – electricidad		6 – leña o carbón		
		7 – gas-oil			8 – otro */
gen	gas2 = 1			if  ch17==1
replace gas2 = 0			if  ch17>1 & ch17<=8

sort clave
save "`bases'\ENGHo_Hogares.dta", replace


* Base personas
use "`bases'\ENGHo_Personas.dta", clear
sort  clave
merge clave using "`bases'\ENGHo_Hogares.dta", _merge(_hog)
tab  _hog
sort  clave
merge clave using "`bases'\ENGHo_alquileres.dta", _merge(_alquileres)
tab  _alquileres

* Genero variables para Estadisticas 
/* CH01: ¿Algún miembro del hogar es...
		1 - propietario de la vivienda y el terreno?
		2 - propietario de la vivienda solamente?
		3 - inquilino o arrendatario de la vivienda?
		4 - ocupante por relación de trabajo?
		5 - ocupante por préstamo, cesión o permiso?
		6 - ocupante de hecho (sin permiso)?
		7 - alguna otra situación (especificar)			*/
gen	propieta = 1			if  ch01==1 | ch01==2 
replace propieta = 0			if  ch01>=3 & ch01<=7
replace propieta = .			if  jefe~=1

* Dummies por region y tipo de hogar
tab region,     gen(region_)
tab tipo_hogar, gen(tipo_hogar_)

keep  if  jefe==1
keep  if  ncntddhgrs==1
keep  if  tipoarea=="U"
replace arriendo = .			if  propieta==1

gen       itf = ingtoth
gen      ipcf = itf/miembros
destring ipcf itf, dpcomma replace


**************  Ajuste Precios  **************
/* La ENGH 2004-2005 se realizó entre 10/2004 y 12/2005
   Los indices se sacaron de PL_cedlas_2015 
   La base es el promedio del segundo semestre de 2005			*/
gen	ipc_rel = 0.913		if  trimestre==4 & anio==4
replace ipc_rel = 0.934		if  trimestre==1 & anio==5
replace ipc_rel = 0.964		if  trimestre==2 & anio==5
replace ipc_rel = 0.986		if  trimestre==3 & anio==5
replace ipc_rel = 1.014		if  trimestre==4 & anio==5

* Ajusta las variables de ingreso relevantes para el paso de coeficientes hacia la eph (arriendo)
local varmonetarias "arriendo ipcf itf"
foreach var of local varmonetarias	{
					replace `var' = `var'/ipc_rel 
					}

gen lp_1usd = 52.2823
****** Ajuste a moneda constante PPP 2005
replace arriendo = (arriendo/lp_1usd)*30.42*1.25
gen    larriendo = ln(arriendo)

* Cuantiles del ipcf_sin_ri
quantiles ipcf [w = expan], n(`Q') gen(d_ipcf)

keep decinpch_t expan arriendo larriendo agua cloacas habita dormi banio gas2 cochera region* provincia cocina articulo ipcf itf maxedu jedad tipo_hogar* jefe_ocu jhombre miembros propieta ch14 clave hogarsec d_ipcf  

* Renombramos para homogeneizar encuestas
rename expan    pondera
rename clave    id

compress
save  "`bases'\base_ENGHo_2005.dta", replace
erase "`bases'\ENGHo_alquileres.dta"
erase "`bases'\ENGHo_Hogares.dta"
erase "`bases'\ENGHo_Personas.dta"
