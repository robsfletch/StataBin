program normalized_diff , rclass
	version 13
	syntax [varlist] [if] [in]
	marksample touse
	
	tokenize `varlist'
	local treat `1'
	macro shift
	local vars `*'
	local k : word count `vars'

	local counter = 1
	matrix ND = J(`k', 4, 0)
	matrix colnames ND = "Control" "Treatment" "Difference" "tstat"
	
	// Iterate over the covariates of interest
	foreach var of varlist `vars' {
		// Calculate the mean and variance for the control group covariate
		qui sum `var' if `treat' == 0
		local mean_c = `r(mean)'
		local var_c = `r(Var)'
		local num_c = `r(N)'

		// Calculate the mean and variance for the treated group covariate
		qui sum `var' if `treat' == 1
		local mean_t = `r(mean)'
		local var_t = `r(Var)'
		local num_t = `r(N)'

		// Calculate the Normalized difference
		local nd = (`mean_t' - `mean_c') / sqrt((`var_t' + `var_c')/2)
		local t = (`mean_t' - `mean_c') / sqrt((`var_t'/`num_t' + `var_c'/`num_c'))

		matrix ND[`counter' ,1] = `mean_c'
		matrix ND[`counter' ,2] = `mean_t'
		matrix ND[`counter' ,3] = `nd'
		matrix ND[`counter' ,4] = `t'
		
		// Move to the next variable that was passed
		local ++counter
		
	}

	matrix rownames ND = `vars'

	return matrix nd ND
end
