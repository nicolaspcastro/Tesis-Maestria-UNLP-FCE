clear
clear matrix
local country  "ARG"   // Country ISO code
local year     "1997"  // Year of the survey
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
Crea base de Argentina - 1997 (EPH)

Autor: CEDLAS/UNLP  
cedlas@depeco.econo.unlp.edu.ar

Actualizado: Mayo de 2018

***********************************************************************************************/

cd "`base_in'"

* Abre base de datos hogares
local     base "comodoro cordoba estero fuego gallegos gba jujuy lapampa laplata neuquen parana salta sanjuan sanluis santafe"
tokenize `base'

* Crea bases temporarias
forvalues i = 1(1)15	{
			tempfile hog`i'
			tempfile tot`i'
			}

* Une bases hogares y personas en casa aglomerado
local totobs = 0
forvalues  i = 1(1)15	{
			clear
			
			use "``i''\bthog.dta"
			keep cod realizad onda ano p0* r0* aglomera itf decif ipcf deccf pondera men14 cat60 tipoviv habitacion agua bano tenencia material pob_tot ocupado subocupado desocupado inactivo percept
			renpfix p0 ph
			sort aglomera cod
			save `hog`i''
		
			use "``i''\btper.dta"
			sort aglomera cod

			merge aglomera cod using `hog`i''
			tab _merge
			drop if _merge==2	
			count
			local num=r(N)
			local totobs=`totobs'+`num'

			capture drop p08esp p30esp p34esp p41_* p42esp p39esp p20_* p48esp

			compress
			save `tot`i''
			}

* Une aglomerados
use `tot1', clear
forvalues i = 2(1)15	{
			append using `tot`i''
			}

destring, replace
duplicates report

replace aglomerado = aglomera if aglomerado==.
replace componente = componen if componente==.
drop aglomera componen

sort aglomerado cod com
compress
save  "`base_out'", replace

