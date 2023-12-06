
preserve
*include "${rootdatalib}\_git_sedlac-03\ARG\_aux\prepara-dbengho_05.do"
*include "${rootdatalib}\_git_sedlac-03\ARG\_aux\prepara-dbengho_12.do"

set seed 357
local Q = 10 
local years "2005 2012"
foreach year of local years	{
				if `year'==2005  use "${rootdatalib}\_git_sedlac-03\ARG\_aux\ENGHo\2005\dta\base_ENGHo_2005.dta", clear
				if `year'==2012  use "${rootdatalib}\_git_sedlac-03\ARG\_aux\ENGHo\2012\dta\base_ENGHo_2012.dta", clear
	
				capture keep if cohh==1 
	
*                               REGRESIONES
				local hogar     "miembros jedad maxedu jefe_ocu jhombre tipo_hogar_2 tipo_hogar_3"	/* porque no ingresos? */
				local vivienda  "agua cloacas cochera habita dormi cocina gas2 banio"
				local region    "region_2 region_3 region_4 region_5 region_6"
				
  				forvalues i = 1(1)`Q'	{
							local tau = `i'/(`Q'+1)
							qreg larriendo `hogar' `vivienda' `region'	if  propieta==0, q(`tau')
							mat  beta_q`i' = e(b)

*							Junto todas las matrices en una	
							if `i'==1	  mat beta`year' = beta_q`i'   
							else mat beta`year' = beta`year' \ beta_q`i'  
							mat drop beta_q`i'
							}	

*				Para sacar el "o." de los nombres de las vars omitidas 
				local names: colfullnames beta`year' 
				foreach name of local names	{
								if substr("`name'",1,2)!="o." local names`year' "`names`year'' `name'" 
								if substr("`name'",1,2)=="o."	{
												local auxname = substr("`name'",3,800)
												local names`year' "`names`year'' `auxname'" 
												}
								}
				di "`names`year''"
	
				mat colnames beta`year' = `names`year''
				
				drop _all
	
*				Para reemplazar _cons por cons
				local col = colsof(beta`year')
				matname beta`year' cons, columns(`col') explicit
				svmat beta`year', names(col)
		
				save "${rootdatalib}\_git_sedlac-03\ARG\_aux\beta`year'.dta", replace
				}	
restore

*********************************************************************************************************************************************************************
*********************************************************************************************************************************************************************
/* II7: Régimen de tenencia 
	01 = Propietario de la vivienda y el terreno	02 = Propietario de la vivienda solamente
	03 = Inquilino/arrendatario de la vivienda	04 = Ocupante por pago de impuestos/expensas
	05 = Ocupante en relación de dependencia	06 = Ocupante gratuito (con permiso)
	07 = Ocupante de hecho (sin permiso		08 = Esta en sucesión?
	09 = Otra situación (especificar)								*/
capture drop aux_propieta
gen     aux_propieta = 0
replace aux_propieta = 1		if  ii7==1 | ii7==2 | ii7==4 | ii7==5 | ii7==6 | ii7==7 | ii8==8

* Edad del jefe
gen aux = edad				if  relacion==1
bysort id: egen jedad= total(aux)
drop aux

* Jefe hombre
gen	jhombre = 1			if  relacion==1 & hombre==1
replace jhombre = 0			if  relacion==1 & hombre==0

** Tipos de hogar
replace    jefe = 0			if     relacion==.
replace conyuge = 0			if  conyuge==.
gen  aux = jefe + conyuge 
egen numero_jefes_con = sum(aux),	by(id)
drop aux 

gen	tipo_hogar = 1			if  numero_jefes_con>=2 & numero_jefes_con<=5
replace tipo_hogar = 2			if  numero_jefes_con==1 & miembros>1 
replace tipo_hogar = 3			if  miembros==1 

* Jefe Ocupado
gen     aux_ocu = 0		if  relacion==1			
replace aux_ocu = 1		if  relacion==1 & ocupado==1
egen jefe_ocu = max(aux_ocu), by(id)
drop aux_ocu

* LP
local ipc05 = 42.5805
local ppp05 =   1.353
gen lp_1usd = 1.25*30.42*`ppp05'*(ipc/`ipc05') 

* Dummies por tipo de hogar
tab tipo_hogar, gen(tipo_hogar_)

* Maximo nivel educativo del hogar
egen    maxedu = max(aedu), by(id)
replace maxedu = 0	if  maxedu==.

* Dummies por region
tab region_est1, gen(region_)

* Genero deciles de ipcf sin renta implicita
gen    ipcf_sin_ri = itf_sin_ri/miembros
gsort -ipcf_sin_ri

* Genera deciles del ipcf
quantiles ipcf_sin_ri [w=pondera], n(10) gen(d_ipcf)

* Variables al cuadrado
gen  habita2 = habita^2
gen   dormi2 =  dormi^2
gen   jedad2 =  jedad^2

