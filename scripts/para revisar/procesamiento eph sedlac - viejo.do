****************************************************************************************************************************************
*        AGERGAR PROVINCIAS A BASE EPH CEDLAS (POR AGLOMERADO - USANDO CRITERIO DIRECCION NACIONAL ASUNTOS PROVINCIALES - DNAP)
****************************************************************************************************************************************
************************************************ EPH PUNTUALES *****************************************************************
/*
glo año_punt = "1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002"

foreach i in $año_punt {

	capture use "${path_datain}\EPH\EPH CEDLAS\cedlas - 91-2003\02\arg_`i'_eph_v01_m_v02_a_sedlac_02.dta", clear
	if _rc==601{
	display in red "no existe base"
	}
	if _rc!=601 {
		
		clonevar aglomerado=reg_aglomera
        *AGLOMERADOS POR PROVINCIA
		gen prov=""
		replace prov="Buenos Aires" if aglomerado==2 | aglomerado==3 | aglomerado==33 | aglomerado==34 | aglomerado==38 
		replace prov="Ciudad Autonoma de BA" if aglomerado==32 
		replace prov="Cordoba" if aglomerado==13 | aglomerado==36  
		replace prov="Santa Fe" if aglomerado==4 | aglomerado==5 
		replace prov="La Pampa" if aglomerado==30
		replace prov="Mendoza" if aglomerado==10 
		replace prov="San Juan" if aglomerado==27  
		replace prov="San Luis" if aglomerado==26
		replace prov="Chaco" if aglomerado==8  
		replace prov="Corrientes" if aglomerado==12  
		replace prov="Entre Rios" if aglomerado==6 | aglomerado==14 
		replace prov="Formosa" if aglomerado==15  
		replace prov="Misiones" if aglomerado==7  
		replace prov="Catamarca" if aglomerado==22
		replace prov="Jujuy" if aglomerado==19
		replace prov="La Rioja" if aglomerado==25
		replace prov="Salta" if aglomerado==23
		replace prov="Santiago del Estero" if aglomerado==18 
		replace prov="Tucuman" if aglomerado==29
		replace prov="Rio Negro" if aglomerado==93 
		replace prov="Neuquen" if aglomerado==17
		replace prov="Chubut" if aglomerado==9 | aglomerado==91
		replace prov="Santa Cruz" if aglomerado==20
		replace prov="Tierra del Fuego" if aglomerado==31 
		
		gen nprov=.
		replace nprov=1 if prov=="Buenos Aires" 
		replace nprov=5 if prov=="Ciudad Autonoma de BA" 
		replace nprov=6 if prov=="Cordoba" 
		replace nprov=21 if prov=="Santa Fe" 
		replace nprov=11 if prov=="La Pampa" 
		replace nprov=13 if prov=="Mendoza" 
		replace nprov=18 if prov=="San Juan"  
		replace nprov=19 if prov=="San Luis" 
		replace nprov=3 if prov=="Chaco"   
		replace nprov=7 if prov=="Corrientes"  
		replace nprov=8 if prov=="Entre Rios" 
		replace nprov=9 if prov=="Formosa"  
		replace nprov=14 if prov=="Misiones"  
		replace nprov=2 if prov=="Catamarca" 
		replace nprov=10 if prov=="Jujuy" 
		replace nprov=12 if prov=="La Rioja" 
		replace nprov=17 if prov=="Salta" 
		replace nprov=22 if prov=="Santiago del Estero" 
		replace nprov=24 if prov=="Tucuman" 
		replace nprov=16 if prov=="Rio Negro" 
		replace nprov=15 if prov=="Neuquen" 
		replace nprov=4 if prov=="Chubut" 
		replace nprov=20 if prov=="Santa Cruz" 
		replace nprov=23 if prov=="Tierra del Fuego" 

        rename ipcf ipcf_cedlas

        save "${path_datain}\EPH\EPH CEDLAS\provincias\arg_`i'_eph_v01_m_v02_a_sedlac_02_prov.dta", replace
    }
}

exit
*/

*********************************************** EPH CONTINUAS *****************************************************************
glo año = "03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21"
glo sem = "1 2"

