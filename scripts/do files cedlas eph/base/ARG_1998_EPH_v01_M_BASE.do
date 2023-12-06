clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "1998"  // Year of the survey
local survey   "EPH"   // Survey acronym
local vm       "01"    // Master version
local va       ""      // Alternative version
local project  "03"    // Project version
local period   ""      // Periodo, ejemplo -S1 -S2
local alterna  ""      // 

include "${rootdatalib}/_git_sedlac-03/_aux/sedlac_hardcode.do"

local base_in   "`folder_nesstar_stata'"
local base_out  "`base_out_nesstar_base'"

/******************************************************************************************

SOCIO-ECONOMIC DATABASE FOR LATIN AMERICA AND THE CARIBBEAN (SEDLAC) 
CEDLAS/UNLP y THE WORLD BANK 
Crea base de Argentina - 1998 (EPH)

Autor: CEDLAS/UNLP  
cedlas@depeco.econo.unlp.edu.ar

Actualizado: Mayo de 2018

***********************************************************************************************/

cd "`base_in'"

* Abre base de datos hogares
use   "arg98ho.dta", replace
keep    cod aglo pob_tot 
replace cod = aglo*100000+cod
ren    aglo aglomera
sort   cod aglo
save  "borrar.dta", replace

* Abre base agregada de personas
use  "arg98pe.dta", replace
sort  cod aglo
merge cod aglomera using "borrar.dta"
tab  _merge
drop _merge
drop if (com==. & edad==.)

duplicates report
compress

sort cod aglomera com
save  "`base_out'", replace
erase "borrar.dta"
