clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "1999"  // Year of the survey
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
Crea base de Argentina - 1999 (EPH)

Autor: CEDLAS/UNLP  
cedlas@depeco.econo.unlp.edu.ar

Actualizado: Mayo de 2018

***********************************************************************************************/

cd "`base_in'"

* Abre base de datos hogares
local     base "bblanca catamar comodoro concor cordoba corrie estero formosa fuego gallegos gba jujuy Lapampa laplata larioja mendoza mplata neuquen parana posadas rcuarto resisten rosario salta sanjuan sanluis santafe tucuman"
tokenize `base'

* Crea bases temporarias
forvalues i = 1(1)28	{
			tempfile hog`i'
			tempfile tot`i'
			}

* Une bases hogares y personas en casa aglomerado
local totobs = 0
forvalues  i = 1(1)28	{
			clear
			
			use "``i''\bthog.dta"
			keep codusu realizad onda ano p0* r0* aglomera
			renpfix p0 ph
			sort aglomera codusu
			save `hog`i''
	
			use "``i''\btper.dta"
			sort aglomera codusu

			merge aglomera codusu using `hog`i''
			tab _merge
			drop if _merge==2	
			count
			local num=r(N)
			local totobs=`totobs'+`num'

			save `tot`i''
			}

* Une aglomerados
use `tot1', clear
forvalues i=2(1)28	{
			append using `tot`i''
			}

compress
destring p56, replace
destring p58b, replace
destring decind, replace
destring deccf, replace
destring decif, replace
duplicates report

sort aglomera codusu com
save  "`base_out'", replace

