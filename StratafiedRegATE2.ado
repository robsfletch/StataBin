*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program StratafiedRegATE2, rclass
version 16
  syntax , OUTCOME(varname) STRATAVAR(varname) CONTROLS(varlist)

  local num_control : word count `controls'
  local num_covar = 1 + `num_control'

  qui sum `stratavar'
  local num_strata = r(max)

  qui count
  local num_obs = r(N)

  matrix ate = J(1, `num_covar', 0)
  matrix ate_var = J(`num_covar', `num_covar', 0)
  forvalues strata = 1/`num_strata' {
    qui reg `outcome' `controls' if `stratavar' == `strata', rob
    local num_obs_strata = e(N)
    local weight = `num_obs_strata' / `num_obs'
    matrix ate = ate + `weight' * e(b)
    matrix ate_var = ate_var + (`weight')^2 * e(V)
  }

  * matrix t = ate / sqrt(diag(ate_var))

  matrix list ate
  matrix list ate_var
  * matrix list t


  return matrix ate = ate
  return matrix ate_var = ate_var
  * return matrix t = t


end








******************************************************************************
