clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "2015"  // Year of the survey
local survey   "EPHC"  // Survey acronym
local vm       "03"    // Master version
local va       ""      // Alternative version
local project  "03"    // Project version
local period   "-S1"   // Periodo, ejemplo -S1 -S2
local alterna  ""      // 

include "${rootdatalib}/_git_sedlac-03/_aux/sedlac_hardcode.do"

local base_in   "`folder_nesstar_stata'"
local base_out  "`base_out_nesstar_base'"

/*********************************************************************

SOCIO-ECONOMIC DATABASE FOR LATIN AMERICA AND THE CARIBBEAN (SEDLAC) 
CEDLAS/UNLP y THE WORLD BANK 

Crea base de Argentina 2015 (EPHC - Semestre I)

Autor: CEDLAS/UNLP  
cedlas@depeco.econo.unlp.edu.ar

Actualizado: Julio de 2019

**********************************************************************/

cd "`base_in'"

*******************************************************************************
******** Une bases de los dos trimestres 
*******************************************************************************
use          "Trimestre_1"
append using "Trimestre_2.dta"
duplicates report
duplicates drop

summ     ch04 [w=pondera]	if  trimestre==1
scalar   p_trimestre_a = r(sum_w)

summ     ch04 [w=pondera]	if  trimestre==2
scalar   p_trimestre_b = r(sum_w)

scalar   p_trimestre = (p_trimestre_a + p_trimestre_b) / 2

gen pondera3 = pondera
* Divide por dos los ponderadores de las observaciones duplicadas en los dos trimestres
*** PROBLEMA DO ANTERIOR:  no identifica cuando falta componente==1 en un hogar
***			   sobreidentifica cuando un hogar está en ambas ondas, pero un miembro está únicamente en una
duplicates tag codusu componente nro_hogar aglo, gen(auxiliar) 
gen     obs_duplicada = 0
replace obs_duplicada = 1    if  auxiliar==1
replace pondera = pondera/2  if  obs_duplicada==1
drop auxiliar 

* Repondera para llegar al expandido de los aglomerados relevados 
summ    ch04 [w=pondera]
scalar  p_semestre = r(sum_w)
scalar      coef_p = p_trimestre/p_semestre 

egen   pondera2 = min(pondera), by(codusu nro_hogar trimestre)
replace pondera = pondera2*coef_p
replace pondera = round(pondera)
rename pondera3 pondera_oficial
drop pondera2
compress

gen	pondera2 = .
replace pondera2 = pondera		
replace pondera2 = pondera/1.08935	if  ch06>=-1 & ch06<=9  & trimestre==1 
replace pondera2 = pondera/1.02288	if  ch06>=10 & ch06<=19 & trimestre==1 
replace pondera2 = pondera/0.98815	if  ch06>=20 & ch06<=29 & trimestre==1 
replace pondera2 = pondera/1.07348	if  ch06>=30 & ch06<=39 & trimestre==1 
replace pondera2 = pondera/0.99897	if  ch06>=40 & ch06<=49 & trimestre==1 
replace pondera2 = pondera/0.91496	if  ch06>=50 & ch06<=59 & trimestre==1 
replace pondera2 = pondera/0.94195	if  ch06>=60 & ch06<=69 & trimestre==1 
replace pondera2 = pondera/0.85141	if  ch06>=70 & ch06<=79 & trimestre==1 
replace pondera2 = pondera/0.89783	if  ch06>=80 & ch06<=89 & trimestre==1 
replace pondera2 = pondera/0.84626	if  ch06>=90 & ch06<.   & trimestre==1 

replace pondera2 = pondera/1.08934	if  ch06>=-1 & ch06<=9  & trimestre==2 
replace pondera2 = pondera/1.03983	if  ch06>=10 & ch06<=19 & trimestre==2 
replace pondera2 = pondera/0.97781	if  ch06>=20 & ch06<=29 & trimestre==2 
replace pondera2 = pondera/1.07380	if  ch06>=30 & ch06<=39 & trimestre==2 
replace pondera2 = pondera/1.02219	if  ch06>=40 & ch06<=49 & trimestre==2 
replace pondera2 = pondera/0.92186	if  ch06>=50 & ch06<=59 & trimestre==2 
replace pondera2 = pondera/0.90495	if  ch06>=60 & ch06<=69 & trimestre==2 
replace pondera2 = pondera/0.85966	if  ch06>=70 & ch06<=79 & trimestre==2 
replace pondera2 = pondera/0.84042	if  ch06>=80 & ch06<=89 & trimestre==2 
replace pondera2 = pondera/0.87274	if  ch06>=90 & ch06<.   & trimestre==2 

replace  pondera = round(pondera2)


replace pondera_oficial = pondera_oficial/1.08935	if  ch06>=-1 & ch06<=9  & trimestre==1 
replace pondera_oficial = pondera_oficial/1.02288	if  ch06>=10 & ch06<=19 & trimestre==1 
replace pondera_oficial = pondera_oficial/0.98815	if  ch06>=20 & ch06<=29 & trimestre==1 
replace pondera_oficial = pondera_oficial/1.07348	if  ch06>=30 & ch06<=39 & trimestre==1 
replace pondera_oficial = pondera_oficial/0.99897	if  ch06>=40 & ch06<=49 & trimestre==1 
replace pondera_oficial = pondera_oficial/0.91496	if  ch06>=50 & ch06<=59 & trimestre==1 
replace pondera_oficial = pondera_oficial/0.94195	if  ch06>=60 & ch06<=69 & trimestre==1 
replace pondera_oficial = pondera_oficial/0.85141	if  ch06>=70 & ch06<=79 & trimestre==1 
replace pondera_oficial = pondera_oficial/0.89783	if  ch06>=80 & ch06<=89 & trimestre==1 
replace pondera_oficial = pondera_oficial/0.84626	if  ch06>=90 & ch06<.   & trimestre==1 

replace pondera_oficial = pondera_oficial/1.08934	if  ch06>=-1 & ch06<=9  & trimestre==2 
replace pondera_oficial = pondera_oficial/1.03983	if  ch06>=10 & ch06<=19 & trimestre==2 
replace pondera_oficial = pondera_oficial/0.97781	if  ch06>=20 & ch06<=29 & trimestre==2 
replace pondera_oficial = pondera_oficial/1.07380	if  ch06>=30 & ch06<=39 & trimestre==2 
replace pondera_oficial = pondera_oficial/1.02219	if  ch06>=40 & ch06<=49 & trimestre==2 
replace pondera_oficial = pondera_oficial/0.92186	if  ch06>=50 & ch06<=59 & trimestre==2 
replace pondera_oficial = pondera_oficial/0.90495	if  ch06>=60 & ch06<=69 & trimestre==2 
replace pondera_oficial = pondera_oficial/0.85966	if  ch06>=70 & ch06<=79 & trimestre==2 
replace pondera_oficial = pondera_oficial/0.84042	if  ch06>=80 & ch06<=89 & trimestre==2 
replace pondera_oficial = pondera_oficial/0.87274	if  ch06>=90 & ch06<.   & trimestre==2 

replace pondera_oficial = round(pondera_oficial)

capture drop dig* edad hstrt ocupado id hombre nivel gedad1 ghstrt
sort  codusu nro_hogar trimestre componente
save  "`base_out'", replace
