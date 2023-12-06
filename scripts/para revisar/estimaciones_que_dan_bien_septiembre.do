

* Regresiones que van dando bien

xtreg crec_prom_2 gini_inicial_periodo pbg_pc_puig if reg==1, fe 

xtreg crec_prom_2 gini_inicial_per_lag if reg==1, fe

xtreg crec_prom_2 gini_inicial_per_lag pbg_pc_puig if reg==1, fe 

xtreg crec_prom_2 gini_prom if reg==1, fe

xtreg crec_prom_2 gini_prom pbg_pc_puig if reg==1, fe

xtreg crec_prom_2 gini_prom_lag  if reg==1, fe 

xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, fe

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re

xtreg  crec_prom_2  gini_prom if reg==1, re

xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, re

xtreg  crec_prom_2  gini_inicial_periodo pbg_pc_puig if reg==1, fe robust

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, fe robust

xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, fe robust

xtreg  crec_prom_2  gini_prom if reg==1, fe robust

xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, fe robust

xtreg  crec_prom_2  gini_prom_lag  if reg==1, fe robust

xtreg  crec_prom_2  gini_prom_lag pbg_pc_puig if reg==1, fe robust

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re robust

xtreg  crec_prom_2  gini_prom if reg==1, re robust

xtreg  crec_prom_2  gini_prom_lag  if reg==1, re robust

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_inicial_per_lag pbg_pc_puig if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_prom if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_prom pbg_pc_puig if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_prom_lag  if reg==1, fe vce (cluster nreg)

xtreg  crec_prom_2  gini_inicial_per_lag if reg==1, re vce (cluster nreg)
