clear all
local base_raw  "${rootdatalib}\_git_sedlac-03\ARG\_aux\ENGHo\2012"
local bases     "`base_raw'\dta"
set seed 357
loc Q = 10 

******* Gasto en alquiler
insheet using "`base_raw'\ENGHo - Gastos.txt", clear delimiter(|)

* 311101: Alquiler de la vivienda de uso permanente?
gen      arriendo = monto	if  articulo==311101
drop if  arriendo=="."
destring arriendo, dpcomma replace
keep   clave region subregion provincia arriendo articulo expan
sort   clave
save "`bases'\ENGHo_alquileres.dta", replace

******* Personas
insheet using "`base_raw'\ENGHo - Personas.txt", clear delimiter(|)

* Caracteristicas de los individuos
gen	hombre = 1		if  cp12==1
replace hombre = 0		if  cp12==2

gen	jefe = 1		if  cp03==1
replace jefe = 0		if  cp03>=2 & cp03<=9

gen	conyuge = 0		if  cp03>=1 & cp03<=9
replace conyuge = 1		if  cp03==2 

gen	hogarsec = 0
replace hogarsec = 1		if  cp03==10


* Maxima educación del hogar
/* Nivel de instrucción
	01 – Sin instrucción		02 – Preescolar
	03 – Primario incompleto	04 – Primario Completo
	05 – Secundario incompleto	06 – Secundario completo
	07 – Superior incompleto	08 – Superior completo
	09 – Universitario incompleto	10 – Universitario completo

cp15: ¿Asiste o asistió a algún establecimiento educativo?
	1 – Asiste a un establecimiento estatal
	2 – Asiste a un establecimiento privado
	3 – No asiste pero asistió
	4 – Nunca asistió
 
cp16: ¿Cuál es el nivel más alto que cursa o cursó?
	01 – Jardín 			02 – Preescolar
	03 - EGB			04 – Primario
	05 - Polimodal			06 – Secundario
	07 – Superior no universitario
	08 - Universitario		09 - Posgrado universitario
	98 – Educación especial		
 
cp17: ¿Finalizó ese nivel? 

cp18: ¿Cuál fue el último grado o año que aprobó?  
	00 - Ninguno			01 - Primero
	02 - Segundo			03 - Tercero
	04 - Cuarto			05 - Quinto
	06 - Sexto			07 - Séptimo
	08 - Octavo			09 - Noveno	
	98 - Especial						*/
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
replace aedu = 15	if  cp16==7 & cp17==2 & cp18>=3 & cp18<=7
replace aedu = 15	if  cp16==7 & cp17==1 
replace aedu = 12+cp18	if  cp16==8 & cp17==2 
replace aedu = 14	if  cp16==8 & cp17==2 & cp18==99
replace aedu = 17	if  cp16==8 & cp17==2 & cp18>=5 & cp18<=8
replace aedu = 17	if  cp16==8 & cp17==1 
replace aedu = 17+cp18	if  cp16==9 & cp17==2 
replace aedu = 18	if  cp16==9 & cp17==2 & cp18==99
replace aedu = 20	if  cp16==9 & cp17==2 & cp18>=3 & cp18<=5
replace aedu = 19	if  cp16==9 & cp17==1 

* Maximo nivel educativo del hogar
egen    maxedu = max(aedu), by(clave)

* Edad del jefe de hogar
gen  aux = cp02			if  cp03==1
bysort clave: egen jedad= total(aux)
drop aux

* Cantidad de miembros en el hogar
bysort clave: egen miembros= count(miembro) if cp03!=.


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
replace aux_ocu = 1		if  jefe==1 & condocup==1
egen jefe_ocu = max(aux_ocu), by(clave)
drop aux_ocu

* Jefe hombre
gen	aux = 1			if  jefe==1 & cp12==1
replace aux = 0			if  jefe==1 & cp12==2
egen jhombre = max(aux), by(clave)
drop aux
save "`bases'\ENGHo_Personas.dta", replace


****** Hogares
insheet using "`base_raw'\ENGHo - Hogares.txt", clear delimiter(|)

/* CV1B07  El sistema de aprovisionamiento del agua que usan en el hogar es... 
		1 - por cañería dentro de la vivienda? 
		2 - fuera de la vivienda pero dentro del terreno? 
		3 - fuera del terreno?									

 CV1B08   La procedencia del agua es de:
		1 - red pública? 
		2 - perforación con bomba a motor? 
		3 - perforación con bomba manual? 
		4 - pozo? 
		5 - transporte por cisterna? 
		6 - agua de lluvia, río, canal, arroyo o acequia?					*/
gen	agua = 1	if  cv1b07>=1 &  cv1b07<=2 & cv1b08==1
replace agua = 0	if  cv1b07==3 | (cv1b08>=2 & cv1b08<=6)

