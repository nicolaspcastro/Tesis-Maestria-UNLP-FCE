******************* CALCULO DE COEFICIENTE DE GINI POR PROVINCIA - BUCLE PARA TODAS LAS EPH******************************************

clear all

/*
*****************************************RESTPUESTA MAIL CONT****************************************************************
Fijate si la principal diferencia son los niveles o la evolución. Mi sospecha es que debés tener un problema de niveles.
Esto se debe a la construcción propia del Gini. En ese paper (si mal no recuerdo porque esa base la hicimos hace unos 8-10 años), armamos quintiles (por personas, no por hogares) por provincia y el Gini se calculó para quintiles, y para 120 unidades de ingreso a nivel nacional (24x5).
No usamos stata o similar, más allá de la ayuda para sumar el ingreso de a grupos de 20% de población x jurisdicción. Una vez que tuvimos estos datos, cálculo hicimos cálculo por fórmula en excel.
Creo que hicimos alguna ponderación cuando la provincia tiene más de una EPH.
De todo esto, mi mayor sospecha es que la diferencia entre lo que hacés y nuestros números es lo de quintiles (la desigualdad con N unidades es mayor o igual que la desigualdad con M unidades, para N>M, por definición nomás).

*/

***** APPEND DE TODAS LAS BASES
*** TRES OPCIONES PARA LOS DOS AGLOMERADOS CON PROBLEMAS: USARLOS EN LAS DOS PROVINCIAS, USARLO EN UNA
run "${path_estim}\scripts\gini.do"




glo año = "03 04 05 06 07 08 09 10 11 12 13 14 15"
glo trim = "1 2 3 4"
loc opcion = 1
loc col
putexcel set "${path_tables}\gini.xlsx",replace


