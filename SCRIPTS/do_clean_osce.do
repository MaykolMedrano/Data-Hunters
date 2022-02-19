

glo path "G:/.shortcut-targets-by-id/12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ/ATA HUNTERS - DSRP 2022/1.- BASE DE DATOS/1.- CONOSCE""
cd "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\1.- CONOSCE\"


import excel "2.- DATOS DE LA CONVOCATORIA O INVITACION\CONOSCE_CONVOCATORIAS2019_0.xlsx", sheet("CONOSCE") firstrow  case(lower)  clear
tempfile  convocatoria
tostring entidad_ruc, replace
save `convocatoria'

import excel "3.- DATOS DE LA ADJUDICACION\CONOSCE_ADJUDICACIONES2019_0.xlsx", sheet("CONOSCE")  firstrow case(lower) clear
tempfile  adjudicacion
save `adjudicacion'

import excel "6.- CONTRATOS\CONOSCE_CONTRATOS2019_0.xlsx", sheet("CONOSCE")  firstrow case(lower) clear
tempfile  contratos
save `contratos'

import delimited "10.- SANCIONES, INHABILITACIONES Y PENALIDADES\penalidades2018-2020.csv", clear 
ren ruccontratista ruc_proveedor
tostring ruc_proveedor, replace
gen año_penalidad = substr( fechapenalidad, -2,2)
keep if año_penalidad=="19"
tempfile  penalidades
save `penalidades'

import delimited "10.- SANCIONES, INHABILITACIONES Y PENALIDADES\sancionados_inhabilitacion.csv", clear 
tostring fecha_inicio, replace
gen año_inha = substr(fecha_inicio,1,4)
keep if año_inha=="2019" | año_inha=="2020" | año_inha=="2021" | año_inha=="2022"
ren ruc ruc_proveedor
tostring ruc_proveedor, gen(ruc_proveedor_) format("%12.0f")
drop ruc_proveedor
ren ruc_proveedor_ ruc_proveedor
tempfile  sanciones_in
save `sanciones_in'

import delimited "10.- SANCIONES, INHABILITACIONES Y PENALIDADES\sancionados_multa.csv", clear 
tostring fecha_inicio, replace
gen año_san = substr(fecha_inicio,1,4)
keep if año_san=="2019" | año_san=="2020" | año_san=="2021" | año_san=="2022"
ren ruc ruc_proveedor
tostring ruc_proveedor, gen(ruc_proveedor_) format("%12.0f")
drop ruc_proveedor
ren ruc_proveedor_ ruc_proveedor
tempfile  sancionados_multa
save `sancionados_multa'

import delimited "10.- SANCIONES, INHABILITACIONES Y PENALIDADES\inhabilitaciones_judiciales.csv", clear 
ren ruc_dni  ruc_proveedor
tostring ruc_proveedor, gen(ruc_proveedor_) format("%12.0f")
drop ruc_proveedor
ren ruc_proveedor_ ruc_proveedor
tempfile  inhabilitaciones_judiciales
save `inhabilitaciones_judiciales'

import excel "4.- LISTADO DE OFERTANTES\CONOSCE_POSTOR2019_0.xlsx", sheet("CONOSCE") firstrow case(lower) clear
ren codigo_convocatoria codigoconvocatoria
tempfile  ofertantes
save 	`ofertantes'

import excel "5.- PROVEEDORES Y CONSORCIOS\CONOSCE_CONSORCIO2019_0.xlsx", sheet("CONOSCE") firstrow case(lower) clear
tempfile consorcio
save 	`consorcio'


import excel "5.- PROVEEDORES Y CONSORCIOS\CONOSCE_PROVEEDORES2019_0.xlsx", sheet("CONOSCE") firstrow case(lower) clear
tempfile  proveedores
save `proveedores'

import excel "7.- MIEMBROS DE COMITE\CONOSCE_MIEMBROSCOMITE2019_0.xlsx", sheet("CONOSCE") firstrow case(lower) clear
tempfile  comite
save `comite'

*import excel "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\INFORMACION 88030419.xlsx", sheet("Hoja2") firstrow case(lower) clear

*ren ruc ruc_proveedor
*tempfile  no_domiciliados
*save `no_domiciliados'

********************************************************************************

use `convocatoria', clear
merge m:m codigoconvocatoria using `comite', force nogen keep(1 3)
merge m:m codigoconvocatoria using `ofertantes', force nogen keep(1 3)
merge m:m codigoconvocatoria using `adjudicacion', force nogen keep(1 3)
merge m:m codigoconvocatoria using `contratos', force nogen keep(1 3)
merge m:m ruc_proveedor using `penalidades', force  nogen keep(1 3)
merge m:m ruc_proveedor using `sanciones_in', force  nogen keep(1 3)
merge m:m ruc_proveedor using `sancionados_multa', force  nogen keep(1 3)
merge m:m ruc_proveedor using `inhabilitaciones_judiciales', force  nogen keep(1 3)
*merge m:m ruc_proveedor using `no_domiciliados', force  nogen keep(1 3)

foreach x of varlist entidad_ruc {
tostring `x', gen(`x'_) format("%12.0f")
drop `x'
ren `x'_ `x'
}

