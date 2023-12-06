****************************************************************************************************************************************
*                                             IMPORCACIONES DE DIFERENTES BASES DE PBG
*                                                   CALCULOS, COMPARACIÓN Y DETERMINACIÓN DE BASE FINAL
****************************************************************************************************************************************

* Posibilidades de actualización de datos:
*   - INDICADOR SINTETICO DE ACTIVIDAD PROVINCIAL (ISAP) - MUÑOZ Y TROMBETTA
*   - INDICE DE ACTIVIDAD ECONOMICA PROVINCIAL (IAEP) - MALVICINO, PEREIRA Y TRAJTENBERG (EN CUINAP PAG 26 EXPLICACIÓN DE COMO USARLO)
*   - INDICADOR SINTETICO DE ECONOMIAS REGIONALES (ISER) - SUBSE DE PROGRAMACIÓN REGIONAL Y SECTORIAL (MECON)

****************************************************************************************************************************************
noi display in green "COMENZANDO DO FILE IMPORTACIÓN Y CALCULOS PBG"
*AGREGAR QUIETLY Y DISPLAYS

clear all 
set more off

quietly {
    * ########################### PBG PUIG
    noi display in yellow "IMPORTANDO BASE PBG PUIG Y REALIZANDO CALCULOS"

    import excel "${path_datain}\PBG\Originales\pbg puig - original.xlsx", sheet("Hoja1") firstrow clear
    * datos desde 1960 para todas las provincias (menos caba)

    rename prov_name prov
    gen nprov=.
    replace nprov=1     if prov=="Buenos Aires" 
    replace nprov=5     if prov=="Ciudad Autonoma de BA"
    replace nprov=6     if prov=="Cordoba" 
    replace nprov=21    if prov=="Santa Fe" 
    replace nprov=11    if prov=="La Pampa" 
    replace nprov=13    if prov=="Mendoza" 
    replace nprov=18    if prov=="San Juan"  
    replace nprov=19    if prov=="San Luis" 
    replace nprov=3     if prov=="Chaco"   
    replace nprov=7     if prov=="Corrientes"  
    replace nprov=8     if prov=="Entre Rios" 
    replace nprov=9     if prov=="Formosa"  
    replace nprov=14    if prov=="Misiones"  
    replace nprov=2     if prov=="Catamarca" 
    replace nprov=10    if prov=="Jujuy" 
    replace nprov=12    if prov=="La Rioja" 
    replace nprov=17    if prov=="Salta" 
    replace nprov=22    if prov=="Santiago del Estero" 
    replace nprov=24    if prov=="Tucuman" 
    replace nprov=16    if prov=="Rio Negro" 
    replace nprov=15    if prov=="Neuquen" 
    replace nprov=4     if prov=="Chubut" 
    replace nprov=20    if prov=="Santa Cruz" 
    replace nprov=23    if prov=="Tierra del Fuego" 

    rename pbg pbg_base_2001

    * local con ipi 1993-2001
    loc ipi_1993_2001 = 101.780338513259
    *loc ipc_1993_2001 = 106.0008
    loc ipc_1993_2001 = 105.8198

    gen pbg_puig_ipi=.
    replace pbg_puig_ipi=pbg_base_2001*100/`ipi_1993_2001'

    gen pbg_puig_ipc=.
    replace pbg_puig_ipc=pbg_base_2001*100/`ipc_1993_2001'

    keep if year>=1991

    clonevar año = year

    keep año prov nprov pbg_puig*

    save "${path_datain}\PBG\pbg_puig.dta", replace

    * ########################### PBI
    noi display in yellow "IMPORTANDO BASE PBI Y REALIZANDO CALCULOS"

    import excel "${path_datain}\IPC\actividad_ied.xlsx", sheet("PBI") firstrow clear

    loc ipi_1993_2004 = 160.364461966938
    *loc ipc_1993_2004 = 158.0417
    loc ipc_1993_2004 = 157.6521

    gen pbi_2004_93_ipi = .
    replace pbi_2004_93_ipi = pbi_2004*100/`ipi_1993_2004'

    gen pbi_2004_93_ipc = .
    replace pbi_2004_93_ipc = pbi_2004*100/`ipc_1993_2004'

    * OJO PORQUE NO DAN IGUALES EL PBI A PRECIOS DE 1993 Y EL PBI A PRECIOS DE 2004 PASADO 1993
    * HASTA VARIACIONES DE UNA Y OTRA SERIE EN LOS AÑOS QUE COMPARTEN DAN DISTINTO. ES MUY RARO

    gen var_93= pbi_1993/ pbi_1993[_n-1] - 1

    gen pbi_2004_completo = pbi_2004

    forv i = 1/11 {

        replace pbi_2004_completo = pbi_2004_completo[_n+1]/(1+ var_93[_n+1]) if _n==12-`i'
    }

    gen pbi_ipi = pbi_2004_completo*100/`ipi_1993_2004'
    gen pbi_ipc = pbi_2004_completo*100/`ipc_1993_2004'

    gen pbi_ipi_2=.
    replace pbi_ipi_2=pbi_1993
    replace pbi_ipi_2 = pbi_2004_93_ipi if pbi_ipi_2==.

    gen pbi_ipc_2=.
    replace pbi_ipc_2=pbi_1993
    replace pbi_ipc_2 = pbi_2004_93_ipc if pbi_ipc_2==.

    label var año                   "Año"
    label var pbi_1993              "PBI base 1993 (1993-2012) INDEC"
    label var pbi_2004              "PBI base 2004 (2004-2021) INDEC"
    label var pbi_2004_93_ipi       "PBI base 2004 INDEC pasado a precios de 1993 - IPI"
    label var pbi_2004_93_ipc       "PBI base 2004 INDEC pasado a precios de 1993 - IPC"
    label var var_93                "Variación de PBI base 1993 (1993-2012) INDEC"
    label var pbi_2004_completo     "PBI base 2004 (1993-2021) INDEC - Utiliando var de base 1993"
    label var pbi_ipi               "PBI base 1993 (1993-2021) - IPI"
    label var pbi_ipc               "PBI base 1993 (1993-2021) - IPC"
    label var pbi_ipi_2             "PBI base 1993 (1993-2021) partiendo de base 1993 - IPI"
    label var pbi_ipc_2             "PBI base 1993 (1993-2021) partiendo de base 1993 - IPC"

    save "${path_datain}\PBG\pbi_arg.dta", replace

    * ########################### PBG INDEC (SOLO 2004 PERO SUPER OFICIAL)
    noi display in yellow "IMPORTANDO BASE PBG INDEC Y REALIZANDO CALCULOS"

    import excel "${path_datain}\PBG\Originales\PIB_provincial_06_17.xlsx", sheet("PBG") firstrow clear

    loc ipi_1993_2004 = 160.364461966938
    *loc ipc_1993_2004 = 158.0417
    loc ipc_1993_2004 = 157.6521

    replace pbg_indec = pbg_indec / 1000

    gen pbg_indec_ipi = pbg_indec*100/`ipi_1993_2004'
    gen pbg_indec_ipc = pbg_indec*100/`ipc_1993_2004'

    drop if nprov>24

    save "${path_datain}\PBG\pbg_indec.dta", replace

    * diferencia entre pbi indec y pbg total de esta base: 23 mil millones de pesos del 93 (8.4% por encima la suma de pbg indec 2004 a precios 1993)

    * ########################### PBG MECON
    noi display in yellow "IMPORTANDO BASE PBG MECON Y REALIZANDO CALCULOS"

    import delimited "${path_datain}\PBG\Originales\indicadores-provinciales.csv", clear
    save "${path_datain}\PBG\Originales\indicadores-provinciales.dta", replace

    keep if actividad_producto_nombre=="PBG Total"
    keep indicador unidad_de_medida fuente alcance_nombre indice_tiempo valor
    replace indicador = "_1993" if indicador == "PBG - Base 1993"
    replace indicador = "_2004" if indicador == "PBG - Base 2004"

    replace fuente = "DPEYC y IIEE San Juan" if fuente == "DPEYC San Juan"
    replace fuente = "DPEYC y IIEE San Juan" if fuente == "IIEE San Juan"

    reshape wide valor, i(fuente alcance_nombre indice_tiempo unidad_de_medida) j(indicador) string

    encode unidad_de_medida, gen (unidad)
    *pesos corrientes=1; pesos 1993=2; pesos 2004=3
    drop unidad_de_medida
    reshape wide valor*, i(fuente alcance_nombre indice_tiempo ) j(unidad)

    rename valor_19931 pbg_mecon_1993_corr 
    rename valor_20041 pbg_mecon_2004_corr 
    rename valor_19932 pbg_mecon_1993_const 
    rename valor_20042 pbg_mecon_2004_93 
    rename valor_19933 pbg_mecon_1993_04 
    rename valor_20043 pbg_mecon_2004_const

    rename alcance_nombre provincia
    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="BUENOS AIRES"	
    replace prov = "Catamarca"                  if provincia=="CATAMARCA"		
    replace prov = "Chaco"                      if provincia=="CHACO"			
    replace prov = "Chubut"                     if provincia=="CHUBUT"	
    replace prov = "Ciudad Autonoma de BA"      if provincia=="CAPITAL FEDERAL"	
    replace prov = "Cordoba"                    if provincia=="CORDOBA"			
    replace prov = "Corrientes"                 if provincia=="CORRIENTES"	
    replace prov = "Entre Rios"                 if provincia=="ENTRE RIOS"	
    replace prov = "Formosa"                    if provincia=="FORMOSA"			
    replace prov = "Jujuy"                      if provincia=="JUJUY"			
    replace prov = "La Pampa"                   if provincia=="LA PAMPA"	
    replace prov = "La Rioja"                   if provincia=="LA RIOJA"	
    replace prov = "Mendoza"                    if provincia=="MENDOZA"			
    replace prov = "Misiones"                   if provincia=="MISIONES"	
    replace prov = "Neuquen"                    if provincia=="NEUQUEN"			
    replace prov = "Rio Negro"                  if provincia=="RIO NEGRO"	
    replace prov = "Salta"                      if provincia=="SALTA"			
    replace prov = "San Juan"                   if provincia=="SAN JUAN"		
    replace prov = "San Luis"                   if provincia=="SAN LUIS"		
    replace prov = "Santa Cruz"                 if provincia=="SANTA CRUZ"		
    replace prov = "Santa Fe"                   if provincia=="SANTA FE"		
    replace prov = "Santiago del Estero"        if provincia=="SANTIAGO DEL ESTERO"
    replace prov = "Tierra del Fuego"           if provincia=="TIERRA DEL FUEGO"
    replace prov = "Tucuman"                    if provincia=="TUCUMAN"

    gen nprov=.
    replace nprov=1     if prov=="Buenos Aires" 
    replace nprov=5     if prov=="Ciudad Autonoma de BA"
    replace nprov=6     if prov=="Cordoba" 
    replace nprov=21    if prov=="Santa Fe" 
    replace nprov=11    if prov=="La Pampa" 
    replace nprov=13    if prov=="Mendoza" 
    replace nprov=18    if prov=="San Juan"  
    replace nprov=19    if prov=="San Luis" 
    replace nprov=3     if prov=="Chaco"   
    replace nprov=7     if prov=="Corrientes"  
    replace nprov=8     if prov=="Entre Rios" 
    replace nprov=9     if prov=="Formosa"  
    replace nprov=14    if prov=="Misiones"  
    replace nprov=2     if prov=="Catamarca" 
    replace nprov=10    if prov=="Jujuy" 
    replace nprov=12    if prov=="La Rioja" 
    replace nprov=17    if prov=="Salta" 
    replace nprov=22    if prov=="Santiago del Estero" 
    replace nprov=24    if prov=="Tucuman" 
    replace nprov=16    if prov=="Rio Negro" 
    replace nprov=15    if prov=="Neuquen" 
    replace nprov=4     if prov=="Chubut" 
    replace nprov=20    if prov=="Santa Cruz" 
    replace nprov=23    if prov=="Tierra del Fuego" 

    gen año=substr(indice_tiempo,1,4)
    destring año, replace

    order año indice_tiempo nprov provincia prov fuente pbg_mecon_1993_corr pbg_mecon_2004_corr pbg_mecon_1993_const pbg_mecon_2004_93 pbg_mecon_1993_04 pbg_mecon_2004_const 

    label var año                   "Año" 
    label var indice_tiempo         "Indice de Tiempo" 
    label var nprov                 "Código de Provincia" 
    label var provincia             "Nombre Provincia Original" 
    label var prov                  "Nombre Provincia Base" 
    label var fuente                "Fuente Dato"
    label var pbg_mecon_1993_corr   "PBG - miles de pesos corrientes"
    label var pbg_mecon_2004_corr   "PBG - miles de pesos corrientes"
    label var pbg_mecon_1993_const  "PBG - miles de pesos de 1993"
    label var pbg_mecon_2004_93     "PBG - miles de pesos de 1993"
    label var pbg_mecon_1993_04     "PBG - miles de pesos de 2004"
    label var pbg_mecon_2004_const  "PBG - miles de pesos de 2004"

    save "${path_datain}\PBG\pbg_mecon_completa.dta", replace

    drop pbg_mecon_1993_corr pbg_mecon_2004_corr pbg_mecon_2004_93 pbg_mecon_1993_04 fuente indice_tiempo provincia

    rename pbg_mecon_1993_const pbg_mecon_93
    rename pbg_mecon_2004_const pbg_mecon_04

    replace pbg_mecon_93 = pbg_mecon_93 / 1000
    replace pbg_mecon_04 = pbg_mecon_04 / 1000

    label var pbg_mecon_93     "PBG - millones de pesos de 1993"
    label var pbg_mecon_04     "PBG - millones de pesos de 2004"

    sort prov año
    format %20.2f pbg_mecon_93
    format %20.2f pbg_mecon_04
    * format %15.2fc - para que muestre comas como separador de miles y dos decimales

    loc ipi_1993_2004 = 160.364461966938
    *loc ipc_1993_2004 = 158.0417
    loc ipc_1993_2004 = 157.6521

    gen pbg_mecon_04_93_ipi = .
    replace pbg_mecon_04_93_ipi = pbg_mecon_04*100/`ipi_1993_2004'

    gen pbg_mecon_04_93_ipc = .
    replace pbg_mecon_04_93_ipc = pbg_mecon_04*100/`ipc_1993_2004'

    gen pbg_mecon_ipi = .
    replace pbg_mecon_ipi = pbg_mecon_93
    replace pbg_mecon_ipi = pbg_mecon_04_93_ipi if pbg_mecon_ipi==.
    format %20.2f pbg_mecon_ipi

    gen pbg_mecon_ipc = .
    replace pbg_mecon_ipc = pbg_mecon_93
    replace pbg_mecon_ipc = pbg_mecon_04_93_ipc if pbg_mecon_ipc==.
    format %20.2f pbg_mecon_ipc

    drop pbg_mecon_93 pbg_mecon_04 pbg_mecon_04_93*

    save "${path_datain}\PBG\pbg_mecon.dta", replace

    * ############ BASE ISAP - TROMBETTA
    noi display in yellow "IMPORTANDO BASE ISAP TROMBETTA Y REALIZANDO CALCULOS"

    import excel "${path_datain}\PBG\Originales\Base ISAP difusion.xlsx", sheet("original") firstrow clear

    loc prov = "BuenosAires CABA Catamarca Chaco Chubut Córdoba Corrientes EntreRíos Formosa Jujuy LaPampa LaRioja Mendoza Misiones Neuquén RíoNegro Salta SanJuan SanLuis SantaCruz SantaFe SantiagodelEstero TierradelFuego Tucumán"
    rename Trimestre trim
    gen provincia=""

    foreach var in `prov' {

        preserve
        keep trim provincia `var'
        rename `var' isap_tromb
        replace prov="`var'"
        save "${path_datain}\PBG\Originales\isap_aux\\`var'.dta", replace
        restore
    }

    loc prov = "CABA Catamarca Chaco Chubut Córdoba Corrientes EntreRíos Formosa Jujuy LaPampa LaRioja Mendoza Misiones Neuquén RíoNegro Salta SanJuan SanLuis SantaCruz SantaFe SantiagodelEstero TierradelFuego Tucumán"

    use "${path_datain}\PBG\Originales\isap_aux\BuenosAires.dta", clear

    foreach var in `prov' {
        merge 1:1 trim provincia using "${path_datain}\PBG\Originales\isap_aux\\`var'.dta", gen(_merge_`var')
        erase "${path_datain}\PBG\Originales\isap_aux\\`var'.dta"
    }

    drop _merge*

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="BuenosAires"
    replace prov = "Catamarca"                  if provincia=="Catamarca"
    replace prov = "Chaco"                      if provincia=="Chaco"
    replace prov = "Chubut"                     if provincia=="Chubut"
    replace prov = "Ciudad Autonoma de BA"      if provincia=="CABA"
    replace prov = "Cordoba"                    if provincia=="Córdoba"
    replace prov = "Corrientes"                 if provincia=="Corrientes"
    replace prov = "Entre Rios"                 if provincia=="EntreRíos"
    replace prov = "Formosa"                    if provincia=="Formosa"
    replace prov = "Jujuy"                      if provincia=="Jujuy"
    replace prov = "La Pampa"                   if provincia=="LaPampa"
    replace prov = "La Rioja"                   if provincia=="LaRioja"
    replace prov = "Mendoza"                    if provincia=="Mendoza"
    replace prov = "Misiones"                   if provincia=="Misiones"
    replace prov = "Neuquen"                    if provincia=="Neuquén"
    replace prov = "Rio Negro"                  if provincia=="RíoNegro"
    replace prov = "Salta"                      if provincia=="Salta"
    replace prov = "San Juan"                   if provincia=="SanJuan"
    replace prov = "San Luis"                   if provincia=="SanLuis"
    replace prov = "Santa Cruz"                 if provincia=="SantaCruz"
    replace prov = "Santa Fe"                   if provincia=="SantaFe"
    replace prov = "Santiago del Estero"        if provincia=="SantiagodelEstero"
    replace prov = "Tierra del Fuego"           if provincia=="TierradelFuego"
    replace prov = "Tucuman"                    if provincia=="Tucumán"

    gen nprov=.
    replace nprov=1     if prov=="Buenos Aires" 
    replace nprov=5     if prov=="Ciudad Autonoma de BA"
    replace nprov=6     if prov=="Cordoba" 
    replace nprov=21    if prov=="Santa Fe" 
    replace nprov=11    if prov=="La Pampa" 
    replace nprov=13    if prov=="Mendoza" 
    replace nprov=18    if prov=="San Juan"  
    replace nprov=19    if prov=="San Luis" 
    replace nprov=3     if prov=="Chaco"   
    replace nprov=7     if prov=="Corrientes"  
    replace nprov=8     if prov=="Entre Rios" 
    replace nprov=9     if prov=="Formosa"  
    replace nprov=14    if prov=="Misiones"  
    replace nprov=2     if prov=="Catamarca" 
    replace nprov=10    if prov=="Jujuy" 
    replace nprov=12    if prov=="La Rioja" 
    replace nprov=17    if prov=="Salta" 
    replace nprov=22    if prov=="Santiago del Estero" 
    replace nprov=24    if prov=="Tucuman" 
    replace nprov=16    if prov=="Rio Negro" 
    replace nprov=15    if prov=="Neuquen" 
    replace nprov=4     if prov=="Chubut" 
    replace nprov=20    if prov=="Santa Cruz" 
    replace nprov=23    if prov=="Tierra del Fuego" 

    gen año=year( trim)

    bysort prov año: egen isap_prom = mean(isap_tromb)
    bysort prov año: gen aux=_n
    keep if aux==1

    keep año prov nprov isap_prom

    bysort nprov: gen aux=_n
    gen aux_isap=.
    replace aux_isap=isap_prom if aux==8
    drop aux

    bysort nprov: egen aux=mean(aux_isap)
    drop aux_isap

    gen isap_tromb=.
    replace isap_tromb=isap_prom/aux*100
    label var isap_tromb "ISAP TROMBETTA 2004 = 100"

    drop aux
    rename isap_prom isap_97

    save "${path_datain}\PBG\base_isap_tromb.dta", replace

    * ############ BASE ISAP - TRAJTENBERG
    noi display in yellow "IMPORTANDO BASE ISAP TRAJTENBERG Y REALIZANDO CALCULOS"

    import excel "${path_datain}\PBG\Originales\Datos ISAP - Trajtenberg.xlsx", firstrow clear

    loc prov = "buenosaires caba catamarca chaco chubut cordoba corrientes entrerios formosa jujuy lapampa larioja mendoza misiones neuquen rionegro salta sanjuan sanluis santacruz santafe tdfuego tucuman sde"

    gen provincia=""

    foreach var in `prov' {

        preserve
        keep period provincia `var'
        rename `var' isap_trajt
        replace prov="`var'"
        save "${path_datain}\PBG\Originales\isap_trajt_aux\\`var'.dta", replace
        restore
    }

    loc prov = "caba catamarca chaco chubut cordoba corrientes entrerios formosa jujuy lapampa larioja mendoza misiones neuquen rionegro salta sanjuan sanluis santacruz santafe tdfuego tucuman sde"

    use "${path_datain}\PBG\Originales\isap_trajt_aux\buenosaires.dta", clear

    foreach var in `prov' {
        merge 1:1 period provincia using "${path_datain}\PBG\Originales\isap_trajt_aux\\`var'.dta", gen(_merge_`var')
        erase "${path_datain}\PBG\Originales\isap_trajt_aux\\`var'.dta"
    }

    drop _merge*

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="buenosaires"
    replace prov = "Catamarca"                  if provincia=="catamarca"
    replace prov = "Chaco"                      if provincia=="chaco"
    replace prov = "Chubut"                     if provincia=="chubut"
    replace prov = "Ciudad Autonoma de BA"      if provincia=="caba"
    replace prov = "Cordoba"                    if provincia=="cordoba"
    replace prov = "Corrientes"                 if provincia=="corrientes"
    replace prov = "Entre Rios"                 if provincia=="entrerios"
    replace prov = "Formosa"                    if provincia=="formosa"
    replace prov = "Jujuy"                      if provincia=="jujuy"
    replace prov = "La Pampa"                   if provincia=="lapampa"
    replace prov = "La Rioja"                   if provincia=="larioja"
    replace prov = "Mendoza"                    if provincia=="mendoza"
    replace prov = "Misiones"                   if provincia=="misiones"
    replace prov = "Neuquen"                    if provincia=="neuquen"
    replace prov = "Rio Negro"                  if provincia=="rionegro"
    replace prov = "Salta"                      if provincia=="salta"
    replace prov = "San Juan"                   if provincia=="sanjuan"
    replace prov = "San Luis"                   if provincia=="sanluis"
    replace prov = "Santa Cruz"                 if provincia=="santacruz"
    replace prov = "Santa Fe"                   if provincia=="santafe"
    replace prov = "Santiago del Estero"        if provincia=="sde"
    replace prov = "Tierra del Fuego"           if provincia=="tdfuego"
    replace prov = "Tucuman"                    if provincia=="tucuman"

    gen nprov=.
    replace nprov=1     if prov=="Buenos Aires" 
    replace nprov=5     if prov=="Ciudad Autonoma de BA"
    replace nprov=6     if prov=="Cordoba" 
    replace nprov=21    if prov=="Santa Fe" 
    replace nprov=11    if prov=="La Pampa" 
    replace nprov=13    if prov=="Mendoza" 
    replace nprov=18    if prov=="San Juan"  
    replace nprov=19    if prov=="San Luis" 
    replace nprov=3     if prov=="Chaco"   
    replace nprov=7     if prov=="Corrientes"  
    replace nprov=8     if prov=="Entre Rios" 
    replace nprov=9     if prov=="Formosa"  
    replace nprov=14    if prov=="Misiones"  
    replace nprov=2     if prov=="Catamarca" 
    replace nprov=10    if prov=="Jujuy" 
    replace nprov=12    if prov=="La Rioja" 
    replace nprov=17    if prov=="Salta" 
    replace nprov=22    if prov=="Santiago del Estero" 
    replace nprov=24    if prov=="Tucuman" 
    replace nprov=16    if prov=="Rio Negro" 
    replace nprov=15    if prov=="Neuquen" 
    replace nprov=4     if prov=="Chubut" 
    replace nprov=20    if prov=="Santa Cruz" 
    replace nprov=23    if prov=="Tierra del Fuego" 

    gen año=substr(period,3,4)
    destring año, replace

    bysort prov año: egen isap_prom = mean(isap_trajt)
    bysort prov año: gen aux=_n
    keep if aux==1

    keep año prov nprov isap_prom

    bysort nprov: gen aux=_n
    gen aux_isap=.
    replace aux_isap=isap_prom if aux==8
    drop aux

    bysort npro: egen aux=mean(aux_isap)
    drop aux_isap

    gen isap_trajt=.
    replace isap_trajt=isap_prom/aux*100
    label var isap_trajt "ISAP TRAJTENBERG 2004 = 100"

    drop aux
    rename isap_prom isap_97

    save "${path_datain}\PBG\base_isap_trajt.dta", replace

    * ############ BASE CEPAL
    noi display in yellow "IMPORTANDO BASE CEPAL Y REALIZANDO CALCULOS"

    * importo base de coeficientes de la CEPAL
    import excel "${path_datain}\PBG\Originales\jurisdiccion_52sectores - PBG CEPAL.xlsx", sheet("Coeficiente") firstrow case(lower) clear
    
    save "${path_datain}\PBG\Originales\pbg_cepal_aux\\coeficiente_pbg.dta", replace

    * importo base de pbg de cepal
    import excel "${path_datain}\PBG\Originales\jurisdiccion_52sectores - PBG CEPAL.xlsx", sheet("Subir") firstrow case(lower) clear

    rename (jurisdicción total) (año argentina)

    loc prov = "ciudaddebuenosaires buenosaires catamarca córdoba corrientes chaco chubut entreríos formosa jujuy lapampa larioja mendoza misiones neuquén ríonegro salta sanjuan sanluis santacruz santafe santiagodelestero tucumán tierradelfuego nodistribuido argentina"

    gen provincia=""

    foreach var in `prov' {

        preserve
        keep año provincia `var'
        rename `var' pbg_cepal_pb
        replace prov="`var'"
        save "${path_datain}\PBG\Originales\pbg_cepal_aux\\`var'.dta", replace
        restore
    }    

    loc prov = "ciudaddebuenosaires catamarca córdoba corrientes chaco chubut entreríos formosa jujuy lapampa larioja mendoza misiones neuquén ríonegro salta sanjuan sanluis santacruz santafe santiagodelestero tucumán tierradelfuego"

    use "${path_datain}\PBG\Originales\pbg_cepal_aux\buenosaires.dta", clear

    foreach var in `prov' {
        merge 1:1 año provincia using "${path_datain}\PBG\Originales\pbg_cepal_aux\\`var'.dta", gen(_merge_`var')
        erase "${path_datain}\PBG\Originales\pbg_cepal_aux\\`var'.dta"
    }

    merge m:1 año using "${path_datain}\PBG\Originales\pbg_cepal_aux\coeficiente_pbg.dta", gen(_merge_coef)
    drop _merge*

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="buenosaires"
    replace prov = "Catamarca"                  if provincia=="catamarca"
    replace prov = "Chaco"                      if provincia=="chaco"
    replace prov = "Chubut"                     if provincia=="chubut"
    replace prov = "Ciudad Autonoma de BA"      if provincia=="ciudaddebuenosaires"
    replace prov = "Cordoba"                    if provincia=="córdoba"
    replace prov = "Corrientes"                 if provincia=="corrientes"
    replace prov = "Entre Rios"                 if provincia=="entreríos"
    replace prov = "Formosa"                    if provincia=="formosa"
    replace prov = "Jujuy"                      if provincia=="jujuy"
    replace prov = "La Pampa"                   if provincia=="lapampa"
    replace prov = "La Rioja"                   if provincia=="larioja"
    replace prov = "Mendoza"                    if provincia=="mendoza"
    replace prov = "Misiones"                   if provincia=="misiones"
    replace prov = "Neuquen"                    if provincia=="neuquén"
    replace prov = "Rio Negro"                  if provincia=="ríonegro"
    replace prov = "Salta"                      if provincia=="salta"
    replace prov = "San Juan"                   if provincia=="sanjuan"
    replace prov = "San Luis"                   if provincia=="sanluis"
    replace prov = "Santa Cruz"                 if provincia=="santacruz"
    replace prov = "Santa Fe"                   if provincia=="santafe"
    replace prov = "Santiago del Estero"        if provincia=="santiagodelestero"
    replace prov = "Tierra del Fuego"           if provincia=="tierradelfuego"
    replace prov = "Tucuman"                    if provincia=="tucumán"

    gen nprov=.
    replace nprov=1     if prov=="Buenos Aires" 
    replace nprov=5     if prov=="Ciudad Autonoma de BA"
    replace nprov=6     if prov=="Cordoba" 
    replace nprov=21    if prov=="Santa Fe" 
    replace nprov=11    if prov=="La Pampa" 
    replace nprov=13    if prov=="Mendoza" 
    replace nprov=18    if prov=="San Juan"  
    replace nprov=19    if prov=="San Luis" 
    replace nprov=3     if prov=="Chaco"   
    replace nprov=7     if prov=="Corrientes"  
    replace nprov=8     if prov=="Entre Rios" 
    replace nprov=9     if prov=="Formosa"  
    replace nprov=14    if prov=="Misiones"  
    replace nprov=2     if prov=="Catamarca" 
    replace nprov=10    if prov=="Jujuy" 
    replace nprov=12    if prov=="La Rioja" 
    replace nprov=17    if prov=="Salta" 
    replace nprov=22    if prov=="Santiago del Estero" 
    replace nprov=24    if prov=="Tucuman" 
    replace nprov=16    if prov=="Rio Negro" 
    replace nprov=15    if prov=="Neuquen" 
    replace nprov=4     if prov=="Chubut" 
    replace nprov=20    if prov=="Santa Cruz" 
    replace nprov=23    if prov=="Tierra del Fuego" 

    gen pbg_cepal = pbg_cepal_pb * coeficiente

    loc ipi_1993_2004 = 160.364461966938
    *loc ipc_1993_2004 = 158.0417
    loc ipc_1993_2004 = 157.6521

    gen pbg_cepal_ipi = pbg_cepal*100/`ipi_1993_2004'
    gen pbg_cepal_ipc = pbg_cepal*100/`ipc_1993_2004'

    label var año           "Año" 
    label var pbg_cepal_pb  "PBG CEPAL - millones de pesos de 2004 - precios basicos"
    label var pbg_cepal     "PBG CEPAL - millones de pesos de 2004"
    label var pbg_cepal_ipi "PBG CEPAL - millones de pesos de 1993"
    label var pbg_cepal_ipc "PBG CEPAL - millones de pesos de 1993"

    save "${path_datain}\PBG\pbg_cepal.dta", replace

    * ############ MERGE BASES
    noi display in yellow "MERGEANDO BASES PBG"

    use "${path_datain}\PBG\pbg_puig.dta", clear

    merge 1:1 año nprov prov using "${path_datain}\PBG\pbg_mecon.dta", gen(_merge_pbg_mecon)
    merge m:m año using "${path_datain}\PBG\pbi_arg.dta", gen(_merge_pbi) keepusing(pbi_ipi pbi_ipc)
    merge m:1 año nprov using "${path_datain}\PBG\pbg_indec.dta", gen(_merge_indec) keepusing(pbg_indec_ipi pbg_indec_ipc)
    merge 1:1 año nprov using "${path_datain}\PBG\base_isap_tromb.dta", gen(_merge_isap_tromb) keepusing(isap_tromb)
    merge 1:1 año nprov using "${path_datain}\PBG\base_isap_trajt.dta", gen(_merge_isap_trajt) keepusing(isap_trajt)
    merge 1:1 año nprov using "${path_datain}\PBG\pbg_cepal.dta", gen(_merge_pbg_cepal) keepusing(pbg_cepal_ipi pbg_cepal_ipc)

    replace prov="Buenos Aires"             if nprov==1  
    replace prov="Ciudad Autonoma de BA"    if nprov==5  
    replace prov="Cordoba"                  if nprov==6  
    replace prov="Santa Fe"                 if nprov==21 
    replace prov="La Pampa"                 if nprov==11 
    replace prov="Mendoza"                  if nprov==13 
    replace prov="San Juan"                 if nprov==18 
    replace prov="San Luis"                 if nprov==19 
    replace prov="Chaco"                    if nprov==3  
    replace prov="Corrientes"               if nprov==7  
    replace prov="Entre Rios"               if nprov==8  
    replace prov="Formosa"                  if nprov==9  
    replace prov="Misiones"                 if nprov==14 
    replace prov="Catamarca"                if nprov==2  
    replace prov="Jujuy"                    if nprov==10 
    replace prov="La Rioja"                 if nprov==12 
    replace prov="Salta"                    if nprov==17 
    replace prov="Santiago del Estero"      if nprov==22 
    replace prov="Tucuman"                  if nprov==24 
    replace prov="Rio Negro"                if nprov==16 
    replace prov="Neuquen"                  if nprov==15 
    replace prov="Chubut"                   if nprov==4  
    replace prov="Santa Cruz"               if nprov==20 
    replace prov="Tierra del Fuego"         if nprov==23 

    bysort nprov: egen aux_isap_ipi=mean(pbg_indec_ipi)
    bysort nprov: egen aux_isap_ipc=mean(pbg_indec_ipc)

    gen pbg_isap_tromb_ipi = .
    gen pbg_isap_tromb_ipc = .
    gen pbg_isap_trajt_ipi = .
    gen pbg_isap_trajt_ipc = .

    format %20.2f pbg_isap_tromb_ipi
    format %20.2f pbg_isap_tromb_ipc
    format %20.2f pbg_isap_trajt_ipi
    format %20.2f pbg_isap_trajt_ipc

    replace pbg_isap_tromb_ipi = aux_isap_ipi * isap_tromb / 100
    replace pbg_isap_tromb_ipc = aux_isap_ipc * isap_tromb / 100
    replace pbg_isap_trajt_ipi = aux_isap_ipi * isap_trajt / 100
    replace pbg_isap_trajt_ipc = aux_isap_ipc * isap_trajt / 100

    drop aux_isap*

    * variables de pbi como suma de los pbg
    loc vars "pbg_puig_ipi pbg_puig_ipc pbg_mecon_ipi pbg_mecon_ipc pbg_isap_tromb_ipi pbg_isap_tromb_ipc pbg_isap_trajt_ipi pbg_isap_trajt_ipc pbg_cepal_ipi pbg_cepal_ipc isap_tromb isap_trajt"
    foreach var in `vars' {
        sort nprov año
        bysort año: egen pbi_`var' = sum(`var')
        replace pbi_`var' = . if pbi_`var'==0
    }
    

    * armo la variable de región y las dummies regionales

    gen nreg = .

    replace nreg = 1 if nprov == 1 | nprov == 6 | nprov == 8 | nprov == 11 | nprov == 21
    replace nreg = 2 if nprov == 13 | nprov == 18 | nprov == 19
    replace nreg = 3 if nprov == 3 | nprov == 5 | nprov == 7 | nprov == 9 | nprov == 14
    replace nreg = 4 if nprov == 2 | nprov == 10 | nprov == 12 | nprov == 17 | nprov == 22 | nprov == 24
    replace nreg = 5 if nprov == 4 | nprov == 15 | nprov == 16 | nprov == 20 | nprov == 23

    gen region = ""

    replace region = "pampeana" 	if nreg == 1
    replace region = "cuyo" 		if nreg == 2
    replace region = "noa" 			if nreg == 3
    replace region = "nea" 			if nreg == 4
    replace region = "patagonia" 	if nreg == 5

    * genero dummies regionales
    gen pampeana=0
    gen cuyo=0
    gen noa=0
    gen nea=0
    gen patagonia=0

    replace pampeana=1 if nreg==1
    replace cuyo=1 if nreg==2
    replace nea=1 if nreg==3
    replace noa=1 if nreg==4
    replace patagonia=1 if nreg==5
    
   * eliminamos las varibles de pbi isap porque no tienen logica. 
    drop pbi_isap*
    drop _merge*

    sort año nprov
    order año nprov prov pbg* isap* pbi*

    label var año                       "Año" 
    label var nprov                     "Código de Provincia"
    label var prov                      "Nombre de Provincia"
    label var nreg                      "Código de Región"
    label var region                    "Nombre de la Región"
    label var pampeana                  "Dummy Región Pampeana"
    label var cuyo                      "Dummy Región Cuyo"
    label var noa                       "Dummy Región NOA"
    label var nea                       "Dummy Región NEA"
    label var patagonia                 "Dummy Región Patagonia"

    label var pbg_puig_ipi              "PBG PUIG (1991-2014) - millones de pesos de 1993 - Utilizando IPI"
    label var pbg_puig_ipc              "PBG PUIG (1991-2014) - millones de pesos de 1993 - Utilizando IPC"

    label var pbg_mecon_ipi             "PBG MECON (1991-2020-faltantes) - millones de pesos de 1993 - Utilizando IPI"
    label var pbg_mecon_ipc             "PBG MECON (1991-2020-faltantes) - millones de pesos de 1993 - Utilizando IPC"

    label var pbg_indec_ipi             "PBG INDEC (2004) - millones de pesos de 1993 - Utilizando IPI"
    label var pbg_indec_ipc             "PBG INDEC (2004) - millones de pesos de 1993 - Utilizando IPC"

    label var pbg_cepal_ipi             "PBG CEPAL (2004 - 2021) - millones de pesos de 1993 - Utilizando IPI"
    label var pbg_cepal_ipc             "PBG CEPAL (2004 - 2021) - millones de pesos de 1993 - Utilizando IPC"

    label var pbg_isap_tromb_ipi        "PBG ISAP (1997-2016) (PBG INDEC*ISAP) - millones de pesos de 1993 - Trombetta - Utilizando IPI"
    label var pbg_isap_tromb_ipc        "PBG ISAP (1997-2016) (PBG INDEC*ISAP) - millones de pesos de 1993 - Trombetta - Utilizando IPC"
    label var pbg_isap_trajt_ipi        "PBG ISAP (1997-2016) (PBG INDEC*ISAP) - millones de pesos de 1993 - Trajtenberg - Utilizando IPI"
    label var pbg_isap_trajt_ipc        "PBG ISAP (1997-2016) (PBG INDEC*ISAP) - millones de pesos de 1993 - Trajtenberg - Utilizando IPC"

    label var isap_tromb                "Indice Sintetico de Actividad Provincial - base 2004=100 - Trombetta"
    label var isap_trajt                "Indice Sintetico de Actividad Provincial - base 2004=100 - Trajtenberg "

    label var pbi_ipi                   "PBI NACIONAL - millones de pesos de 1993 - Utilizando IPI"
    label var pbi_ipc                   "PBI NACIONAL - millones de pesos de 1993 - Utilizando IPC"

    label var pbi_pbg_puig_ipi          "Suma de PBG PUIG por año - Utilizando IPI"
    label var pbi_pbg_puig_ipc          "Suma de PBG PUIG por año - Utilizando IPC"

    label var pbi_pbg_mecon_ipi         "Suma de PBG MECON por año - Utilizando IPI"
    label var pbi_pbg_mecon_ipc         "Suma de PBG MECON por año - Utilizando IPC"

    label var pbi_pbg_cepal_ipi         "Suma de PBG CEPAL por año - Utilizando IPI"
    label var pbi_pbg_cepal_ipc         "Suma de PBG CEPAL por año - Utilizando IPC"

    label var pbi_pbg_isap_tromb_ipi    "Suma de PBG ISAP por año - Trombetta - Utilizando IPI"
    label var pbi_pbg_isap_tromb_ipc    "Suma de PBG ISAP por año - Trombetta - Utilizando IPC"
    label var pbi_pbg_isap_trajt_ipi    "Suma de PBG ISAP por año - Trajtenberg - Utilizando IPI"
    label var pbi_pbg_isap_trajt_ipc    "Suma de PBG ISAP por año - Trajtenberg - Utilizando IPC"

    drop if año>2021
    
    noi display in yellow "GUARDANDO BASE PBG COMPLETA"
    save "${path_datain}\Bases Finales - Prepara Base\pbg_base_completa.dta", replace
    

}