foreach j in $trim {
		 
	foreach i in $año {
		mat gini_q_`j'`i'= J(24,1,.)
		mat gini_d_`j'`i'= J(24,1,.)
		mat rownames gini_q_`j'`i' = "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Corrientes" "Córdoba" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquén" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Stgo del Estero" "Tierra del Fuego" "Tucumán" "Rio Negro"
		mat rownames gini_d_`j'`i' = "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Corrientes" "Córdoba" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquén" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Stgo del Estero" "Tierra del Fuego" "Tucumán" "Rio Negro"
		mat colnames gini_q_`j'`i' = "gini_q_`j'`i'" 
		mat colnames gini_d_`j'`i' = "gini_d_`j'`i'" 
		
		loc fila = 1
		capture use "${path_datain}\EPH\2003 - 2015\individual_t`j'`i'.dta", clear
		if _rc==601{
		display "no existe base"
		}
		if _rc!=601 {
			*AGLOMERADOS POR PROVINCIA
			gen prov=""
				
			replace prov="Buenos Aires" if aglomerado==2 | aglomerado==3 | aglomerado==33 | aglomerado==34 | aglomerado==38 
			replace prov="Ciudad Autonoma de BA" if aglomerado==32 
			replace prov="Córdoba" if aglomerado==13 | aglomerado==36  
			replace prov="Santa Fe" if aglomerado==4 | aglomerado==5 
			replace prov="La Pampa" if aglomerado==30
			
			replace prov="Mendoza" if aglomerado==10 
			replace prov="San Juan" if aglomerado==27  
			replace prov="San Luis" if aglomerado==26
			
			replace prov="Chaco" if aglomerado==8  
			replace prov="Corrientes" if aglomerado==12  
			replace prov="Entre Ríos" if aglomerado==6 | aglomerado==14 
			replace prov="Formosa" if aglomerado==15  
			replace prov="Misiones" if aglomerado==7  
			
			replace prov="Catamarca" if aglomerado==22
			replace prov="Jujuy" if aglomerado==19
			replace prov="La Rioja" if aglomerado==25
			replace prov="Salta" if aglomerado==23
			replace prov="Stgo. del Estero" if aglomerado==18 
			replace prov="Tucumán" if aglomerado==29
			
			replace prov="z_Río Negro" if aglomerado==93 
			replace prov="Neuquén" if aglomerado==17
			replace prov="Chubut" if aglomerado==9 | aglomerado==91
			replace prov="Santa Cruz" if aglomerado==20
			replace prov="Tierra del Fuego" if aglomerado==31 
			
			egen nprov=group(prov)
			
			save "${path_datain}\EPH\2003 - 2015\individual_t`j'`i'_prov.dta", replace
			levelsof nprov, loc (nprov)
			
			foreach x in `nprov' {
				preserve
			
				keep if nprov==`x'
				destring deccfr,replace
				**Limpieza Base:
				*12 y 13 es que no respondio ingreso
				drop if deccfr<1 | deccfr>10
				**hogar secundario:pensionista o servicio domestico**
				drop if nro_hogar==51 | nro_hogar==71
				
				sort ipcf
				
				gen sumpop=sum(pondera)
				*esto es para sumar ponderadores y no personas
				
				local ppdecil=sumpop[_N]/10
				*ppdecil va a tener el numero de personas en la muestra ponderadas
				
				gen decil=0
				replace decil=1 if sumpop>0 & sumpop<=`ppdecil'
				replace decil=2 if sumpop>`ppdecil' & sumpop<=(`ppdecil'*2)
				replace decil=3 if sumpop>(2*`ppdecil') & sumpop<=(`ppdecil'*3)
				replace decil=4 if sumpop>(3*`ppdecil') & sumpop<=(`ppdecil'*4)
				replace decil=5 if sumpop>(4*`ppdecil') & sumpop<=(`ppdecil'*5)
				replace decil=6 if sumpop>(5*`ppdecil') & (sumpop<=`ppdecil'*6)
				replace decil=7 if sumpop>(6*`ppdecil') & sumpop<=(`ppdecil'*7)
				replace decil=8 if sumpop>(7*`ppdecil') & (sumpop<=`ppdecil'*8)
				replace decil=9 if sumpop>(8*`ppdecil') & sumpop<=(`ppdecil'*9)
				replace decil=10 if sumpop>(9*`ppdecil') & sumpop<=(`ppdecil'*10)
				
				table decil [w=pondera], c(freq mean ipcf sum ipcf) row replace
				rename table1 freq
				rename table2 ipcf_mean 
				rename table3 sum
				run "${path_estim}\scripts\gini.do"
				gini ipcf_mean
				loc gini_d_`j'`i'=r(gini)
				mat gini_d_`j'`i' [`fila',1]=`gini_d_`j'`i''
				
				restore
				
				preserve
			
				keep if nprov==`x'
				destring deccfr,replace
				**Limpieza Base:
				*12 y 13 es que no respondio ingreso
				drop if deccfr<1 | deccfr>10
				**hogar secundario:pensionista o servicio domestico**
				drop if nro_hogar==51 | nro_hogar==71
				
				sort ipcf
				
				gen sumpop=sum(pondera)
				*esto es para sumar ponderadores y no personas
				
				local ppdecil=sumpop[_N]/10
				*ppdecil va a tener el numero de personas en la muestra ponderadas
				
				gen quintil=0
				replace quintil=1 if sumpop>0 & sumpop<=(`ppdecil'*2)
				replace quintil=2 if sumpop>(2*`ppdecil') & sumpop<=(`ppdecil'*4)
				replace quintil=3 if sumpop>(4*`ppdecil') & sumpop<=(`ppdecil'*6)
				replace quintil=4 if sumpop>(6*`ppdecil') & sumpop<=(`ppdecil'*8)
				replace quintil=5 if sumpop>(8*`ppdecil') & sumpop<=(`ppdecil'*10)
				
				table quintil [w=pondera], c(freq mean ipcf sum ipcf) row replace
				rename table1 freq
				rename table2 ipcf_mean 
				rename table3 sum
				run "${path_estim}\scripts\gini.do"
				gini ipcf_mean
				loc gini_q_`j'`i'=r(gini)
				mat gini_q_`j'`i' [`fila',1]=`gini_q_`j'`i''
				loc fila = `fila' + 1 
				
				restore
			
			}
			
		}
	}
}	



glo cuantil "d q"
foreach z in $cuantil {
	foreach j in $trim {
		foreach i in $año {
			preserve
			drop _all
			svmat gini_`z'_`j'`i', names(col)
			gen nprov=.
			replace nprov=_n
			order nprov gini_`z'_`j'`i'
			save "${path_estim}\data\data_out\gini\gini_`z'_`j'`i'.dta", replace
			restore
		}
	}
}


use "${path_estim}\data\data_out\gini\gini_d_303.dta", clear

foreach j in $trim {
		foreach i in $año {
		merge 1:1 nprov using "${path_estim}\data\data_out\gini\gini_d_`j'`i'.dta", gen(_merge)
		drop _merge
	}
}
gen aux=.
replace aux=1 if nprov==1
replace aux=2 if nprov==2
replace aux=3 if nprov==3
replace aux=4 if nprov==4
replace aux=5 if nprov==5

replace aux=6 if nprov==7
replace aux=7 if nprov==6

replace aux=8 if nprov==8
replace aux=9 if nprov==9
replace aux=10 if nprov==10
replace aux=11 if nprov==11
replace aux=12 if nprov==12
replace aux=13 if nprov==13
replace aux=14 if nprov==14
replace aux=15 if nprov==15

replace aux=16 if nprov==24
replace aux=17 if nprov==16
replace aux=18 if nprov==17
replace aux=19 if nprov==18
replace aux=20 if nprov==19
replace aux=21 if nprov==20
replace aux=22 if nprov==21
replace aux=23 if nprov==22
replace aux=24 if nprov==23

drop nprov
rename aux nprov
order nprov

save "${path_estim}\data\data_out\gini\gini_d.dta", replace

use "${path_estim}\data\data_out\gini\gini_q_303.dta", clear

foreach j in $trim {
		foreach i in $año {
		merge 1:1 nprov using "${path_estim}\data\data_out\gini\gini_q_`j'`i'.dta", gen(_merge)
		drop _merge
	}
}
gen aux=.
replace aux=1 if nprov==1
replace aux=2 if nprov==2
replace aux=3 if nprov==3
replace aux=4 if nprov==4
replace aux=5 if nprov==5

replace aux=6 if nprov==7
replace aux=7 if nprov==6

replace aux=8 if nprov==8
replace aux=9 if nprov==9
replace aux=10 if nprov==10
replace aux=11 if nprov==11
replace aux=12 if nprov==12
replace aux=13 if nprov==13
replace aux=14 if nprov==14
replace aux=15 if nprov==15

replace aux=16 if nprov==24
replace aux=17 if nprov==16
replace aux=18 if nprov==17
replace aux=19 if nprov==18
replace aux=20 if nprov==19
replace aux=21 if nprov==20
replace aux=22 if nprov==21
replace aux=23 if nprov==22
replace aux=24 if nprov==23

drop nprov
rename aux nprov
order nprov
save "${path_estim}\data\data_out\gini\gini_q.dta", replace



/*
nprov	prov
1	Buenos Aires
2	Catamarca
3	Chaco
4	Chubut

6	Córdoba
7	Corrientes

8	Entre Ríos
9	Formosa
10	Jujuy
11	La Pampa
12	La Rioja
13	Mendoza
14	Misiones
15	Neuquén

16	Río Negro
17	Salta
18	San Juan
19	San Luis
20	Santa Cruz
21	Santa Fe
22	Stgo. del Estero
23	Tierra del Fuego
24	Tucumán

1 "Buenos Aires" 
2 "Catamarca" 
3 "Chaco" 
4 "Chubut" 
5 "Ciudad Autonoma de BA" 

6 "Corrientes" 
7 "Córdoba" 

8 "Entre Ríos" 
9 "Formosa" 
10 "Jujuy" 
11 "La Pampa" 
12 "La Rioja" 
13 "Mendoza" 
14 "Misiones" 
15 "Neuquén" 
16 "Salta" 
17 "San Juan" 
18 "San Luis" 
19 "Santa Cruz" 
20"Santa Fe" 
21"Stgo del Estero" 
22"Tierra del Fuego" 
23"Tucumán" 
24"Rio Negro"
*/




/*
** Probelmas: Algomerado 38 (san nicolas-villa const) es buenos aires y santa fe - segun DNAP es buenos aires
			  Aglomerado 93 (viedma- carmen de patagones) es rio negro y buenos aires - segun DNAP es rio negro
Buenos Aires 			02 - 03 - 33 - 34 - 38
CABA 					32
Cordoba 				13 - 36 
Santa Fe 				4 - 5 
La Pampa 				30 

Mendoza 				10 
San Juan 				27  
San Luis 				26  

Chaco 					8  
Corrientes 				12 
Entre Rios 				6 - 14 
Formosa 				15
Misiones 				7 

Catamarca 				22 
Jujuy 					19 
La Rioja 				25 
Salta 					23 
Santiago del Estero 	18 
Tucuman 				29 

Rio Negro 				93
Neuquen 				17 
Chubut 					9 - 91 
Santa Cruz 				20 
Tierra del Fuego 		31 


*/







