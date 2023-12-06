clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "2002"  // Year of the survey
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
Crea base de Argentina - 2002 (EPH)

Autor: CEDLAS/UNLP  
cedlas@depeco.econo.unlp.edu.ar

Actualizado: Mayo de 2018

***********************************************************************************************/

cd "`base_in'"

* Abre base de datos hogares
tempfile provisoria
tempfile provisoria2

use  "hog_bua.dta", clear
keep  codusu agloreal p0* r0* realizad
renpfix p0 ph
sort  agloreal codusu
save `provisoria', replace

* Abre base de datos jefes y jefas
use  "jefajefe.dta", clear
keep  codusu agloreal componente pj*
sort  agloreal codusu componente
save `provisoria2', replace

* Abre base de datos personas
use "per_bua.dta", clear
sort  agloreal codusu
merge agloreal codusu using `provisoria'
rename _merge merge2
sort  agloreal codusu componente
merge agloreal codusu componente using `provisoria2'
tab  _merge
drop if merge2==2
drop _merge merge*

compress
destring p56, replace
destring p58b, replace
destring decind, replace
destring deccf, replace
destring decif, replace
duplicates report

drop   aglomera
rename agloreal aglomera
keep if (aglomera<=34 | aglomera==36)

sort aglomera codusu componen
save  "`base_out'", replace