/*

gen x_total_04=.
replace x_total_04=x_total_uss*100/100 if año==2004
replace x_total_04=x_total_uss*100/103.39 if año==2005
replace x_total_04=x_total_uss*100/106.73 if año==2006
replace x_total_04=x_total_uss*100/109.77 if año==2007
replace x_total_04=x_total_uss*100/113.99 if año==2008
replace x_total_04=x_total_uss*100/113.58 if año==2009
replace x_total_04=x_total_uss*100/115.44 if año==2010
replace x_total_04=x_total_uss*100/119.09 if año==2011
replace x_total_04=x_total_uss*100/121.55 if año==2012
replace x_total_04=x_total_uss*100/123.33 if año==2013
replace x_total_04=x_total_uss*100/125.33 if año==2014
replace x_total_04=x_total_uss*100/125.48 if año==2015
replace x_total_04=x_total_uss*100/127.07 if año==2016
replace x_total_04=x_total_uss*100/129.77 if año==2017
replace x_total_04=x_total_uss*100/132.94 if año==2018
replace x_total_04=x_total_uss*100/135.35 if año==2019
replace x_total_04=x_total_uss*100/137.02 if año==2020
replace x_total_04=x_total_uss*100/143.46 if año==2021

con eso llevás a dólares de 2004 (lo podés usar para otra variable)

replace x_total_04= x_total_04*2.9415  

con eso lo pasas a pesos de 2004

2.9415 es el tc promedio 2004