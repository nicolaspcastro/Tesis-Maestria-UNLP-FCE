clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "2007"  // Year of the survey
local survey   "EPHC"  // Survey acronym
local vm       "03"    // Master version
local va       ""      // Alternative version
local project  "03"    // Project version
local period   "-S2"   // Periodo, ejemplo -S1 -S2
local alterna  ""      // 

include "${rootdatalib}/_git_sedlac-03/_aux/sedlac_hardcode.do"

local base_in   "`folder_nesstar_stata'"
local base_out  "`base_out_nesstar_base'"

/*********************************************************************

SOCIO-ECONOMIC DATABASE FOR LATIN AMERICA AND THE CARIBBEAN (SEDLAC) 
CEDLAS/UNLP y THE WORLD BANK 

Crea base de Argentina 2007 (EPHC - Semestre II)

Autor: CEDLAS/UNLP  
cedlas@depeco.econo.unlp.edu.ar

Actualizado: Julio de 2019

**********************************************************************/

cd "`base_in'"

*******************************************************************************
******** Une bases de los dos trimestres 
*******************************************************************************
use          "Trimestre_4"
duplicates report
duplicates drop

gen pondera3 = pondera
rename pondera3 pondera_oficial
compress

capture drop dig* edad hstrt ocupado id hombre nivel gedad1 ghstrt
sort  codusu nro_hogar trimestre componente
save  "`base_out'", replace