* Cocina
* II4_1: Cuarto de cocina?
gen	cocina = 1		if  ii4_1==1
replace cocina = 0		if  ii4_1==2
replace cocina = 0		if  cocina==. & relacion==1
replace cocina = .		if  relacion!=1

* II4_3 Tiene garage?
gen	cochera = 1		if  ii4_3==1
replace cochera = 0		if  ii4_3==2
replace cochera = 0		if  cochera==. & relacion==1
replace cochera = .		if  relacion!=1

/* II8 Combustible utilizado para cocinar...
		0. No aplica			1. Gas de red
		2. Gas de tubo/garrafa		3. Kerosene/leÃ±a/carbon
		4. Otro				5. Ns/Nr			*/
gen	gas2 = 1			if  ii8==1
replace gas2 = 0			if  ii8>1 & ii8<=5
replace gas2 = 0			if  gas2==. & relacion==1
replace gas2 = .			if  relacion!=1

gen     tag_clo = 1		if  relacion==1 & cloacas==.
replace cloacas = 0		if  relacion==1 & tag_clo==1
gen     tag_ban = 1		if  relacion==1 & banio==.
replace   banio = 0		if  relacion==1 & tag_ban==1
gen     tag_agu = 1		if  relacion==1 & agua==.
replace    agua = 0		if  relacion==1 & tag_agu==1

*********************************************************************************************************************************************************************
*********************************************************************************************************************************************************************
local     ano = ano
local ano_ini = 2005
local ano_fin = 2012
local   rango = 7

local years "`ano_ini' `ano_fin'"

* Abro los beta.dta y los transformo en matrices
foreach year of local years	{	
				preserve
				use "${rootdatalib}\_git_sedlac-03\ARG\_aux\beta`year'.dta", clear

*				Transformo base en matriz
				mkmat _all, matrix(beta`year')	
	
*				Ahora renombro cons por _cons para poder matchear coeficientes
				local col = colsof(beta`year')
				matname beta`year' _cons, columns(`col') explicit	
	
*				Repito lo anterior para generar vectores fila por decil
				forvalues i = 1(1)10	{
							mkmat _all if _n==`i', matrix(beta`year'_`i')
							local col = colsof(beta`year'_`i')
							matname beta`year'_`i' _cons, columns(`col') explicit
							}
				restore 
				
				forvalues i = 1(1)10	{
							if `i'==1 mat score larriendo_qr_`year' = beta`year'_`i'   if  aux_propieta==1 & d_ipcf==`i'
							if `i'!=1 mat score larriendo_qr_`year' = beta`year'_`i'   if  aux_propieta==1 & d_ipcf==`i', replace
							}
				}

		
* Aplica exponencial a las distintas variables y expresa en valores corrientes
gen	renta`ano'_`ano_ini'    = exp(larriendo_qr_`ano_ini')				if  aux_propieta==1
replace renta`ano'_`ano_ini'   = (renta`ano'_`ano_ini'*lp_1usd)/(30.42*1.25)		if  aux_propieta==1
	
gen	renta`ano'_`ano_fin'   = exp(larriendo_qr_`ano_fin')				if  aux_propieta==1
replace renta`ano'_`ano_fin'   = (renta`ano'_`ano_fin'*lp_1usd)/(30.42*1.25)		if  aux_propieta==1
	

**************************************************************************************************************************************************************************
**************************************************************************************************************************************************************************
**** Interpolacion. Ponderar segun distancia
if `ano_ini'<=`ano' & `ano'<=`ano_fin'	{
*		 			Alpha es el ponderador del año inicial (si mi año esta mas cerca del inicial, alpha sera mas alto, y visceversa)
					local alpha = (`ano_fin' - `ano' ) / `rango'
					di in ye "ponderador de `ano' con respecto a `ano_ini' = `alpha' "

*					Genera la renta final de cada aÃ±o como un promedio ponderado de rentas 
					gen aux_renta_imp = `alpha' * renta`ano'_`ano_ini' + (1-`alpha') * renta`ano'_`ano_fin'
					}
	
**** Extrapolacion   
else					{
					if  `ano'<`ano_ini'	loc beta = 1 
					if  `ano'>`ano_fin'	loc beta = 0	
					di in ye " ponderador de `ano' con respecto a `ano_ini' = `beta'"
		
					gen aux_renta_imp = `beta' * renta`ano'_`ano_ini' + (1-`beta') * renta`ano'_`ano_fin'	
					}
***************************************************************************************************************************************************************************
***************************************************************************************************************************************************************************
egen    renta_imp = max(aux_renta_imp), by(id)
replace renta_imp = .				if  aux_prop!=1 | hogarsec==1 
replace renta_imp = renta_imp / p_reg 
replace renta_imp = renta_imp / ipc_rel 

replace cloacas = .		if  relacion==1 & tag_clo==1
replace   banio = .		if  relacion==1 & tag_ban==1
replace    agua = .		if  relacion==1 & tag_agu==1

drop  jedad-aux_renta_imp	
