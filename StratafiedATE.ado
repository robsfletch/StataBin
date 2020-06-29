*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program StratafiedATE, rclass
version 16
  syntax , TREAT(varname) VAR(varname) STRATAVAR(varname)

    qui sum `stratavar'
    local num_strata = r(max)

    qui count
    local num_obs = r(N)

    local ate = 0
    local ate_var = 0

    forvalues strata = 1/`num_strata' {
      qui ttest `var' if `stratavar' == `strata', by(`treat') unequal
      local num_obs_strata = r(N_1) + r(N_2)
      local weight = `num_obs_strata' / `num_obs'
      local ate = `ate' + `weight' * (r(mu_2) - r(mu_1))
      local ate_var = `ate_var' + (`weight')^2 * r(se)
    }

    local z = `ate' / sqrt(`ate_var')

    disp "ATE: `ate'"
    disp "ATE VAR: `ate_var'"
    disp "Z-Stat : `z'"

    return local ate = `ate'
    return local ate_var = `ate_var'
    return local z = `z'


end

******************************************************************************
