****************************************************************************************************************************************
*                                    DO FILE AUXILIAR EPH PUNTUAL - BASES POR AÑO/AGLO Y NACIONAL DE DBF A DTA Y MERGE
****************************************************************************************************************************************
* CAMBIAR EL DO PARA QUE GUARDE LAS BASES INDIVIDUAL Y HOGAR POR SEPARADO CUANDO ARREGLE LA COMPU.

quietly {
    noi display in green "COMENZANDO DO FILE AUXILIAR EPH PUNTUAL"
    ***************************************************************************************************************************************
    *                                    JUNTAR BASES DE EPH PUNTUAL POR AGLOMERADO
    ***************************************************************************************************************************************
    * LAS BASES POR AGLOMERADO SE GUARDAN EN UNA CARPETA POR SEPARADO (UNA BASE INDIVIDUAL, UNA HOGAR Y LA COMPLETA)
    * AÑOS 1995 a 1999

    loc año = "95 96 97 98 99"
    loc aglo = "01 02 03 04 05 06 07 08 09 10 12 13 14 15 17 18 19 20 22 23 25 26 27 29 30 31 34 36 38 91 93"
    loc onda = "1 3"
    glo path_bases = "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en Otros formatos\EPHP - 1991 - 2006\bases_por_año"

    foreach y in `año' {
        foreach o in `onda' {
            foreach a in `aglo' {

                clear
                *Abro las bases usando capture porque hay algunas que no estan
                capture import dbase using "${path_bases}\19`y'\Bua`a'`o'`y'\PER_BUA.DBF", clear case(lower)

                if _rc==601{
                    
                    * Si no existe la base, salteo el procedimiento
            		noi display in red "NO EXISTE BASE año `y' aglomerado `a' onda `o' (carpeta por aglo) - PASANDO A SIGUIENTE BASE..."
                }
        		if _rc==0 {
                    
                    * Si existe la base comienza a preparar las bases
        		    noi display in yellow "EXISTE BASE año `y' aglomerado `a' onda `o' (carpeta por aglo) - GENERANDO BASE COMPLETA..."

                    sort codusu componente aglomerado
                    save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\Individual_`a'o`o'`y'.dta", replace

                    import dbase using "${path_bases}\19`y'\Bua`a'`o'`y'\HOG_BUA.DBF", clear case(lower)
                    save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\Hogar_`a'o`o'`y' .dta", replace

                    gsort codusu aglomerado -realizada
                    duplicates drop codusu aglomerado, force
                    merge 1:m codusu aglomerado using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\Individual_`a'o`o'`y'.dta"
                    keep if _merge==3

                    save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\EPHP_`a'o`o'`y'.dta", replace
                }
            }

            clear
            foreach a in `aglo' {

                capture append using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\EPHP_`a'o`o'`y'.dta"
            }
            if _N!=0 save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_19`y'_O`o'_aglo.dta", replace
        }
    }

    * AÑOS 2000 a 2006
    loc año = "00 01 02 03 04 05 06"
    loc aglo = "01 02 03 04 05 06 07 08 09 10 12 13 14 15 17 18 19 20 22 23 25 26 27 29 30 31 34 36 38 91 93"
    loc onda = "1 3"
    glo path_bases = "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en Otros formatos\EPHP - 1991 - 2006\bases_por_año"

    foreach y in `año' {
        foreach o in `onda' {
            foreach a in `aglo' {

                capture import dbase using "${path_bases}\20`y'\Bua`a'`o'`y'\PER_BUA.DBF", clear case(lower)

                if _rc==601{

            		noi display in red "NO EXISTE BASE año `y' aglomerado `a' onda `o' (carpeta por aglo) - PASANDO A SIGUIENTE BASE..."
                }
        		if _rc==0 {
                
        		    noi display in yellow "EXISTE BASE año `y' aglomerado `a' onda `o' (carpeta por aglo) - GENERANDO BASE COMPLETA..."

                    sort codusu componente aglomerado
                    save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\Individual_`a'o`o'`y'.dta", replace

                    import dbase using "${path_bases}\20`y'\Bua`a'`o'`y'\HOG_BUA.DBF", clear case(lower)
                    save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\Hogar_`a'o`o'`y' .dta", replace

                    sort codusu aglomerado
                    merge 1:m codusu aglomerado using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\Individual_`a'o`o'`y'.dta"
                    keep if _merge==3

                    save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\EPHP_`a'o`o'`y'.dta", replace
                }
            }
            clear
            foreach a in `aglo' {

                capture append using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Puntual por aglomerado\EPHP_`a'o`o'`y'.dta"
            }
            if _N!=0 save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_20`y'_O`o'_aglo.dta", replace
        }
    }

    use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_1995_O1_aglo.dta", clear
    save"$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_1995_O1_B.dta", replace

    use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_1995_O3_aglo.dta", clear
    save"$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_1995_O3_B.dta", replace

    use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_2003_O3_aglo.dta", clear
    save"$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_2003_O3_B.dta", replace

    use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_2004_O1_aglo.dta", clear
    save"$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_2004_O1_B.dta", replace

    use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_2004_O3_aglo.dta", clear
    save"$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_2004_O3_B.dta", replace

    use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_2005_O1_aglo.dta", clear
    save"$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_2005_O1_B.dta", replace

    use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_2005_O3_aglo.dta", clear
    save"$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_2005_O3_B.dta", replace

    use "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_2006_O1_aglo.dta", clear
    save"$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_2006_O1_B.dta", replace

    ***************************************************************************************************************************************
    *                                    GUARDADO DE BASES A NIVEL NACIONAL EN .DTA
    ***************************************************************************************************************************************
    * AÑOS 1995 A 1999
    * SE GUARDAN LAS BASES INDIVIDUAL, HOGAR Y COMPLETA EN LAS MISMAS CARPETAS QUE LA EPH CONTINUA (EN PRINCIPIO VOY A USAR ESTAS)
    loc año = "95 96 97 98 99"
    loc onda = "1 3"

    foreach y in `año' {
        foreach o in `onda' {

            capture import dbase using "${path_bases}\19`y'\Bua45`o'`y'\PER_BUA.DBF", clear case(lower)

            if _rc==601{

            	noi display in red "NO EXISTE BASE año `y' nacional onda `o' (carpeta aglo nac) - PASANDO A SIGUIENTE BASE..."
            }
        	if _rc==0 {

        		noi display in yellow "EXISTE BASE año `y' nacional onda `o' (carpeta aglo nac) - GENERANDO BASE COMPLETA..."

                sort codusu componente aglomerado agloreal
                save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Individual\Individual_o`o'`y'.dta", replace

                import dbase using "${path_bases}\19`y'\Bua45`o'`y'\HOG_BUA.DBF", clear case(lower)
                save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Hogar\Hogar_o`o'`y'.dta", replace

                gsort codusu aglomerado agloreal realizada
                duplicates drop codusu aglomerado agloreal, force
                merge 1:m codusu aglomerado agloreal using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Individual\Individual_o`o'`y'.dta"
                keep if _merge==3

                save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_19`y'_O`o'.dta", replace
                save "$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_19`y'_O`o'_A.dta", replace
            }
        }
    }  
    
    loc año = "00 01 02 03"
    loc onda = "1 3"

    * AÑOS 2000 a 2006
    foreach y in `año' {
        foreach o in `onda' {

            capture import dbase using "${path_bases}\20`y'\Bua45`o'`y'\PER_BUA.DBF", clear case(lower)

            if _rc==601{

            	noi display in red "NO EXISTE BASE año `y' nacional onda `o' (carpeta aglo nac) - PASANDO A SIGUIENTE BASE..."
            }
        	if _rc==0 {

        		noi display in yellow "EXISTE BASE año `y' nacional onda `o' (carpeta aglo nac) - GENERANDO BASE COMPLETA..."

                sort codusu componente aglomerado agloreal
                save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Individual\Individual_o`o'`y'.dta", replace

                import dbase using "${path_bases}\20`y'\Bua45`o'`y'\HOG_BUA.DBF", clear case(lower)
                save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Hogar\Hogar_o`o'`y'.dta", replace

                sort codusu aglomerado agloreal
                merge 1:m codusu aglomerado agloreal using "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Individual\Individual_o`o'`y'.dta"
                keep if _merge==3

                save "$path_datain\EPH\Bases Originales\EPH INDEC\Bases en DTA\Completa\EPHP_20`y'_O`o'.dta", replace
                save "$path_datain\EPH\Bases Procesadas\Semestrales\EPHP_20`y'_O`o'_A.dta", replace
            }
        }
    }
}