foreach i in $año {

	foreach j in $sem {

		capture use "${path_datain}\EPH\EPH CEDLAS\original\ARG_20`i'_EPHC-S`j'_v03_M_v01_A_SEDLAC-03_all.dta", clear

		if _rc==601{
		display in red "NO EXISTE BASE EPHC_20`i'_T`j'"
		}

		if _rc!=601 {
			
			display in yellow "REALIZANDO CALCULOS EN BASE EPHC_20`i'_T`j'"

            *AGLOMERADOS POR PROVINCIA
			gen prov=""
			replace prov="Buenos Aires" if aglomerado==2 | aglomerado==3 | aglomerado==33 | aglomerado==34 | aglomerado==38 
			replace prov="Ciudad Autonoma de BA" if aglomerado==32 
			replace prov="Cordoba" if aglomerado==13 | aglomerado==36  
			replace prov="Santa Fe" if aglomerado==4 | aglomerado==5 
			replace prov="La Pampa" if aglomerado==30
			replace prov="Mendoza" if aglomerado==10 
			replace prov="San Juan" if aglomerado==27  
			replace prov="San Luis" if aglomerado==26
			replace prov="Chaco" if aglomerado==8  
			replace prov="Corrientes" if aglomerado==12  
			replace prov="Entre Rios" if aglomerado==6 | aglomerado==14 
			replace prov="Formosa" if aglomerado==15  
			replace prov="Misiones" if aglomerado==7  
			replace prov="Catamarca" if aglomerado==22
			replace prov="Jujuy" if aglomerado==19
			replace prov="La Rioja" if aglomerado==25
			replace prov="Salta" if aglomerado==23
			replace prov="Santiago del Estero" if aglomerado==18 
			replace prov="Tucuman" if aglomerado==29
			replace prov="Rio Negro" if aglomerado==93 
			replace prov="Neuquen" if aglomerado==17
			replace prov="Chubut" if aglomerado==9 | aglomerado==91
			replace prov="Santa Cruz" if aglomerado==20
			replace prov="Tierra del Fuego" if aglomerado==31 

			gen nprov=.
			replace nprov=1 if prov=="Buenos Aires" 
			replace nprov=5 if prov=="Ciudad Autonoma de BA" 
			replace nprov=6 if prov=="Cordoba" 
			replace nprov=21 if prov=="Santa Fe" 
			replace nprov=11 if prov=="La Pampa" 
			replace nprov=13 if prov=="Mendoza" 
			replace nprov=18 if prov=="San Juan"  
			replace nprov=19 if prov=="San Luis" 
			replace nprov=3 if prov=="Chaco"   
			replace nprov=7 if prov=="Corrientes"  
			replace nprov=8 if prov=="Entre Rios" 
			replace nprov=9 if prov=="Formosa"  
			replace nprov=14 if prov=="Misiones"  
			replace nprov=2 if prov=="Catamarca" 
			replace nprov=10 if prov=="Jujuy" 
			replace nprov=12 if prov=="La Rioja" 
			replace nprov=17 if prov=="Salta" 
			replace nprov=22 if prov=="Santiago del Estero" 
			replace nprov=24 if prov=="Tucuman" 
			replace nprov=16 if prov=="Rio Negro" 
			replace nprov=15 if prov=="Neuquen" 
			replace nprov=4 if prov=="Chubut" 
			replace nprov=20 if prov=="Santa Cruz" 
			replace nprov=23 if prov=="Tierra del Fuego" 

			* Renombrar ipcf cedlas y to string
            rename ipcf ipcf_cedlas
            destring ipcf_cedlas, replace
            capture replace ipcf_indec="." if ipcf_indec=="NA"
            destring ipcf_indec, replace

			* Generamos pondih, pondii pondiio en las bases previas a 2016 
			loc pondera = "pondii pondih pondiio"

			foreach pond in `pondera' {

				capture sum `pond'
				if _rc==111 {

					clonevar `pond' = pondera
				}
			}

			gen pet=.
        	replace pet=1 if edad>=10
        	replace pet=0 if edad<10
			label var pet "Dummy de Población en Edad de Trabajar - mayores de 10 años"

        	gen pea=.
        	replace pea=1 if estado==1 | estado==2
        	replace pea=0 if estado==3 | estado==4 | estado==0 
			label var pea "Dummy de Población Economicamente Activa - Ocupados + Desocupados"

        	gen ocupados=.
        	replace ocupados=1 if estado==1
        	replace ocupados=0 if estado==2 | estado==3 | estado==4 | estado==0 
			label var ocupados "Dummy de Población Ocupada - variable estado=1"

        	gen desocupados=.
        	replace desocupados=1 if estado==2
        	replace desocupados=0 if estado==1  
			label var desocupados "Dummy de Población Desocupada - variable estado=2"

        	gen inactivos=.
        	replace inactivos=1 if estado==3 
        	replace inactivos=0 if estado==1 | estado==2 | estado==4 | estado==0 
			label var inactivos "Dummy de Población Inactiva - variables estado=3"

			gen menor_10=.
			replace menor_10=1 if estado==4
			replace menor_10=0 if estado==1 | estado==2 | estado==3 | estado==0
			label var menor_10 "Dummy de Población fuera de la edad de trabajar - variable estado=4"
			
            save "${path_datain}\EPH\BASES FINALES\EPHC_20`i'_T`j'_proc.dta", replace
        }
    }
}
