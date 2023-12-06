clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "2007"  // Year of the survey
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

Crea base de Argentina 2007 (EPHC - Semestre I)

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

capture drop dig* edad hstrt ocupado id hombre nivel gedad1 ghstrt
sort  codusu nro_hogar trimestre componente
save  "`base_out'", replace
