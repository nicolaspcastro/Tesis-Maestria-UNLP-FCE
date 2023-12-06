clear all
set more off

use "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\data\data_in\EPH\2003 - 2015\Individual_t110_prov.dta"

append using "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\data\data_in\EPH\2003 - 2015\Individual_t210_prov.dta"
append using "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\data\data_in\EPH\2003 - 2015\Individual_t310_prov.dta"
append using "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\data\data_in\EPH\2003 - 2015\Individual_t410_prov.dta"

rename _all, lower

destring deccfr,replace
**Limpieza Base:
*12 y 13 es que no respondio ingreso
drop if deccfr<1 | deccfr>10
**hogar secundario:pensionista o servicio domestico**
drop if nro_hogar==51 | nro_hogar==71

sort codusu nro_hogar componente
egen id = group(codusu nro_hogar componente)    

run "${path_estim}\scripts\comando_cuantiles.do"

levelsof nprov, loc (nprov)
glo trim = "1 2 3 4"
foreach j in $trim {

    foreach x in `nprov' { 
    
    	cuantiles ipcf [w=pondera] if nprov == `x' & trimestre == `j' & ipcf>0, ncuantiles(5) orden_aux(id) generate(p5_`x'_`j')
    }
}


mat gini= J(24,20,.)
mat rownames gini = "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Corrientes" "Córdoba" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquén" "Rio Negro" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Stgo del Estero" "Tierra del Fuego" "Tucumán" 
mat colnames gini = "1_1" "1_2" "1_3" "1_4" "1_5" "2_1" "2_2" "2_3" "2_4" "2_5" "3_1" "3_2" "3_3" "3_4" "3_5" "4_1" "4_2" "4_3" "4_4" "4_5" 

loc col=0
loc aux=0
foreach j in $trim {
    loc fila=1
    foreach x in `nprov' {
        
        forv i=1/5 { 
            preserve
    
		    keep if nprov==`x'
            keep if trimestre==`j'
		    keep if p5_`x'_`j'==`i'

      	    run "${path_estim}\scripts\comando_gini.do"

            loc col= `i' + `aux'
		    gini ipcf [w=pondera] 
            loc gini_`i'=r(gini)
		    mat gini[`fila',`col']=`gini_`i''
    
            
            restore
        }

        loc fila = `fila' + 1
    }	
    loc aux= `aux' + 5	
}

mat list gini

putexcel set "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\outputs\tables\gini\gini_prueba.xlsx", sheet("original", replace) modify

putexcel A2=mat(gini), rownames

*******************************************************************************
mat gini2= J(24,4,.)
mat rownames gini2 = "Buenos Aires" "Catamarca" "Chaco" "Chubut" "Ciudad Autonoma de BA" "Corrientes" "Córdoba" "Entre Ríos" "Formosa" "Jujuy" "La Pampa" "La Rioja" "Mendoza" "Misiones" "Neuquén" "Rio Negro" "Salta" "San Juan" "San Luis" "Santa Cruz" "Santa Fe" "Stgo del Estero" "Tierra del Fuego" "Tucumán" 
mat colnames gini2 = "1" "2" "3" "4"


loc col=0
loc aux=0
foreach j in $trim {
    loc fila=1
    foreach x in `nprov' {
        
         
        preserve

		keep if nprov==`x'
        keep if trimestre==`j'
		
      	loc col= `j'
		
        table p5_`x'_`j' [w=pondera], c(freq mean ipcf sum ipcf) row replace
		rename table1 freq
		rename table2 ipcf_mean 
		rename table3 sum
		run "${path_estim}\scripts\comando_gini.do"
		gini ipcf_mean
		loc gini_`x'_`j'=r(gini)
		mat gini2 [`fila',`col']=`gini_`x'_`j''
        
        restore
        
        loc fila = `fila' + 1
    }	
    loc aux= `aux' + 5	
}

mat list gini2

putexcel set "C:\Users\nicoc\Google Drive\Facultad\Maestria\Tesis\Estimaciones\outputs\tables\gini\gini_prueba.xlsx", sheet("original2", replace) modify

putexcel A2=mat(gini2), rownames