save "conosce_2019.dta", replace
exit 
/*
//Quitar tildes y cambiar todo a mayúscula
ds, has(type string)
local string_var "`r(varlist)'"
foreach i of varlist `string_var'{
	qui replace `i' = upper(ustrto(ustrnormalize(`i', "nfd"), "ascii", 2))
	qui replace `i' = stritrim(`i')
	qui replace `i' = strltrim(`i')
	qui replace `i' = strrtrim(`i')
}



replace moneda="SOLES" if moneda=="NUEVOS SOLES"
gen 	monto_final_soles=monto_referencial_item
replace monto_final_soles=3.35*monto_referencial_item 	if  moneda=="DOLAR NORTEAMERICANO"
replace monto_final_soles=3.72*monto_referencial_item 	if  moneda=="EURO"
replace monto_final_soles=1.30*monto_referencial_item   if  moneda=="LIBRA ESTERLINA"
replace monto_final_soles=0.034*monto_referencial_item 	if  moneda=="YEN JAPONES"
replace monto_final_soles=4.23*monto_referencial_item 	if  moneda=="FRANCO SUIZO"

keep tipo_proveedor ruc_proveedor departamento_item
duplicates drop ruc_proveedor, force
duplicates r ruc_proveedor

ren ruc_proveedor ruc_consorcio
merge 1:m ruc_consorcio using `consorcio', force nogen keep(1 3) 

ren ruc_consorcio ruc_proveedor
drop consorcio miembro año

gen ruc_proveedor_final = ""
replace ruc_proveedor_final = ruc_proveedor if tipo_proveedor!="Consorcio"
replace ruc_proveedor_final = ruc_miembro   if tipo_proveedor=="Consorcio"

duplicates r ruc_proveedor_final
duplicates drop ruc_proveedor_final, force

keep tipo_proveedor ruc_proveedor_final tipo_proveedor departamento_item

keep if departamento_item=="CUSCO" | departamento_item=="PIURA" | departamento_item=="MADRE DE DIOS"

export excel using "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\RUCs\rucs_2019_to_sunat_region.xls", sheet("todo") sheetmodify firstrow(variables) 

keep if tipo_proveedor=="Persona Natural"
export excel using "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\RUCs\rucs_2019_to_sunat_region.xls", sheet("naturales") sheetmodify firstrow(variables) 

keep if tipo_proveedor=="Persona Juridica" | tipo_proveedor=="Consorcio"

export excel using "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\RUCs\rucs_2019_to_sunat_region.xls", sheet("juridicas") sheetmodify firstrow(variables)   

exit 

format %15.2fc monto_final_soles
keep if monto_final_soles <= 33600
*/

********************************************************************************
* JURIDICAS SCRAPEO

import excel "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\RUCs\rucs_2019_to_sunat_region.xls", sheet("juridicas") firstrow clear
keep if departamento_item=="CUSCO" | departamento_item=="PIURA" | departamento_item=="MADRE DE DIOS"
ren ruc_proveedor_final ruc_proveedor
duplicates drop ruc_proveedor, force
tempfile juridicas
save `juridicas'


import excel "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\7_SUNAT\juridicas\sunat_juridicas_scrapy_0_1000.xlsx", sheet("Sheet1") firstrow clear

drop A

foreach i of varlist * {
	replace `i'= upper(ustrto(ustrnormalize(`i', "nfd"), "ascii", 2))
	replace `i' = stritrim(`i')
	replace `i' = strltrim(`i')
	replace `i' = strrtrim(`i')
} 

gen ruc_proveedor = substr(ruc, 1,11)
ren ruc ruc_nombre
replace ruc_nombre = substr(ruc_nombre, 15,.)
order ruc_proveedor

format %15s *
duplicates drop ruc_proveedor, force
merge 1:1 ruc_proveedor using `juridicas', keepus(ruc_proveedor) nogen

foreach i of varlist * {
	replace `i'= upper(ustrto(ustrnormalize(`i', "nfd"), "ascii", 2))
	replace `i' = stritrim(`i')
	replace `i' = strltrim(`i')
	replace `i' = strrtrim(`i')
} 

save "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\7_DATA FINAL\sunat_juridicas.dta", replace

* NATURALES SCRAPEO
import excel "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\RUCs\rucs_2019_to_sunat_region.xls", sheet("naturales") firstrow clear
keep if departamento_item=="CUSCO" | departamento_item=="PIURA" | departamento_item=="MADRE DE DIOS"
ren ruc_proveedor_final ruc_proveedor
duplicates drop ruc_proveedor, force
tempfile naturales
save `naturales'

import excel "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\1.- BASE DE DATOS\7_SUNAT\naturales\sunat_naturales_scrapy_0_768_regiones.xlsx", sheet("Sheet1") firstrow clear
duplicates drop ruc, force

foreach i of varlist * {
	replace `i'= upper(ustrto(ustrnormalize(`i', "nfd"), "ascii", 2))
	replace `i' = stritrim(`i')
	replace `i' = strltrim(`i')
	replace `i' = strrtrim(`i')
} 

gen ruc_proveedor = substr(ruc, 1,11)
ren ruc ruc_nombre
replace ruc_nombre = substr(ruc_nombre, 15,.)
order ruc_proveedor

format %15s *

merge 1:1 ruc_proveedor using `naturales', keepus(ruc_proveedor) nogen

foreach i of varlist * {
	replace `i'= upper(ustrto(ustrnormalize(`i', "nfd"), "ascii", 2))
	replace `i' = stritrim(`i')
	replace `i' = strltrim(`i')
	replace `i' = strrtrim(`i')
} 


save "G:\.shortcut-targets-by-id\12TzPbm9VMQ59iYHV5STnjfMFuqvVP6KQ\DATA HUNTERS - DSRP 2022\7_DATA FINAL\sunat_naturales.dta", replace