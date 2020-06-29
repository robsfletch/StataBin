*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
**
*******************************************************************************

program Mahalanobis, rclass
version 16
  syntax , TREAT(varname) VARS(varlist)

  tempname treat_mean treat_cov control_mean control_cov Sigma InvSigma Dif MDist
  qui tabstat `vars' if `treat' == 1 , stat(mean) save
  matrix `treat_mean' = r(StatTotal)
  qui corr `vars' if `treat' == 1 , cov
  matrix `treat_cov' = r(C)

  qui tabstat `vars' if `treat' == 0 , stat(mean) save
  matrix `control_mean' = r(StatTotal)
  qui corr `vars' if `treat' == 0 , cov
  matrix `control_cov' = r(C)

  matrix `Sigma' = (`treat_cov' + `control_cov') / 2
  matrix `InvSigma' = invsym(`Sigma')

  matrix `Dif' = `treat_mean'' - `control_mean''
  matrix `MDist' = `Dif'' * `InvSigma' * `Dif'
  local MDistance = sqrt(`MDist'[1,1])
  disp "`MDistance'"

  return local Dist = `MDistance'


end

******************************************************************************
