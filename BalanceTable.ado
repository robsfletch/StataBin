*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program BalanceTable , eclass
	version 16
	syntax [if] [in], TREAT(varname) VARS(varlist) [PI USING(str)]
	marksample touse

	if "`using'" != "" {
		local using = `"using "`using'" "'
	}

	sort `treat'
	eststo clear
	qui estpost sum `vars' if `treat' == 0
	eststo control

	qui estpost sum `vars' if `treat' == 1
	eststo treat

	CalcBalance , treat(`treat') vars(`vars')
	ereturn list
	eststo BalanceTest

	Pi , treat(`treat') vars(`vars')
	ereturn list
	eststo Pi

	if "`pi'" != "" {
		local cell_str = "mean(pattern(1 1 0 0) fmt(2)) sd(pattern(1 1 0 0) par) " + ///
			" TStat(pattern(0 0 1 0)) ND(pattern(0 0 1 0)) " + ///
			" LogRatio(fmt(2) pattern(0 0 1 0)) " + ///
			" PiC(fmt(2) pattern(0 0 0 1)) PiT(fmt(2) pattern(0 0 0 1))"

			esttab control treat BalanceTest Pi `using' ///
				, cells("`cell_str'") nonumbers ///
				mlabel("Control" "Treatment" "Balance Tests" "Pi(0.05)") ///
				collabels("Mean" "Std. Dev." "t-stat" "Norm-Diff" "Log Ratio" "Control" "Treat") `options'
	}
	else {
		local cell_str = "mean(pattern(1 1 0) fmt(2)) sd(pattern(1 1 0) par) " + ///
			" TStat(pattern(0 0 1)) ND(pattern(0 0 1)) " + ///
			" LogRatio(fmt(2) pattern(0 0 1)) "

			esttab control treat BalanceTest `using' ///
				, cells("`cell_str'") nonumbers ///
				mlabel("Control" "Treatment" "Balance Tests") ///
				collabels("Mean" "Std. Dev." "t-stat" "Norm-Diff" "Log Ratio") `options'
	}

end


*******************************************************************************
** Calculate Balance
*******************************************************************************
program CalcBalance , eclass
	syntax [if] [in], TREAT(varname) VARS(varlist)

	local k : word count `vars'
	matrix TStat = J(1, `k', 0)
	matrix ND = J(1, `k', 0)
	matrix LogRatio = J(1, `k', 0)

	matrix colnames TStat = `vars'
	matrix colnames ND = `vars'
	matrix colnames LogRatio = `vars'


	** Fill In Statistics
	local counter = 1
	foreach var of varlist `vars' {
		// Calculate the mean and variance for the control group covariate
		qui sum `var' if `treat' == 0, de
		local mean_c = r(mean)
		local var_c = r(Var)
		local sd_c = r(sd)
		local num_c = r(N)

		// Calculate the mean and variance for the treated group covariate
		qui sum `var' if `treat' == 1, de
		local mean_t = r(mean)
		local var_t = r(Var)
		local sd_t = r(sd)
		local num_t = r(N)

		// Calculate the Normalized difference
		local nd = (`mean_t' - `mean_c') / sqrt((`var_t' + `var_c')/2)
		local t = (`mean_t' - `mean_c') / sqrt((`var_t'/`num_t' + `var_c'/`num_c'))
		local log_ratio = log(`sd_t') - log(`sd_c')

		matrix TStat[1, `counter'] = `t'
		matrix ND[1, `counter'] = `nd'
		matrix LogRatio[1, `counter'] = `log_ratio'

		// Move to the next variable that was passed
		local ++counter
	}

	ereturn post
	ereturn matrix TStat = TStat
	ereturn matrix ND = ND
	ereturn matrix LogRatio = LogRatio

end


*******************************************************************************
** Calculate Overlap with Percentiles
*******************************************************************************
program Pi , eclass
	syntax [if] [in], TREAT(varname) VARS(varlist)

	local k : word count `vars'
	matrix PiC = J(1, `k', 0)
	matrix PiT = J(1, `k', 0)

	matrix colnames PiC = `vars'
	matrix colnames PiT = `vars'

	count if `treat' == 1
	local num_t = r(N)
	count if `treat' == 0
	local num_c = r(N)

	local counter = 1
	foreach var of varlist `vars' {
		// Calculate the mean and variance for the control group covariate
		_pctile `var' if `treat' == 0, p(2.5)
		local p25_c = r(r1)

		_pctile `var' if `treat' == 0, p(97.5)
		local p975_c = r(r1)

		// Calculate the mean and variance for the treated group covariate
		_pctile `var' if `treat' == 1, p(2.5)
		local p25_t = r(r1)

		_pctile `var' if `treat' == 1, p(97.5)
		local p975_t = r(r1)

		count if (`var' < `p25_c' | `var' > `p975_c') & `treat' == 1
		local num_out_t = r(N)
		local pi_t = `num_out_t' / `num_t'

		count if (`var' < `p25_t' | `var' > `p975_t') & `treat' == 0
		local num_out_c = r(N)
		local pi_c = `num_out_c' / `num_c'

		matrix PiC[1, `counter'] = `pi_c'
		matrix PiT[1, `counter'] = `pi_t'

		local ++counter
	}

	estpost
	ereturn matrix PiC = PiC
	ereturn matrix PiT = PiT

end
