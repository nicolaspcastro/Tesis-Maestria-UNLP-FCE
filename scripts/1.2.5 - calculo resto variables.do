****************************************************************************************************************************************
*                                          IMPORTACION Y CALCULOS DE BASES DE VARIABLES DE CONTROL
*                                                   EXPORTACIONES PROVINCIALES
*                                                   TASA DE MORTALIDAD INFANTIL, NATALIDAD
*                                                   GASTOS CORRIENTES
*                                                   TASA EMPLEO PUBLICO/INDUSTRIA/AGRICULTURA?     
****************************************************************************************************************************************
* #TODO - agregar links de descarga de las bases
clear all
set more off

noi display in green "COMENZANDO DO FILE RESTO VARIABLES"

quietly {
    
    *######################## TCN
    noi display in yellow "IMPORTANDO BASE TCN Y REALIZANDO CALCULOS"

    clear

    import excel "${path_datain}\TCN\TCN Argertina - Banco Mundial.xls", sheet("ARG-TCN") firstrow case(lower)

    destring año, replace

    save "${path_datain}\TCN\tcn_arg_completo.dta", replace

    keep if año>=1991

    label var año "Año"
    label var tcn "Tipo de Cambio Nominal - Banco Mundial"

    save "${path_datain}\TCN\tcn_arg.dta", replace

    *######################## IPC
    noi display in yellow "IMPORTANDO BASE IPC Y REALIZANDO CALCULOS"

    * MESCLO VARIAS SERIES, VER SI CONSIGO UNA COMPLETA
    * BASE DE 1943 A 2013 BASE ABRIL 2008 = 100
    clear
    import excel "${path_datain}\IPC\sh_ipc_2008.xls", sheet("Subir") firstrow case(lower)

    destring nivelgeneral, gen(ipc_abr_08) force

    format %20.10f ipc_abr_08

    * guardo base completa
    save "${path_datain}\IPC\sh_ipc_2008.dta", replace

    * corto la base a 1991 para usarla en la base final
    keep if año>=1991

    * calculo la media anual
    * #TODO - ESTA OK CALCULAR LA MEDIA? O DEBERÍA USAR LA DE DICIEMBRE? --> PARECE QUE ESTA OK
    sort año mes
    by año: egen ipc_08 = mean(ipc_abr_08)

    keep if mes==1
    drop mes nivelgeneral ipc_abr_08

    * modifico la base del indice a 1993 = 100
    gen aux = ipc_08 if año ==1993
    egen base = mean (aux) 
    drop aux
    gen ipc_93 = ipc_08 / base * 100

    save "${path_datain}\IPC\ipc_91-13.dta", replace

    *import 
    * #TODO - AGREGAR IPC 2003-2021 Y MERGEAR CON ANTERIOR. NO TENGO MESES QUE SE SOLAPEN. BUSCAR SERIE PRIVADA
    rename ipc_93 ipc

    save "${path_datain}\IPC\ipc.dta", replace

    * IPC BCRA
    clear 

    import excel "${path_datain}\IPC\infla_bcra.xlsx", sheet("datos") firstrow

    * calculo la media anual
    sort año mes
    by año: egen ipc_mean = mean(ipc_bcra)
    keep if mes==1

    drop ipc_bcra 

    * modifico la base del indice a 1993 = 100
    gen aux = ipc_mean if año ==1993
    egen base = mean (aux) 
    drop aux
    gen ipc_bcra = ipc_mean / base * 100

    keep año ipc_bcra

    label var ipc_bcra "IPC BCRA base 1993=100"

    save "${path_datain}\IPC\ipc_bcra.dta", replace


    *######################## IPI PBI 
    * #NOTE - (NO DA LOGICO CUANDO COMPARAS EL DE 1993 Y 2004)
    noi display in yellow "IMPORTANDO BASE IPI PBI Y REALIZANDO CALCULOS"

    clear
    import excel "${path_datain}\IPC\actividad_ied.xlsx", sheet("IPI-PBI") firstrow case(lower)

    * armo una local con el valor del ipi_93 para el año 2004 
    loc ipi_2004 = 160.364462

    * calculo la variación del ipi base 2004 para los años en que tengo datos
    gen var_ipi_04 = .
    replace var_ipi_04 = ((ipi_04 / ipi_04[_n-1]) - 1)

    * genero la variable para el ipi final, lo dejo como el valor para el ipi base 1993 para lo años que esta disponible, y a los datos faltantes despues de 2012 les aplico la variación del ipi base 2004 para completar la serie. Esto soluciona el problema de no poder usar un único coeficiente de empalme.
    gen ipi = .
    replace ipi = ipi_93
    replace ipi = (ipi[_n-1] * (1 + var_ipi_04)) if ipi == .

    label var año           "Año" 
    label var ipi_93        "IPI PBI base 1993=100 (1993-2012)"
    label var ipi_04        "IPI PBI base 2004=100 (2004-2021)"
    label var var_ipi_04    "Variación IPI PBI base 2004=100"
    label var ipi           "IPI PBI base 1993=100 (1993-2021) - 93 original hasta 2012 y transformado hasta 2021"  

    save "${path_datain}\IPC\ipi.dta", replace

    *######################## IPI EXPO 
    *NOTE - (TAMPOCO DA EL DE 1993 Y 2004)
    noi display in yellow "IMPORTANDO BASE IPI EXPO Y REALIZANDO CALCULOS"

    clear
    import excel "${path_datain}\IPC\actividad_ied.xlsx", sheet("IPI-EXPO") firstrow case(lower)

    * se realiza un procesamiento análogo al realizado para el ipi pbi
    loc ipi_2004 = 303.17127
    gen var_ipi_expo_04 = .
    replace var_ipi_expo_04 = ((ipi_expo_04 / ipi_expo_04[_n-1]) - 1)

    gen ipi_expo = .
    replace ipi_expo = ipi_expo_93
    replace ipi_expo = (ipi_expo[_n-1] * (1 + var_ipi_expo_04)) if ipi_expo == .

    label var año               "Año" 
    label var ipi_expo_93       "IPI Exportaciones base 1993=100 (1993-2012)"
    label var ipi_expo_04       "IPI Exportaciones base 2004=100 (2004-2021)"
    label var var_ipi_expo_04   "Variación IPI Exportaciones PBI base 2004=100"
    label var ipi_expo          "IPI Exportaciones base 1993=100 (1993-2021) - 93 original hasta 2012 y transformado hasta 2021"  

    save "${path_datain}\IPC\ipi_expo.dta", replace

    * ####### EXPORTACIONES
    noi display in yellow "IMPORTANDO BASE EXPORTACIONES Y REALIZANDO CALCULOS"

    import delimited "${path_datain}\Exportaciones\exportaciones-provincia-rubro.csv", clear

    * local con los nombres de las provincias
    loc prov = "buenos_aires catamarca chaco chubut ciudad_de_buenos_aires cordoba corrientes entre_rios formosa jujuy la_pampa la_rioja mendoza misiones  neuquen rio_negro salta san_juan san_luis santa_cruz santa_fe santiago_del_estero tierra_del_fuego tucuman"

    * genero el año a partir de la variable de indice_tiempo
    gen año=substr(indice_tiempo,1,4)
    destring año, replace

    * creo bases por provincia para despues mergearlas
    foreach p in `prov' {

        preserve
        keep año `p'*
        gen prov=""
        replace prov = "`p'" 
        rename `p'* *
        rename _total* _total 
        save "${path_datain}\Exportaciones\aux_expo\\`p'.dta", replace
        restore
    }
    
    * local de provincias para mergear
    loc prov = "catamarca chaco chubut ciudad_de_buenos_aires cordoba corrientes entre_rios formosa jujuy la_pampa la_rioja mendoza misiones  neuquen rio_negro salta san_juan san_luis santa_cruz santa_fe santiago_del_estero tierra_del_fuego tucuman"

    * abro base para buenos aires y mergeo las demás
    use "${path_datain}\Exportaciones\aux_expo\buenos_aires.dta", clear

    * #REVIEW - esto es un append en terminos practicos no?
    foreach var in `prov' {

        merge 1:1 año prov using "${path_datain}\Exportaciones\aux_expo\\`var'.dta", gen(_merge_`var')
        erase "${path_datain}\Exportaciones\aux_expo\\`var'.dta"
    }
    * #TODO - eliminar las bases auxiliares despues de mergear
    drop _merge*

    order año prov
    rename prov provincia

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="buenos_aires"
    replace prov = "Catamarca"                  if provincia=="catamarca"
    replace prov = "Chaco"                      if provincia=="chaco"
    replace prov = "Chubut"                     if provincia=="chubut"
    replace prov = "Ciudad Autonoma de BA"      if provincia=="ciudad_de_buenos_aires"
    replace prov = "Cordoba"                    if provincia=="cordoba"
    replace prov = "Corrientes"                 if provincia=="corrientes"
    replace prov = "Entre Rios"                 if provincia=="entre_rios"
    replace prov = "Formosa"                    if provincia=="formosa"
    replace prov = "Jujuy"                      if provincia=="jujuy"
    replace prov = "La Pampa"                   if provincia=="la_pampa"
    replace prov = "La Rioja"                   if provincia=="la_rioja"
    replace prov = "Mendoza"                    if provincia=="mendoza"
    replace prov = "Misiones"                   if provincia=="misiones"
    replace prov = "Neuquen"                    if provincia=="neuquen"
    replace prov = "Rio Negro"                  if provincia=="rio_negro"
    replace prov = "Salta"                      if provincia=="salta"
    replace prov = "San Juan"                   if provincia=="san_juan"
    replace prov = "San Luis"                   if provincia=="san_luis"
    replace prov = "Santa Cruz"                 if provincia=="santa_cruz"
    replace prov = "Santa Fe"                   if provincia=="santa_fe"
    replace prov = "Santiago del Estero"        if provincia=="santiago_del_estero"
    replace prov = "Tierra del Fuego"           if provincia=="tierra_del_fuego"
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

    rename _* expo_*_uss

    drop provincia 

    order año nprov prov

    * #NOTE - dejamos de lado las expo de plataforma continental y las de origen indeterminado

    save "${path_datain}\Exportaciones\expo_prov_original.dta", replace

    * #REVIEW - las expo están en dolares corrientes?
    * las exportaciones están en dolares corrientes así que mergeamos variables de tipo de cambio, ipi e ipc para pasarlo a valores constantes
    merge m:1 año using "${path_datain}\TCN\tcn_arg.dta", gen(_merge_tcn)
    merge m:1 año using "${path_datain}\IPC\ipi.dta", gen(_merge_ipi) keepusing(ipi)
    merge m:1 año using "${path_datain}\IPC\ipi_expo.dta", gen(_merge_ipi_expo) keepusing(ipi_expo)
    *merge m:1 año using "${path_datain}\IPC\ipc.dta", gen(_merge_ipc) keepusing(ipc)
    merge m:1 año using "${path_datain}\IPC\ipc_bcra.dta", gen(_merge_ipc) keepusing(ipc_bcra)
    rename ipc_bcra ipc

    * eliminos observaciones que no mergearon en las bases using de tcn e ipc
    drop if _merge_tcn == 2
    drop if _merge_ipc == 2
    drop _merge*

    * genero las variables de expo medido en distintas monedas
    loc expo = "expo_pp expo_moa expo_moi expo_cye expo_total"
    foreach x in `expo' {

            gen `x'_pesos       = `x'_uss * tcn
            gen `x'_ipi_expo    = `x'_pesos * 100 / ipi_expo
            gen `x'_ipi         = `x'_pesos * 100 / ipi
            gen `x'_ipc         = `x'_pesos * 100 / ipc
    }

    label var año                   "Año" 
    label var nprov                 "Código Provincia" 
    label var prov                  "Nombre Provincia" 

    label var expo_pp_uss           "Exportaciones Productos Primarios - millones de dólares corrientes" 
    label var expo_moa_uss          "Exportaciones MOA - millones de dólares corrientes" 
    label var expo_moi_uss          "Exportaciones MOI - millones de dólares corrientes" 
    label var expo_cye_uss          "Exportaciones Combustibles y Energía - millones de dólares corrientes" 
    label var expo_total_uss        "Exportaciones Totales - millones de dólares corrientes" 

    label var expo_pp_pesos         "Exportaciones Productos Primarios - millones de pesos corrientes" 
    label var expo_moa_pesos        "Exportaciones MOA - millones de pesos corrientes" 
    label var expo_moi_pesos        "Exportaciones MOI - millones de pesos corrientes" 
    label var expo_cye_pesos        "Exportaciones Combustibles y Energía - millones de pesos corrientes" 
    label var expo_total_pesos      "Exportaciones Totales - millones de pesos corrientes" 

    label var expo_pp_ipi           "Exportaciones Productos Primarios - millones de pesos de 1993 - Utilizando IPI" 
    label var expo_moa_ipi          "Exportaciones MOA - millones de pesos de 1993 - Utilizando IPI" 
    label var expo_moi_ipi          "Exportaciones MOI - millones de pesos de 1993 - Utilizando IPI" 
    label var expo_cye_ipi          "Exportaciones Combustibles y Energía - millones de pesos de 1993 - Utilizando IPI" 
    label var expo_total_ipi        "Exportaciones Totales - millones de pesos de 1993 - Utilizando IPI"

    label var expo_pp_ipi_expo      "Exportaciones Productos Primarios - millones de pesos de 1993 - Utilizando IPI EXPO" 
    label var expo_moa_ipi_expo     "Exportaciones MOA - millones de pesos de 1993 - Utilizando IPI EXPO" 
    label var expo_moi_ipi_expo     "Exportaciones MOI - millones de pesos de 1993 - Utilizando IPI EXPO" 
    label var expo_cye_ipi_expo     "Exportaciones Combustibles y Energía - millones de pesos de 1993 - Utilizando IPI EXPO" 
    label var expo_total_ipi_expo   "Exportaciones Totales - millones de pesos de 1993 - Utilizando IPI EXPO"

    label var expo_pp_ipc           "Exportaciones Productos Primarios - millones de pesos de 1993 - Utilizando IPC" 
    label var expo_moa_ipc          "Exportaciones MOA - millones de pesos de 1993 - Utilizando IPC" 
    label var expo_moi_ipc          "Exportaciones MOI - millones de pesos de 1993 - Utilizando IPC" 
    label var expo_cye_ipc          "Exportaciones Combustibles y Energía - millones de pesos de 1993 - Utilizando IPC" 
    label var expo_total_ipc        "Exportaciones Totales - millones de pesos de 1993 - Utilizando IPC"


    save "${path_datain}\Exportaciones\expo_prov_completo.dta", replace
     
    * guardo base de exportaciones por provincia solo con las variables de exportaciones. 
    keep año nprov prov expo_pp* expo_moa* expo_moi* expo_cye* expo_total*

    save "${path_datain}\Exportaciones\expo_prov.dta", replace

    * ####### Exportaciones por País de Destino
    noi display in yellow "IMPORTANDO BASE EXPO DESTINO Y REALIZANDO CALCULOS"

    clear

    import delimited "${path_datain}\Exportaciones\exportaciones-por-provincia-por-pais-de-destino-valores-anuales.csv"
    * #NOTE - link https://datos.gob.ar/no/dataset/sspm-exportaciones-por-provincia-por-pais-destino
    * #NOTE - luego de 2017 baja mucho la disponibilidad de datos

    * genero variable de año en función de la variable indice_tiempo
    gen año=substr(indice_tiempo,1,4)
    destring año, replace
    drop indice_tiempo

    loc prov "pba catamarca chaco chubut caba cordoba corrientes entre_rios formosa jujuy la_pampa la_rioja mendoza misiones neuquen rio_negro salta san_juan san_luis santa_cruz santa_fe santiago_del_estero tierra_del_fuego tucuman"

    * genero bases por provincia para despues mergear
    foreach p in `prov' {
        
        preserve
        keep año `p'*
        gen provincia = "`p'"
        rename `p'_* *
        rename total* total

        save "${path_datain}\Exportaciones\aux_expo_destino\\`p'.dta", replace

        restore
    }
    * #TODO - eliminar las bases auxialiares despues de merear

    loc prov "catamarca chaco chubut caba cordoba corrientes entre_rios formosa jujuy la_pampa la_rioja mendoza misiones neuquen rio_negro salta san_juan san_luis santa_cruz santa_fe santiago_del_estero tierra_del_fuego tucuman"

    use "${path_datain}\Exportaciones\aux_expo_destino\pba.dta", clear

    * merge de bases pro provincia
    foreach p in `prov' {

        append using "${path_datain}\Exportaciones\aux_expo_destino\\`p'.dta", gen(_merge_`p')
        erase "${path_datain}\Exportaciones\aux_expo_destino\\`p'.dta"
    }

    order año provincia total 
    drop _merge*

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="pba"
    replace prov = "Catamarca"                  if provincia=="catamarca"
    replace prov = "Chaco"                      if provincia=="chaco"
    replace prov = "Chubut"                     if provincia=="chubut"
    replace prov = "Ciudad Autonoma de BA"      if provincia=="caba"
    replace prov = "Cordoba"                    if provincia=="cordoba"
    replace prov = "Corrientes"                 if provincia=="corrientes"
    replace prov = "Entre Rios"                 if provincia=="entre_rios"
    replace prov = "Formosa"                    if provincia=="formosa"
    replace prov = "Jujuy"                      if provincia=="jujuy"
    replace prov = "La Pampa"                   if provincia=="la_pampa"
    replace prov = "La Rioja"                   if provincia=="la_rioja"
    replace prov = "Mendoza"                    if provincia=="mendoza"
    replace prov = "Misiones"                   if provincia=="misiones"
    replace prov = "Neuquen"                    if provincia=="neuquen"
    replace prov = "Rio Negro"                  if provincia=="rio_negro"
    replace prov = "Salta"                      if provincia=="salta"
    replace prov = "San Juan"                   if provincia=="san_juan"
    replace prov = "San Luis"                   if provincia=="san_luis"
    replace prov = "Santa Cruz"                 if provincia=="santa_cruz"
    replace prov = "Santa Fe"                   if provincia=="santa_fe"
    replace prov = "Santiago del Estero"        if provincia=="santiago_del_estero"
    replace prov = "Tierra del Fuego"           if provincia=="tierra_del_fuego"
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

    drop provincia 

    order año nprov prov

    * #NOTE - DEJAMOS DE LADO LAS EXPO DE PLATAFORMA CONTINENTAL Y LAS DE ORIGEN INDETERMINADO

    save "${path_datain}\Exportaciones\expo_destino_original.dta", replace
    
    * merge de bases de datos de tipo de cambio nominal e ipi_expo para expresar en pesos y dolares constantes 
    merge m:1 año using "${path_datain}\TCN\tcn_arg.dta", gen(_merge_tcn)
    merge m:1 año using "${path_datain}\IPC\ipi_expo.dta", gen(_merge_ipi_expo) keepusing(ipi_expo)

    * eliminamos variables que están en base using de tcn
    drop if _merge_tcn == 2
    drop _merge*
    rename zf_zonamerica_ex_montev zf_uruguay

    * renombramos variables
    loc expo = "total brasil estados_unidos chile china uruguay paraguay mexico paises_bajos alemania venezuela resto japon republica_corea espania finlandia filipinas bulgaria canada india italia indonesia egipto colombia hong_kong vietnam iraq rusia reino_unido argelia peru belgica arabia_saudita ecuador siria francia sudafrica bolivia suiza zf_uruguay malasia"

    foreach x in `expo' {

        rename `x' expo_`x'_uss 
        gen expo_`x'_pesos = expo_`x'_uss * tcn
        gen expo_`x' = expo_`x'_pesos * 100 / ipi_expo
    }

    drop *_pesos *_uss

    * label de variables
    label var año                   "Año" 
    label var nprov                 "Código Provincia"
    label var prov                  "Nombre Provincia"
    label var expo_total            "Exportaciones Totales - millones de pesos de 1993"
    label var expo_brasil           "Exportaciones a Brasil - millones de pesos de 1993"
    label var expo_estados_unidos   "Exportaciones a Estados Unidos - millones de pesos de 1993"
    label var expo_chile            "Exportaciones a Chile - millones de pesos de 1993"
    label var expo_china            "Exportaciones a China - millones de pesos de 1993"
    label var expo_uruguay          "Exportaciones a Uruguay - millones de pesos de 1993"
    label var expo_paraguay         "Exportaciones a Paraguay - millones de pesos de 1993"
    label var expo_mexico           "Exportaciones a Mexico - millones de pesos de 1993"
    label var expo_paises_bajos     "Exportaciones a Paises Bajos - millones de pesos de 1993"
    label var expo_alemania         "Exportaciones a Alemania - millones de pesos de 1993"
    label var expo_venezuela        "Exportaciones a Venezuela - millones de pesos de 1993"
    label var expo_resto            "Exportaciones a Otros Países - millones de pesos de 1993"
    label var expo_japon            "Exportaciones a Japon - millones de pesos de 1993"
    label var expo_republica_corea  "Exportaciones a Republica de Corea - millones de pesos de 1993"
    label var expo_espania          "Exportaciones a España - millones de pesos de 1993"
    label var expo_finlandia        "Exportaciones a Finlandia - millones de pesos de 1993"
    label var expo_filipinas        "Exportaciones a Filipinas - millones de pesos de 1993"
    label var expo_bulgaria         "Exportaciones a Bulgaria - millones de pesos de 1993"
    label var expo_canada           "Exportaciones a Canada - millones de pesos de 1993"
    label var expo_india            "Exportaciones a India - millones de pesos de 1993"
    label var expo_italia           "Exportaciones a Italia - millones de pesos de 1993"
    label var expo_indonesia        "Exportaciones a Indonesia - millones de pesos de 1993"
    label var expo_egipto           "Exportaciones a Egipto - millones de pesos de 1993"
    label var expo_colombia         "Exportaciones a Colombia - millones de pesos de 1993"
    label var expo_hong_kong        "Exportaciones a Hong Kong - millones de pesos de 1993"
    label var expo_vietnam          "Exportaciones a Vietnam - millones de pesos de 1993"
    label var expo_iraq             "Exportaciones a Iraq - millones de pesos de 1993"
    label var expo_rusia            "Exportaciones a Rusia - millones de pesos de 1993"
    label var expo_reino_unido      "Exportaciones a Reino Unido - millones de pesos de 1993"
    label var expo_argelia          "Exportaciones a Argelia - millones de pesos de 1993"
    label var expo_peru             "Exportaciones a Peru - millones de pesos de 1993"
    label var expo_belgica          "Exportaciones a Belgica - millones de pesos de 1993"
    label var expo_arabia_saudita   "Exportaciones a Arabaia Saudita - millones de pesos de 1993"
    label var expo_ecuador          "Exportaciones a Ecuador - millones de pesos de 1993"
    label var expo_siria            "Exportaciones a Siria - millones de pesos de 1993"
    label var expo_francia          "Exportaciones a Francia - millones de pesos de 1993"
    label var expo_sudafrica        "Exportaciones a Sudafrica - millones de pesos de 1993"
    label var expo_bolivia          "Exportaciones a Bolivia - millones de pesos de 1993"
    label var expo_suiza            "Exportaciones a Suiza - millones de pesos de 1993"
    label var expo_zf_uruguay       "Exportaciones a Zona Franca Uruguay - millones de pesos de 1993"
    label var expo_malasia          "Exportaciones a Malasia - millones de pesos de 1993"

    * renombro variables con codigo de tres digitos
    rename expo_brasil           expo_bra
    rename expo_estados_unidos   expo_usa
    rename expo_chile            expo_chl
    rename expo_china            expo_chn
    rename expo_uruguay          expo_ury
    rename expo_paraguay         expo_pry
    rename expo_mexico           expo_mex
    rename expo_paises_bajos     expo_nld
    rename expo_alemania         expo_deu
    rename expo_venezuela        expo_ven
    rename expo_japon            expo_jpn
    rename expo_republica_corea  expo_kor
    rename expo_espania          expo_esp
    rename expo_finlandia        expo_fin
    rename expo_filipinas        expo_phl
    rename expo_bulgaria         expo_bgr
    rename expo_canada           expo_can
    rename expo_india            expo_ind
    rename expo_italia           expo_ita
    rename expo_indonesia        expo_idn
    rename expo_egipto           expo_egy
    rename expo_colombia         expo_col
    rename expo_hong_kong        expo_hkg
    rename expo_vietnam          expo_vnm
    rename expo_iraq             expo_irq
    rename expo_rusia            expo_rus
    rename expo_reino_unido      expo_gbr
    rename expo_argelia          expo_dza
    rename expo_peru             expo_per
    rename expo_belgica          expo_bel
    rename expo_arabia_saudita   expo_sau
    rename expo_ecuador          expo_ecu
    rename expo_siria            expo_syr
    rename expo_francia          expo_fra
    rename expo_sudafrica        expo_zaf
    rename expo_bolivia          expo_bol
    rename expo_suiza            expo_che
    rename expo_zf_uruguay       expo_zf_ury
    rename expo_malasia          expo_mys

    save "${path_datain}\Exportaciones\expo_pais_destino.dta", replace

    * ####### POBLACIÓN 
    noi display in yellow "IMPORTANDO BASE POBLACION Y REALIZANDO CALCULOS"

    * importo base de indicadores provinciales
    use "${path_datain}\PBG\Originales\indicadores-provinciales.dta", clear

    * me quedo con las variables de población 
    keep if actividad_producto_nombre == "Población"
    keep indicador unidad_de_medida fuente alcance_nombre indice_tiempo valor
    drop unidad_de_medida indicador fuente

    * renombramos variables y ponemos nombres de provincias
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

    order año indice_tiempo nprov provincia prov valor

    rename valor poblacion

    * labels de variables
    label var año                   "Año" 
    label var indice_tiempo         "Indice de Tiempo" 
    label var nprov                 "Código de Provincia" 
    label var provincia             "Nombre Provincia Original" 
    label var prov                  "Nombre Provincia Base" 
    label var poblacion             "Población"

    * guardamos base de proyección de población post 2010
    save "${path_datain}\Población\proyeccion_pob.dta", replace

    clear
    import excel "${path_datain}\Población\Población 91-01-10.xlsx", sheet("pob 91-01-10") firstrow case(lower)
    * #NOTE - IMPORTAMOS LA BASE CON LA POBLACION OFICIAL DEL CENSO DEL 2010 Y LA DE LAS PROYECCIONES. BORRAMOS LA DEL CENSO OFICIAL ASÍ NO LO USAMOS, LUEGO BORRO TAMBIEN LA DEL 2010 (PORQUE MERGEA PROYECCIONES DESDE 2010)

    * me quedo con las variables de población para 2010 de las proyecciones, no de las del CENSO, porque son las finales. 
    drop pob_2010_censo dens_2010_censo
    rename (pob_2010_proy dens_2010_proy) (pob_2010 dens_2010)

    * armo bases por separado para cada CENSO 
    loc año = "1991 2001 2010"
    foreach a in `año' {

        preserve
        keep provincia superficie_km_2 pob_`a' dens_`a'
        gen año = `a'
        rename pob* poblacion
        rename dens* densidad

        save "${path_datain}\Población\pob_`a'.dta", replace

        restore
    }

    use "${path_datain}\Población\pob_1991.dta", clear

    merge 1:1 provincia año using "${path_datain}\Población\pob_2001.dta", gen(_merge_2001)
    merge 1:1 provincia año using "${path_datain}\Población\pob_2010.dta", gen(_merge_2010)

    drop _merge*

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="Buenos Aires"
    replace prov = "Catamarca"                  if provincia=="Catamarca"
    replace prov = "Chaco"                      if provincia=="Chaco"	
    replace prov = "Chubut"                     if provincia=="Chubut"		
    replace prov = "Ciudad Autonoma de BA"      if provincia=="Ciudad Autónoma de Buenos Aires"
    replace prov = "Cordoba"                    if provincia=="Córdoba"
    replace prov = "Corrientes"                 if provincia=="Corrientes"	
    replace prov = "Entre Rios"                 if provincia=="Entre Ríos"
    replace prov = "Formosa"                    if provincia=="Formosa"	
    replace prov = "Jujuy"                      if provincia=="Jujuy"	
    replace prov = "La Pampa"                   if provincia=="La Pampa"
    replace prov = "La Rioja"                   if provincia=="La Rioja"
    replace prov = "Mendoza"                    if provincia=="Mendoza"	
    replace prov = "Misiones"                   if provincia=="Misiones"
    replace prov = "Neuquen"                    if provincia=="Neuquén"	
    replace prov = "Rio Negro"                  if provincia=="Río Negro"
    replace prov = "Salta"                      if provincia=="Salta"	
    replace prov = "San Juan"                   if provincia=="San Juan"
    replace prov = "San Luis"                   if provincia=="San Luis"
    replace prov = "Santa Cruz"                 if provincia=="Santa Cruz"
    replace prov = "Santa Fe"                   if provincia=="Santa Fe"
    replace prov = "Santiago del Estero"        if provincia=="Santiago del Estero"
    replace prov = "Tierra del Fuego"           if provincia=="Tierra del Fuego"
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

    order año prov nprov superficie_km_2 poblacion densidad
    drop provincia 

    * genero un coeficiente que toma la variaición entre CENSOS y lo eleva a 1/t, siendo t la cantidad de años entre CENSOS
    gen coef_pob = .
    sort nprov año
    bysort nprov: replace coef_pob=(poblacion/poblacion[_n-1])^(1/10) if año == 2001 

    sort nprov año
    bysort nprov: replace coef_pob=(poblacion/poblacion[_n-1])^(1/9)  if año == 2010 

    * merge con base auxiliar de población que tienen la estructura de la base final (años y provincias)
    merge 1:1 nprov año using "${path_datain}\Población\base_aux_pob.dta", gen(_merge_aux)

    * genero variable de potencia, que determina el año dentro de la serie 
    gen potencia = .
    sort nprov año
    bysort nprov: replace potencia = _n if año > 1991 & año < 2001  

    sort nprov año
    bysort nprov: replace potencia = _n if año > 2001 & año < 2010  

    * resto 1 a las observaciones entre 1991 y 2001, y resto 11 a las observaciones entre 2001 y 2010 para que queden numeradas del 1 al 10/11
    replace potencia = potencia - 1 if año > 1991 & año < 2001
    replace potencia = potencia - 11 if año > 2001 & año < 2010

    * calculo la media de coef_pob para cada provincia para que quede en todos los años. Uno para pre 2001 y otro post 2001 y despues aplico row total para quedarme con una sola variable con ambos datos.
    sort nprov año
    bysort nprov: egen coef_pob_1 = mean(coef_pob) if año <= 2001
    bysort nprov: egen coef_pob_2 = mean(coef_pob) if año > 2001
    egen coef_pob_3 = rowtotal(coef_pob_1 coef_pob_2)
    drop coef_pob coef_pob_1 coef_pob_2
    rename coef_pob_3 coef_pob

    * hago el mismo procedimiento para la población
    sort nprov año
    bysort nprov: egen pob_aux_1 = mean(poblacion) if año < 2001
    bysort nprov: egen pob_aux_2 = mean(poblacion) if año >= 2001 & año < 2010
    egen pob_aux = rowtotal(pob_aux_1 pob_aux_2)
    drop pob_aux_1 pob_aux_2

    format %10.0g pob_aux

    * calculo la población para cada año como la población del año inicial (1991 y 2001) * coef_pob^potencia
    loc años = "1992 1993 1994 1995 1996 1997 1998 1999 2000 2002 2003 2004 2005 2006 2007 2008 2009"
    foreach a in `años' {

        sort nprov año
        bysort nprov: replace poblacion = pob_aux * (coef_pob)^(potencia) if año == `a'
    }

    * formateo las variables de población
    gen pob2=round(poblacion)
    recast long pob2
    format %10.0g pob2

    drop pob_aux poblacion _merge_aux coef_pob potencia
    rename pob2 poblacion 

    * elimino los datos de 2010 porque uso las de la base de estimación
    drop if año==2010

    * #NOTE - CABA TIENE UNA CAÍDA DE LA POBLACION ENTRE 1991 Y 2001 (CEHQUEAR SI ESTÁ OK)

    * mergeo con base de proyecciones de población (2010 en adelante)
    * #NOTE - no mergea nada porque en realidad quiero pegarlo abajo
    merge 1:1 nprov año using "${path_datain}\Población\proyeccion_pob.dta", gen(_merge_proy)

    drop _merge* provincia indice_tiempo

    * relleno el dato de superficie para los post 2010 y luego calculo la densidad poblacional 
    sort nprov año
    bysort nprov: egen sup_aux = mean(superficie_km_2)
    replace superficie_km_2 = sup_aux if superficie_km_2 == .
    drop sup_aux

    replace densidad = poblacion / superficie_km_2 if densidad == .

    * label variables
    label var año               "Año" 
    label var nprov             "Código de Provincia" 
    label var prov              "Nombre Provincia" 
    label var poblacion         "Población"
    label var superficie_km_2   "Superficie de la Provincia - en km cuadrados" 
    label var densidad          "Densidad Poblacional - Población / Superficie"

    * guardo base completa
    save "${path_datain}\Población\pob_1991-2025.dta", replace

    drop if año>2021

    * guardo base hasta 2021
    save "${path_datain}\Población\poblacion.dta", replace


    * ####### Tasas salud
    noi display in yellow "IMPORTANDO BASE SALUD Y REALIZANDO CALCULOS"

    * importo base de tasa de mortalidad infantil
    clear
    import delimited "${path_datain}\Otros\tasa-mortalidad-infantil-deis-1990-2020.csv", clear

    gen año=substr(indice_tiempo,1,4)
    destring año, replace
    drop indice_tiempo

    * genero bases auxiliares y las mergeo
    loc prov "caba buenosaires catamarca cordoba corrientes chaco chubut entrerios formosa jujuy lapampa larioja mendoza misiones neuquen rionegro salta sanjuan sanluis santacruz santafe santiagodele tierradelfue tucuman"

    foreach p in `prov' {
        
        preserve
        keep año *`p'
        gen provincia = "`p'"
        rename *_`p' *

        save "${path_datain}\Otros\aux_mort\\`p'.dta", replace

        restore
    }

    loc prov "caba catamarca cordoba corrientes chaco chubut entrerios formosa jujuy lapampa larioja mendoza misiones neuquen rionegro salta sanjuan sanluis santacruz santafe santiagodele tierradelfue tucuman"

    use "${path_datain}\Otros\aux_mort\buenosaires.dta", clear

    foreach p in `prov' {

        append using "${path_datain}\Otros\aux_mort\\`p'.dta", gen(_merge_`p')
        erase "${path_datain}\Otros\aux_mort\\`p'.dta"
    }

    * renombro variables
    rename mortalidad_infantil tasa_mort_inf
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
    replace prov = "Santiago del Estero"        if provincia=="santiagodele"
    replace prov = "Tierra del Fuego"           if provincia=="tierradelfue"
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

    drop provincia

    label var año               "Año" 
    label var nprov             "Código Provincia"
    label var prov              "Nombre Provincia"
    label var tasa_mort_inf     "Tasa de Mortalidad Infantil (1990-2020)"

    order año nprov prov tasa_mort_inf

    * guardo base de mortalidad infantil
    save "${path_datain}\Otros\tasa_mort_inf.dta", replace

    * ####### Remuneración bruta promedio sector privado
    noi display in yellow "IMPORTANDO BASE REMUNERACION Y REALIZANDO CALCULOS"

    * importo base de remuneración provada mensual
    clear
    import excel "${path_datain}\Archivos DNAP\10_Remuneracion_bruta_privada_mensual.xlsx", sheet("Subir") firstrow case(lower)

    rename jurisdicción provincia

    * genero bases auxiliares por año y mergeo
    loc año "1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"

    foreach a in `año' {

        preserve
        keep provincia _`a'
        gen año = `a'
        rename _`a' rbpm_sipa 

        save "${path_datain}\Archivos DNAP\aux_remuneracion_bruta\\`a'.dta", replace

        restore
    }

    use "${path_datain}\Archivos DNAP\aux_remuneracion_bruta\\1995.dta", clear

    loc año "1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"

    foreach a in `año' {

        append using "${path_datain}\Archivos DNAP\aux_remuneracion_bruta\\`a'.dta"
        erase "${path_datain}\Archivos DNAP\aux_remuneracion_bruta\\`a'.dta"

    }

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="Buenos Aires"
    replace prov = "Catamarca"                  if provincia=="Catamarca"
    replace prov = "Chaco"                      if provincia=="Chaco"
    replace prov = "Chubut"                     if provincia=="Chubut"
    replace prov = "Ciudad Autonoma de BA"      if provincia=="C.A.B.A"
    replace prov = "Cordoba"                    if provincia=="Corrientes"
    replace prov = "Corrientes"                 if provincia=="Córdoba"
    replace prov = "Entre Rios"                 if provincia=="Entre Ríos"
    replace prov = "Formosa"                    if provincia=="Formosa"
    replace prov = "Jujuy"                      if provincia=="Jujuy"
    replace prov = "La Pampa"                   if provincia=="La Pampa"
    replace prov = "La Rioja"                   if provincia=="La Rioja"
    replace prov = "Mendoza"                    if provincia=="Mendoza"
    replace prov = "Misiones"                   if provincia=="Misiones"
    replace prov = "Neuquen"                    if provincia=="Neuquén"
    replace prov = "Rio Negro"                  if provincia=="Río Negro"
    replace prov = "Salta"                      if provincia=="Salta"
    replace prov = "San Juan"                   if provincia=="San Juan"
    replace prov = "San Luis"                   if provincia=="San Luis"
    replace prov = "Santa Cruz"                 if provincia=="Santa Cruz"
    replace prov = "Santa Fe"                   if provincia=="Santa Fe"
    replace prov = "Santiago del Estero"        if provincia=="Santiago del Estero"
    replace prov = "Tierra del Fuego"           if provincia=="Tierra del Fuego"
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

    drop provincia

    merge m:1 año using "${path_datain}\IPC\ipi.dta", gen(_merge_ipi) keepusing(ipi)
    *merge m:1 año using "${path_datain}\IPC\ipc.dta", gen(_merge_ipc) keepusing(ipc)
    merge m:1 año using "${path_datain}\IPC\ipc_bcra.dta", gen(_merge_ipc) keepusing(ipc_bcra)
    rename ipc_bcra ipc


    gen rbpm_sipa_ipi = rbpm_sipa * 100 / ipi
    gen rbpm_sipa_ipc = rbpm_sipa * 100 / ipc

    order año nprov prov rbpm_sipa*

    label var año           "Año"
    label var nprov         "Código Provincia"
    label var prov          "Nombre Provincia"
    label var rbpm_sipa     "Remuneración Bruta Privada Mensual (SIPA - 1995-2017) - Pesos Corrientes"
    label var rbpm_sipa_ipi "Remuneración Bruta Privada Mensual (SIPA - 1995-2017) - Pesos de 1993 - IPI"
    label var rbpm_sipa_ipc "Remuneración Bruta Privada Mensual (SIPA - 1995-2017) - Pesos de 1993 - IPC"

    drop if _merge_ipi==2
    drop if _merge_ipc==2
    drop _merge*
    drop ipc ipi

    save "${path_datain}\Archivos DNAP\rbpm_sipa_dnap.dta", replace

    * ####### Indice de Desarrollo Humano (1996-2001-2006-2011-2016) (se puede usar uno por periodo)
    noi display in yellow "IMPORTANDO BASE IDH Y REALIZANDO CALCULOS"

    * importo base de DNAP
    clear
    import excel "${path_datain}\Archivos DNAP\27_Indice_de_Desarrollo_Humano.xlsx", sheet("Subir") firstrow case(lower)

    rename jurisdicción provincia

    * armo un archivo por año y mergeo
    loc año "1996 2001 2006 2011 2016"

    foreach a in `año' {

        preserve
        keep provincia _`a'
        gen año = `a'
        rename _`a' idh 

        save "${path_datain}\Archivos DNAP\aux_des_hum\\`a'.dta", replace

        restore
    }

    use "${path_datain}\Archivos DNAP\aux_des_hum\1996.dta", clear

    loc año "2001 2006 2011 2016"

    foreach a in `año' {

        append using "${path_datain}\Archivos DNAP\aux_des_hum\\`a'.dta"
        erase "${path_datain}\Archivos DNAP\aux_des_hum\\`a'.dta"

    }

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="Buenos Aires"
    replace prov = "Catamarca"                  if provincia=="Catamarca"
    replace prov = "Chaco"                      if provincia=="Chaco"
    replace prov = "Chubut"                     if provincia=="Chubut"
    replace prov = "Ciudad Autonoma de BA"      if provincia=="C.A.B.A"
    replace prov = "Cordoba"                    if provincia=="Corrientes"
    replace prov = "Corrientes"                 if provincia=="Córdoba"
    replace prov = "Entre Rios"                 if provincia=="Entre Ríos"
    replace prov = "Formosa"                    if provincia=="Formosa"
    replace prov = "Jujuy"                      if provincia=="Jujuy"
    replace prov = "La Pampa"                   if provincia=="La Pampa"
    replace prov = "La Rioja"                   if provincia=="La Rioja"
    replace prov = "Mendoza"                    if provincia=="Mendoza"
    replace prov = "Misiones"                   if provincia=="Misiones"
    replace prov = "Neuquen"                    if provincia=="Neuquén"
    replace prov = "Rio Negro"                  if provincia=="Río Negro"
    replace prov = "Salta"                      if provincia=="Salta"
    replace prov = "San Juan"                   if provincia=="San Juan"
    replace prov = "San Luis"                   if provincia=="San Luis"
    replace prov = "Santa Cruz"                 if provincia=="Santa Cruz"
    replace prov = "Santa Fe"                   if provincia=="Santa Fe"
    replace prov = "Santiago del Estero"        if provincia=="Santiago del Estero"
    replace prov = "Tierra del Fuego"           if provincia=="Tierra del Fuego"
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

    drop provincia

    order año nprov prov idh

    label var año           "Año"
    label var nprov         "Código Provincia"
    label var prov          "Nombre Provincia"
    label var idh           "Indice de Desarrollo Humano - DNAP (96-01-06-11-16)"

    * #NOTE FALTAN DATOS DE RIO NEGRO PARA 1996 Y 2001 PORQUE NO ESTABA EN LAS EPH PUNTUALES (CHEQUEARLO PORQUE CREO QUE SI). VER SI SE PUEDE BUSCAR Y ARMAR EL DATO, SINO ESTIMARLO CON LAS PROVINCIAS CERCANAS. SE MUEVE PARECIDO A LA PAMPA PERO EN UN NIVEL MAS BAJO EN 2006, 2011 Y 2016

    save "${path_datain}\Archivos DNAP\idh_dnap.dta", replace

    * ####### Puestos de Trabajo del sector privado formal (1996-2017) 
    noi display in yellow "IMPORTANDO BASE TRABAJO Y REALIZANDO CALCULOS"

    * importo la base de empleo privado formal
    clear
    import excel "${path_datain}\Archivos DNAP\81_Empleo_privado_formal.xlsx", sheet("Subir") firstrow case(lower)

    rename jurisdicción provincia

    * armo archivo por año y mergeo
    loc año "1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"

    foreach a in `año' {

        preserve
        keep provincia _`a'
        gen año = `a'
        rename _`a' ptspf_sipa 

        save "${path_datain}\Archivos DNAP\aux_puestos_trab\\`a'.dta", replace

        restore
    }

    use "${path_datain}\Archivos DNAP\aux_puestos_trab\\1996.dta", clear

    loc año "1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017"

    foreach a in `año' {

        append using "${path_datain}\Archivos DNAP\aux_puestos_trab\\`a'.dta"
        erase "${path_datain}\Archivos DNAP\aux_puestos_trab\\`a'.dta"

    }

    gen prov=""
    replace prov = "Buenos Aires"               if provincia=="Buenos Aires"
    replace prov = "Catamarca"                  if provincia=="Catamarca"
    replace prov = "Chaco"                      if provincia=="Chaco"
    replace prov = "Chubut"                     if provincia=="Chubut"
    replace prov = "Ciudad Autonoma de BA"      if provincia=="C.A.B.A"
    replace prov = "Cordoba"                    if provincia=="Corrientes"
    replace prov = "Corrientes"                 if provincia=="Córdoba"
    replace prov = "Entre Rios"                 if provincia=="Entre Ríos"
    replace prov = "Formosa"                    if provincia=="Formosa"
    replace prov = "Jujuy"                      if provincia=="Jujuy"
    replace prov = "La Pampa"                   if provincia=="La Pampa"
    replace prov = "La Rioja"                   if provincia=="La Rioja"
    replace prov = "Mendoza"                    if provincia=="Mendoza"
    replace prov = "Misiones"                   if provincia=="Misiones"
    replace prov = "Neuquen"                    if provincia=="Neuquén"
    replace prov = "Rio Negro"                  if provincia=="Río Negro"
    replace prov = "Salta"                      if provincia=="Salta"
    replace prov = "San Juan"                   if provincia=="San Juan"
    replace prov = "San Luis"                   if provincia=="San Luis"
    replace prov = "Santa Cruz"                 if provincia=="Santa Cruz"
    replace prov = "Santa Fe"                   if provincia=="Santa Fe"
    replace prov = "Santiago del Estero"        if provincia=="Santiago del Estero"
    replace prov = "Tierra del Fuego"           if provincia=="Tierra del Fuego"
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

    drop provincia

    order año nprov prov ptspf_sipa

    label var año           "Año"
    label var nprov         "Código Provincia"
    label var prov          "Nombre Provincia"
    label var ptspf_sipa     "Puestos de Trabajo en el Sector Privado Formal (SIPA - 1996-2017)"

    * guardo base
    save "${path_datain}\Archivos DNAP\ptspf_sipa_dnap.dta", replace

    
    * ####### Depositos en moneda local y Extranjera + Prestamos al sector privado (2001 a 2022) - Miles de pesos corrientes
    
    * #REVIEW Chquear si estan en pesos corrientes
    
    noi display in yellow "IMPORTANDO BASE DESPOSITOS Y PRESTAMOS Y REALIZANDO CALCULOS"

    * importo base de indicadores provinciales de donde sale el dato
    use "${path_datain}\PBG\Originales\indicadores-provinciales.dta", clear

    * me quedo con las observaciones de prestamos y depositos, pero quedandome con el nombre de a quien se presta / quien deposita
    keep if actividad_producto_nombre == "Sector Privado no financiero" | actividad_producto_nombre == "Sector Público no financiero"

    replace actividad_producto_nombre= "priv" if actividad_producto_nombre == "Sector Privado no financiero"
    replace actividad_producto_nombre= "pub" if actividad_producto_nombre == "Sector Público no financiero"

    save "${path_datain}\Otros\dep_prest.dta", replace
    loc indicador = "priv pub"

    * bucle que guarda una base para prestamos y otro para depositos
    foreach indic in `indicador' {

        use "${path_datain}\Otros\dep_prest.dta", clear

        * me quedo con las observaciones del indicador del bucle y las variables necesarias
        keep if actividad_producto_nombre == "`indic'"
        keep indicador unidad_de_medida indice_tiempo valor alcance_nombre

        * elimino observaciones de 2022 
        drop if indice_tiempo == "2022-01-01"

        * renombro el indicador como nombre de variable para cuando haga el reshape
        replace indicador = "depositos_`indic'" if indicador == "Depósitos_Moneda local y extranjera" 
        replace indicador = "prestamos_`indic'" if indicador == "Préstamos_Moneda local y extranjera"

        loc vars "depositos_`indic' prestamos_`indic'"

        * armo una base para cada variable de deposito y prestamo y renombro las variables necesarias (y otras cosas de limpieza)
        foreach var in `vars' {

            preserve
            keep if indicador == "`var'"
            drop indicador
            rename valor `var'

            gen año=substr(indice_tiempo,1,4)
            destring año, replace
            drop indice_tiempo
            rename alcance_nombre provincia

            bysort año provincia: egen `var'_aux_mean = mean(`var')
            bysort año provincia: egen `var'_aux_sum = sum(`var')
            bysort año provincia: egen `var'_aux_sd = sd(`var')
            * #REVIEW - ESTA OK CALCULAR LA MEDIA, O DEBERIA SER LA SUMA DE LOS 4 TRIMESTRES?
            format %12.0g `var'_aux_mean

            bysort año provincia: gen aux = _n
            keep if aux == 1
            drop aux `var' unidad_de_medida
            rename (`var'_aux_mean `var'_aux_sum `var'_aux_sd) (`var'_mean `var'_sum `var'_sd)  

            save "${path_datain}\Otros\aux_dep_prest\\`indic'\\`var'.dta", replace

            restore
        }
    }

    * armo archivo conjunto de depositos y prestamos para cada indicador (publico privado) y genero las variables para el merge final
    foreach indic in `indicador' {

        use "${path_datain}\Otros\aux_dep_prest\\`indic'\depositos_`indic'.dta", clear

        merge 1:1 año provincia using "${path_datain}\Otros\aux_dep_prest\\`indic'\prestamos_`indic'.dta", gen (_merge_prest)

        sort provincia año

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

        drop provincia

        * merge de ipi e ipc para paras a precios de 1993
        merge m:1 año using "${path_datain}\IPC\ipi.dta", gen(_merge_ipi) keepusing(ipi)
        *merge m:1 año using "${path_datain}\IPC\ipc.dta", gen(_merge_ipc) keepusing(ipc)
        merge m:1 año using "${path_datain}\IPC\ipc_bcra.dta", gen(_merge_ipc) keepusing(ipc_bcra)
        rename ipc_bcra ipc

        * borro observaciones que no mergean 
        drop if _merge_ipi==2
        drop _merge*

        * renombro variables a corrientes y despues paso a pesos de 1993 con ipi ipc
        loc stats = "mean sum" 
        foreach st in `stats' {

            rename (depositos_`indic'_`st' prestamos_`indic'_`st') (depositos_`indic'_`st'_corr prestamos_`indic'_`st'_corr)
            gen depositos_`indic'_`st'_ipi = depositos_`indic'_`st'_corr * 100 / ipi
            gen prestamos_`indic'_`st'_ipi = prestamos_`indic'_`st'_corr * 100 / ipi
            gen depositos_`indic'_`st'_ipc = depositos_`indic'_`st'_corr * 100 / ipc
            gen prestamos_`indic'_`st'_ipc = prestamos_`indic'_`st'_corr * 100 / ipc
        }
        

        format %10.0g prestamos_`indic'* depositos_`indic'*

        save "${path_datain}\Otros\\`indic'.dta", replace
    }

    * merge de todos los indicadores privados y públicos
    use "${path_datain}\Otros\priv.dta", clear

    merge 1:1 año nprov using "${path_datain}\Otros\pub.dta", gen(_merge) keepusing(prestamos* depositos*)

    * el drop de tiempo es por seguridad, no debería haber observaciones menores a 2001
    drop if año<2000
    drop _merge*
    drop ipi ipc

    label var año                           "Año"
    label var prov                          "Nombre Provincia"
    label var nprov                         "Código Provincia"

    label var depositos_priv_mean_corr      "Depósitos Privados - media anual - Precios corrientes"
    label var depositos_priv_sum_corr       "Depósitos Privados - total anual - Precios corrientes"
    label var depositos_priv_sd             "Depósitos Privados - Desvio Estándar"

    label var prestamos_priv_mean_corr      "Prestamos Privados - media anual - Precios corrientes"
    label var prestamos_priv_sum_corr       "Prestamos Privados - total anual - Precios corrientes"
    label var prestamos_priv_sd             "Prestamos Privados - Desvio Estándar"

    label var depositos_priv_mean_ipi       "Depósitos Privados - media anual - Precios de 1993 - IPI"
    label var prestamos_priv_mean_ipi       "Prestamos Privados - media anual - Precios de 1993 - IPI"
    label var depositos_priv_mean_ipc       "Depósitos Privados - media anual - Precios de 1993 - IPC"
    label var prestamos_priv_mean_ipc       "Prestamos Privados - media anual - Precios de 1993 - IPC"

    label var depositos_priv_sum_ipi        "Depósitos Privados - total anual - Precios de 1993 - IPI"
    label var prestamos_priv_sum_ipi        "Prestamos Privados - total anual - Precios de 1993 - IPI"
    label var depositos_priv_sum_ipc        "Depósitos Privados - total anual - Precios de 1993 - IPC"
    label var prestamos_priv_sum_ipc        "Prestamos Privados - total anual - Precios de 1993 - IPC"

    label var depositos_pub_mean_corr       "Depósitos Públicos - media anual - Precios corrientes"
    label var depositos_pub_sum_corr        "Depósitos Públicos - total anual - Precios corrientes"
    label var depositos_pub_sd              "Depósitos Públicos - Desvio Estándar"

    label var prestamos_pub_mean_corr       "Prestamos Públicos - media anual - Precios corrientes"
    label var prestamos_pub_sum_corr        "Prestamos Públicos - total anual - Precios corrientes"
    label var prestamos_pub_sd              "Prestamos Públicos - Desvio Estándar"

    label var depositos_pub_mean_ipi        "Depósitos Públicos - media anual - Precios de 1993 - IPI"
    label var prestamos_pub_mean_ipi        "Prestamos Públicos - media anual - Precios de 1993 - IPI"
    label var depositos_pub_mean_ipc        "Depósitos Públicos - media anual - Precios de 1993 - IPC"
    label var prestamos_pub_mean_ipc        "Prestamos Públicos - media anual - Precios de 1993 - IPC"

    label var depositos_pub_sum_ipi         "Depósitos Públicos - total anual - Precios de 1993 - IPI"
    label var prestamos_pub_sum_ipi         "Prestamos Públicos - total anual - Precios de 1993 - IPI"
    label var depositos_pub_sum_ipc         "Depósitos Públicos - total anual - Precios de 1993 - IPC"
    label var prestamos_pub_sum_ipc         "Prestamos Públicos - total anual - Precios de 1993 - IPC"

    * guardo base
    save "${path_datain}\Otros\dep_prest_completa.dta", replace

    
    * ####### MERGE BASES DE VARIABLES DE CONTROL
    * merge de todas las bases calculadas
    use "${path_datain}\Exportaciones\expo_prov.dta", clear

    merge m:1 año       using "${path_datain}\TCN\tcn_arg.dta",                      gen(_merge_tcn)
    *merge m:1 año       using "${path_datain}\IPC\ipc.dta",                          gen(_merge_ipc)
    merge m:1 año       using "${path_datain}\IPC\ipc_bcra.dta",                     gen(_merge_ipc_bcra)
    merge m:1 año       using "${path_datain}\IPC\ipi.dta",                          gen(_merge_ipi) keepusing(ipi)
    merge m:1 año       using "${path_datain}\IPC\ipi_expo.dta",                     gen(_merge_ipi_expo) keepusing(ipi_expo)
    merge 1:1 año nprov using "${path_datain}\Exportaciones\expo_pais_destino.dta",  gen(_merge_expo_pais_dest)
    merge 1:1 año nprov using "${path_datain}\Población\poblacion.dta",              gen(_merge_pob)
    merge 1:1 año nprov using "${path_datain}\Otros\tasa_mort_inf.dta",              gen(_merge_mort)
    merge 1:1 año nprov using "${path_datain}\Archivos DNAP\rbpm_sipa_dnap.dta",     gen(_merge_rbpm)
    merge 1:1 año nprov using "${path_datain}\Archivos DNAP\idh_dnap.dta",           gen(_merge_idh)
    merge 1:1 año nprov using "${path_datain}\Archivos DNAP\ptspf_sipa_dnap.dta",    gen(_merge_ptspf)    
    merge 1:1 año nprov using "${path_datain}\Otros\dep_prest_completa.dta",         gen(_merge_dep_prest)
    merge 1:1 año nprov using "${path_datain}\Empleo\empleo_nt.dta",                  gen(_merge_empleo_nt)

    drop _merge*

    * elimino las observaciones previas a 1991
    drop if año == 1990

    noi display in yellow "GUARDANDO BASE RESTO VARIABLES DE CONTROL"
    save "${path_datain}\Bases Finales - Prepara Base\variables_control.dta", replace

    *armar de nuevo serie de empleo no transable - usar el excel de esteban

    * ####### indices provinciales varios - archivos viejo 
    /*
    import excel "${path_datain}\PBG\Originales\_old\99-indicadores-provinciales-basecompleta.xlsx", sheet("Otros Datos") firstrow case(lower)

    save "${path_datain}\PBG\Originales\indicadores_prov_viejo.dta", replace
    */
    
}