clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "1980"  // Year of the survey
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
Crea base de GBA - 1986 (EPH)

Autor: CEDLAS/UNLP  
cedlas@depeco.econo.unlp.edu.ar

Actualizado: Mayo de 2018

***********************************************************************************************/

cd "`base_in'"

* Abre base de datos hogares
use "bthog.dta", clear

* Renombra variables con nombre similar al de la base de personas
local lista = "entrevista onda ano aglomerado realizada p01 p02 p03 p04 p05 p06 p07 p08 r01 r02 r03 r04 r05 r06 itf decif ipcf deccf pondera"
foreach i of varlist `lista' {
			     ren  `i'  h_`i'
			     }
sort cod
save "temp_hog.dta", replace

* Abre base de datos personas 
use  "btper.dta", clear


* Lleva a variable numérica algunas variables cargadas como string originalmente
destring     p56, replace
destring ingreso, replace
destring  decocu, replace
destring   decif, replace
destring   deccf, replace

sort  cod
merge cod using "temp_hog.dta"
tab  _merge
drop _merge 

duplicates report
compress

sort cod com
save "`base_out'", replace
erase "temp_hog.dta"


