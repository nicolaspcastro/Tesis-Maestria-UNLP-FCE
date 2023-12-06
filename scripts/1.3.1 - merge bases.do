****************************************************************************************************************************************
*														PREPARA BASE FINAL
*	ABRO BASE DE PBG FINAL
*		MERGE CON BASE DE COEFICIENTE DE GINI
*			MERGE CON BASE DE VARIABLES DE CONTROL
*				CALCULO DE VARIACIONES, VARIABLES POR REGION, LOGARITMOS, ETC.
*
****************************************************************************************************************************************

*drop _all

quietly {
    
    clear all

    noi display in green "COMENZANDO DO FILE MERGE BASE FINAL"

    use "${path_datain}\Bases Finales - Prepara Base\pbg_base_completa.dta", replace

    merge 1:1 año nprov using "${path_datain}\Bases Finales - Prepara Base\variables_control.dta", gen(_merge_control)

    merge 1:1 año nprov using "${path_datain}\Bases Finales - Prepara Base\eph_base_completa.dta", gen(_merge_eph)

    noi display in yellow "GUARDANDO BASE MERGEADA"
    
    save "${path_dataout}\base_tesis_completa.dta", replace

}

quietly {
    /*
    keep if año >= 1993

    keep año nprov prov pbg_cepal_ipi pbg_cepal_ipc pbg_isap_tromb_ipi pbg_isap_tromb_ipc pbg_isap_trajt_ipi pbg_isap_trajt_ipc pbi_ipi pbi_ipc pbi_pbg_isap_tromb_ipi pbi_pbg_isap_tromb_ipc pbi_pbg_isap_trajt_ipi pbi_pbg_isap_trajt_ipc pbi_pbg_cepal_ipi pbi_pbg_cepal_ipc expo_pp_uss expo_moa_uss expo_moi_uss expo_cye_uss expo_total_uss expo_pp_pesos expo_pp_ipi_expo expo_pp_ipi expo_pp_ipc expo_moa_pesos expo_moa_ipi_expo expo_moa_ipi expo_moa_ipc expo_moi_pesos expo_moi_ipi_expo expo_moi_ipi expo_moi_ipc expo_cye_pesos expo_cye_ipi_expo expo_cye_ipi expo_cye_ipc expo_total_pesos expo_total_ipi_expo expo_total_ipi expo_total_ipc tcn ipc_bcra ipi ipi_expo expo_total expo_bra expo_usa expo_chl expo_chn expo_ury expo_pry expo_mex expo_nld expo_deu expo_ven expo_resto expo_jpn expo_kor expo_esp expo_fin expo_phl expo_bgr expo_can expo_ind expo_ita expo_idn expo_egy expo_col expo_hkg expo_vnm expo_irq expo_rus expo_gbr expo_dza expo_per expo_bel expo_sau expo_ecu expo_syr expo_fra expo_zaf expo_bol expo_che expo_zf_ury expo_mys superficie_km_2 densidad poblacion tasa_mort_inf rbpm_sipa rbpm_sipa_ipi rbpm_sipa_ipc idh ptspf_sipa depositos_priv_corr depositos_priv_sd prestamos_priv_corr prestamos_priv_sd depositos_priv_ipi prestamos_priv_ipi depositos_priv_ipc prestamos_priv_ipc depositos_pub_corr depositos_pub_sd prestamos_pub_corr prestamos_pub_sd depositos_pub_ipi prestamos_pub_ipi depositos_pub_ipc prestamos_pub_ipc gini_m_sa gini_indec_sa poblacion_eph gini_m_ca gini_indec_ca

    save "${path_dataout}\base_tesis_tobi.dta", replace
    */
}