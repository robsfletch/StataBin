*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program MahalanobisObs, eclass
version 16
  syntax [if] [in], VARS(varlist) treat(varname) REFOBS(integer)  ///
    [INVSIGMA(name) GENerate(string) REPlace EQUALWeight EUCLID UNWEIGHTED]

  tempname Dif MDist x1 x2 ones

  if "`invsigma'" == "" {
    tempname treat_cov control_cov num_treat num_control ///
      weight_treat_cov weight_control_cov sigma invsigma ///
      treat_wt control_wt

    qui corr `vars' if `treat' == 1 , cov
    matrix `treat_cov' = r(C)
    local num_treat = r(N)

    qui corr `vars' if `treat' == 0 , cov
    matrix `control_cov' = r(C)
    local num_control = r(N)

    local num_obs = (`num_treat' + `num_control')

    if "`equalweight'" != "" {
      local `treat_wt' = .5
      local `control_wt' = .5
    }
    else {
      local `treat_wt' = `num_treat' / `num_obs'
      local `control_wt' = `num_control' / `num_obs'
    }

    matrix `sigma' = (``treat_wt'' * `treat_cov' + ``control_wt'' * `control_cov')

    if "`unweighted'" != "" {
      qui corr `vars', cov
      matrix `sigma' = r(C)
    }

    ** Turn it into euclidean distance measure if specified
    if "`euclid'" != "" {
      matrix `sigma' = diag(vecdiag(`sigma'))
    }

    matrix `invsigma' = invsym(`sigma')
  }

  mkmat `vars' in `refobs' , matrix(`x1')
  mkmat `vars' `if' `in ', matrix(`x2')

  local num_covar : word count `vars'
  qui count `if' `in'
  matrix `ones' = J(r(N), 1, 1)
  matrix `x1' = `x1'#`ones'

  matrix `Dif' = (`x1' - `x2')'
  matrix `MDist' = vecdiag(`Dif'' * `invsigma' * `Dif')'

  if "`generate'" != "" {
    if "`replace'" != "" {
      capture drop `generate'
    }
    svmat `MDist' , name("`generate'")
    rename `generate'1 `generate'
  }

  ereturn post
  ereturn matrix Dist = `MDist'
  ereturn matrix invsigma = `invsigma'

end

******************************************************************************
