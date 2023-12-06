clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "2003"  // Year of the survey
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
Crea base de Argentina - 2003 (EPH)

Autor: CEDLAS/UNLP  
cedlas@depeco.econo.unlp.edu.ar

Actualizado: Mayo de 2018

***********************************************************************************************/

cd "`base_in'"

* Abre base de datos hogares
* Bases del total de aglomerados excepto Santa Fe - Mayo 2003     *
tempfile provisoria1
tempfile provisoria2

use  "hog_bua.dta", clear
keep  codusu agloreal p0* r0* realizad
renpfix p0 ph
sort  agloreal codusu
save `provisoria1', replace

* Abre base de datos jefa/jefe
use  "jefajefe.dta", clear
keep  agloreal codusu componen pj* h12
capture rename h12 h12_j
sort  agloreal codusu componen
save `provisoria2', replace

* Abre base de datos personas
use "per_bua.dta", clear
sort   agloreal codusu componen
merge  agloreal codusu componen using `provisoria2'
rename _merge merge1

sort   agloreal codusu
merge  agloreal codusu using `provisoria1'
rename _merge merge2

* Guarda provisoriamente la base
drop   aglomera
rename agloreal aglomera
sort   aglomera codusu componen
tempfile quasitotal
save    `quasitotal'

*  Santa Fe - Octubre 2002  *
tempfile tot_stfe
tempfile hog_stfe

* Base hogares
use  "hog_bua_5.dta", clear
keep  codusu aglomera p0* r0* realizad
renpfix p0 ph
sort  aglomera codusu
save `hog_stfe', replace

* Base personas
use "per_bua_5.dta", clear
sort aglomera codusu componen

sort   aglomera codusu
merge  aglomera codusu using `hog_stfe'
rename _merge merge2_5

drop if merge2==2   

* Guarda provisoriamente la base
sort  aglomera codusu componen
save `tot_stfe'

*    Une Santa Fe al resto de los aglomerados    *
clear
use `quasitotal'
append using `tot_stfe'
tab aglomera

* Formato de variables
destring p56, replace
destring p58b, replace
duplicates report

compress
sort aglomera codusu componen
save  "`base_out'", replace

