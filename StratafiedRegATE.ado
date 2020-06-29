*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program StratafiedRegATE, rclass
version 16
  syntax , OUTCOME(varname) TREAT(varname) STRATAVAR(varname) [CONTROLS(varlist)]

  * tempvar Resid ID const r InvSigma
  * tempname Gamma Delta V
  * local num_control : word count `controls'
  * local num_covar = 2 + `num_control'

  qui sum `stratavar'
  local num_strata = r(max)

  qui count
  local num_obs = r(N)

  * gen `const' = 1
  * sort `stratavar'
  * gen `ID' = _n

  local ate = 0
  local ate_var = 0
  forvalues strata = 1/`num_strata' {
    qui reg `outcome' `treat' `controls' if `stratavar' == `strata', rob
    local num_obs_strata = e(N)
    local weight = `num_obs_strata' / `num_obs'
    local ate = `ate' + `weight' * _b[`treat']

    local ate_var = `ate_var' + (`weight')^2 * (_se[`treat'])^2
  }

  local t = `ate' / sqrt(`ate_var')

  disp "ATE: `ate'"
  disp "ATE VAR: `ate_var'"
  disp "T-Stat : `t'"


  return local ate = `ate'
  return local ate_var = `ate_var'
  return local t = `t'


end




/*
predict `Resid' if `stratavar' == `strata' , resid

matrix `Gamma' = J(`num_covar', `num_covar', 0)
matrix `Delta' = J(`num_covar', `num_covar', 0)
sum `ID' if `stratavar' == `strata'
local first = r(min)
local last = r(max)
local strata_num = r(N)
forvalues ii = `first'/`last' {
  mkmat `const' `treat' `controls' in `ii' , matrix(`r')
  local resid_ii = `Resid'[`ii']
  matrix `V' = (`r'' * `r')
  matrix `Gamma' = `Gamma' + `V'
  matrix `Delta' = `Delta' + (`resid_ii'^2 * `V')
}
matrix `Gamma' = `Gamma' / `strata_num'
matrix `Delta' = `Delta' / `strata_num'
matrix `InvSigma' = invsym(`Gamma' * invsym(`Delta') * `Gamma') / `strata_num'

local ate_var = `ate_var' + (`num_strata' / `num_obs')^2 * `InvSigma'[2,2]


drop `Resid'
*/









******************************************************************************