* Baño higienico
/* CV1B09  Esta vivienda ¿Tiene baño/letrina? 
   CV1B10 ¿El baño tiene:  
		1 - inodoro con botón/mochila/cadena y arrastre de agua? 
		2 - inodoro sin botón/mochila/cadena y arrastre de agua? (a balde) 
		3 - letrina? (sin arrastre de agua)							*/
gen	banio = 0	if  cv1b09==2
replace banio = 0	if  cv1b10==2 | cv1b10==3
replace banio = 1	if  cv1b10==1

/* CV1B11  El desague del inodoro, ¿es: 
		1 - a red pública? (cloaca) 
		2 - a cámara séptica y pozo ciego? 
		3 - sólo a pozo ciego? 
		4 - a hoyo, excavación en la tierra, etc.?						*/
gen	cloacas = 1	if  cv1b11==1 & banio==1
replace cloacas = 0	if  cv1b11>=2 & cv1b11<=4 & banio==1
replace cloacas = 0	if  banio==0

/* CH01_A  Dispone de cochera?
		1 - Sí, de uso común
		2 - Sí, de uso exclusivo
		3 - No											*/
gen	cochera = 1	if  ch01_a==1 | ch01_a==2
replace cochera = 0	if  ch01_a==3

* CH04  En total, ¿cuántas habitaciones o piezas de uso exclusivo tiene este hogar? (sin contar baño/s y cocina/s)
gen     habita = ch04
replace habita = habita + 1	if  ch08==1
replace habita = habita + 1	if  banio==1

* CH05  De esas, ¿cuántas habitaciones o piezas de uso exclusivo tiene este hogar? 
gen dormi = ch05

/* CH08  Este hogar, ¿tiene… 
		1 - cuarto de cocina con instalación de agua? 
		2 - cuarto de cocina sin instalación de agua? 
		3 - no tiene cuarto de cocina							*/
gen	cocina = 1		if  ch08==1 | ch08==2 
replace cocina = 0		if  ch08==3
label var cocina "1= si tiene cocina"

/* CH09  Para cocinar ¿utilizan principalmente… 
		1 - gas de red? 
		2 - gas a granel (zeppelin)? 
		3 - gas a tubo? 
		4 - gas en garrafa? 
		5 - electricidad? 
		6 - leña o carbón? 
		7 - otro (especificar)								*/
gen	gas2 = 1			if  ch09==1
replace gas2 = 0			if  ch09>=2 & ch09<=7

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
/* CH14  ¿Algún miembro del hogar es...
		1 - propietario de la vivienda y el terreno?
		2 - propietario de la vivienda solamente?
		3 - inquilino o arrendatario de la vivienda?
		4 - ocupante por relación de trabajo?
		5 - ocupante por préstamo, cesión o permiso?
		6 - ocupante de hecho (sin permiso)?
		7 - alguna otra situación (especificar)				*/
gen	propieta = 1		if  ch14==1 | ch14==2 
replace propieta = 0		if  ch14>=3 & ch14<=7
replace propieta = .		if  jefe~=1

* Dummies por region y tipo de hogar
tab region,     gen(region_)
tab tipo_hogar, gen(tipo_hogar_)

keep  if  jefe==1
keep  if  hogarsec!=1
replace arriendo = .		if  propieta==1
keep  if  cv1a01==2

gen ipcf = ingpch
gen itf  = ingtoth
destring ipcf itf, dpcomma replace

**************  Ajuste Precios  **************
/* La ENGH 2012/13 se realizó entre 03/2012 y 03/2013
   Los indices ipc_real se sacaron de PL_cedlas_2015
   La base es el promedio del segundo semestre de 2012				*/
gen	ipc_rel = 0.918		if  trimestre==2
replace ipc_rel = 0.972		if  trimestre==3 
replace ipc_rel = 1.028		if  trimestre==4 
replace ipc_rel = 1.103		if  trimestre==1 


* Ajusta las variables de ingreso relevantes para el paso de coeficientes hacia la eph (arriendo)
local varmonetarias "arriendo ipcf itf"
foreach var of local varmonetarias	{
					replace `var' = `var'/ipc_rel 
					}
gen lp_1usd = 189.9399
****** Ajuste a moneda constante PPP 2005
replace arriendo = (arriendo/lp_1usd)*30.42*1.25
gen    larriendo = ln(arriendo)

* Cuantiles del ipcf_sin_ri
quantiles ipcf [w = expan], n(`Q') gen(d_ipcf)

keep decippht expan arriendo larriendo agua cloacas habita dormi banio gas2 cochera region* provincia cocina articulo ipcf itf maxedu jedad tipo_hogar* jefe_ocu jhombre miembros propieta ch14 clave jefe hogarsec d_ipcf

* Renombramos para homogeneizar encuestas
rename expan pondera
rename clave id

compress
save "`bases'\base_ENGHo_2012.dta", replace
erase "`bases'\ENGHo_alquileres.dta"
erase "`bases'\ENGHo_Hogares.dta"
erase "`bases'\ENGHo_Personas.dta"
