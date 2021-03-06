program evenbin, rclass
	version 13
	syntax varlist [, min(real 1) dif(real 1) increment(real 1) ///
					maxcutoff(real -999) mincutoff(real -999) ///
					ZERO other(int -888) refusal(int -555) ///
					missing(int -999) na(int -777) ///
					gen(str) KEEPLABEL ADDTICK SINGLE]


	// Automatically set the name of the new binned variable if one isn't
	// provided
	if ("`gen'" == "") {
		local gen = "`varlist'_bin"
	}

	// Check that the new gen variable doesn't already exist, and delete
	// it if it does
	capture su `gen', meanonly
	if _rc == 0 {
		drop `gen'
	}

	// Find the max end of the new variable so Coded values don't overlap
	qui sum `varlist' if !inlist(`varlist', `other', `refusal', `missing', `na')
	local max = `r(max)'
	local truemin = `r(min)'

	// Calculate the span to be covered and number of bins needed to cover it
	if (`mincutoff' == -999) {
		if (`maxcutoff' == -999) {
			local span = `max' - `min' + `increment'
			local bin_count = ceil(`span' / `dif')
		}
		else {
			local span = `maxcutoff' - `min' + `increment'
			local bin_count = ceil(`span' / `dif')
		}
		local bin_min = `min'
		local bin_max = `bin_min' + `dif' - `increment'

		label define bin_`varlist' -9999 "-9999", replace
		local bin_code = ""
	}
	else {
		if (`maxcutoff' == -999) {
			local span = `max' - `mincutoff' + `increment'
			local bin_count = ceil(`span' / `dif')
		}
		else {
			local span = `maxcutoff' - `mincutoff' + `increment'
			local bin_count = ceil(`span' / `dif')
		}
		local bin_min = `truemin'
		local bin_max = `mincutoff' - `increment'

		local under = `mincutoff' - `increment'
		label define bin_`varlist' 0 "`under' and Under", replace

		local bin_code = "`bin_min'/`bin_max'=0"

		local bin_min = `mincutoff'
		local bin_max = `bin_min' + `dif' - `increment'
	}

	// Set up the value labels
	if ((`dif' == `increment') | ("`single'" != "")) {
		label define bin_`varlist' 1 "`bin_min'", add
	}
	else {
		if ("`addtick'" != "") {
			local tic_max = `bin_max' + `increment'
			label define bin_`varlist' 1 "`bin_min'-`tic_max'", add
		}
		else {
			label define bin_`varlist' 1 "`bin_min'-`bin_max'", add
		}
	}

	local bin_code = "`bin_code' `bin_min'/`bin_max'=1"


	foreach bin_num of numlist 2/`bin_count' {
		local bin_min = `bin_max' + `increment'
		local bin_max = `bin_min' + `dif' - `increment'

		if ((`dif' == `increment') | ("`single'" != "")) {
			label define bin_`varlist' `bin_num' "`bin_min'", add
		}
		else {
			if ("`addtick'" != "") {
				local tic_max = `bin_max' + `increment'
				label define bin_`varlist' `bin_num' "`bin_min'-`tic_max'", add
			}
			else {
				label define bin_`varlist' `bin_num' "`bin_min'-`bin_max'", add
			}
		}
		local bin_code = "`bin_code' `bin_min'/`bin_max'=`bin_num'"
	}

	if (`maxcutoff' != -999) {
		local bin_min = `bin_max' + `increment'
		local bin_num = `bin_count' + 1
		label define bin_`varlist' `bin_num' "`bin_min'+", add
		local bin_code = "`bin_code' `bin_min'/max=`bin_num'"
	}

	*****************************
	** ALLOW FOR ZERO CATEGORY **
	*****************************
	if ("`zero'" != "") {
		label define bin_`varlist' 0 "0", add
		local bin_code = "`bin_code' 0=0"
	}

	if ("`keeplabel'" != "" ) {
		label copy `varlist' bin_`varlist', replace
	}

	local extra = `bin_count' + 3
	**************************
	** ALLOW FOR EXCEPTIONS **
	**************************
	** If indicated in the options (default it is), then allow
	** For other and refusal options to be shown

	qui count if (`varlist' == `other')
	local other_count = `r(N)'

	if ((`other' != 0) & (`other_count' != 0)) {
		label define bin_`varlist' `extra' "other" , add
		local bin_code = "`bin_code' `other'=`extra'"
		local o_code  = `extra'
		local extra = `extra' + 1

	}

	qui count if (`varlist' == `refusal')
	local refusal_count = `r(N)'

	if ((`refusal' != 0) & (`refusal_count' != 0)) {
		label define bin_`varlist' `extra' "refusal" , add
		local bin_code = "`bin_code' `refusal'=`extra'"
		local r_code `extra'
		local extra = `extra' + 1
	}


	qui count if (`varlist' == `na')
	local NA_count = `r(N)'

	if ((`na' != 0) & (`NA_count' != 0)) {
		label define bin_`varlist' `extra' "Not Applicable" , add
		local bin_code = "`bin_code' `na'=`extra'"
		local NA_code `extra'
		local extra = `extra' + 1
	}

	qui count if (`varlist' == `missing')
	local missing_count = `r(N)'

	if ((`missing' != 0) & (`missing_count' != 0)) {
		label define bin_`varlist' `extra' "missing" , add
		local bin_code = "`bin_code' `missing'=`extra'"
		local m_code `extra'
		local extra = `extra' + 1
	}

	recode `varlist' `bin_code', gen("`gen'")

	label values `gen' "bin_`varlist'"


	return local codes "`r_code' `o_code' `NA_code' `m_code'"
end
