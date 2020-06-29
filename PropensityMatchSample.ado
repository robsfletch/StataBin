*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/"
**
** TODO : ADD option to drop treatment vars with particularly poor matches
*******************************************************************************

program PropensityMatchSample
version 16
  syntax , PROB(varname) TREAT(varname) TRIM(string) ///
    [MAHAlanobis VARS(varlist) EQUALWeight EUCLID UNWEIGHTED ///
    GREEDY MATCHGROUP(str) ///
    NUMMATCHES(str) MATCHNUM(integer 1) ///
    TIEBREAKER(varname) REPLACE]

  tempvar LogOdds MatchID MatchedID Taken
  if "`matchgroup'" == "" {
    tempvar matchgroup
  }

  if "`nummatches'" == "" {
    tempvar nummatches
  }
  if "`replace'" != "" {
    capture drop `trim'
    capture drop `nummatches'
    capture drop `matchgroup'
  }

  gen `nummatches' = 0

  if "`greedy'" != "" {
    gen `matchgroup' = .
    local restrict_str = "| `nummatches' >= 1"
  }

  gen `LogOdds' = log(`prob' / (1 - `prob'))

  gsort - `treat' - `LogOdds' `tiebreaker'

  qui count if `treat' == 1
  local NumTreat = r(N)

  gen `MatchID' = _n
  qui gen `MatchedID' = .

  tempvar Dif DifGroup
  qui gen `Dif' = .
  qui gen `DifGroup' = .

  sort `MatchID'
  forvalues ii = 1/`NumTreat' {

    if "`mahalanobis'" != "" {
      MahalanobisObs , vars(`vars') treat(`treat') refobs(`ii') ///
        gen(`Dif') replace `euclid' `equalweight' `unweighted'
    }
    else {
      local matchval = `LogOdds'[`ii']
      qui replace `Dif' = abs(`LogOdds' - `matchval')
    }

    qui replace `Dif' = . if `treat' == 1 // `restrict_str'

    sort `Dif' `MatchID'

    if "`greedy'" != "" {
      local matchid = `MatchID'[1]

      sort `MatchID'
      qui replace `MatchedID' = `matchid' in `ii'
      qui replace `nummatches' = `nummatches' + 1 if `MatchID' == `matchid'

      qui replace `matchgroup' = `ii' in `ii'
      qui replace `matchgroup' = `ii' if `MatchID' == `matchid'
    }
    else {
          drop `DifGroup'
          qui egen `DifGroup' = group(`Dif')

          qui levelsof `DifGroup' in 1/`matchnum'
          local groupids = r(levels)
          local groupids = subinstr("`groupids'", " ", ", ", .)

          sort `MatchID'
          qui count if inlist(`DifGroup', `groupids')
          local size = r(N)
          local invsize = 1/`size'

          qui replace `nummatches' = `nummatches' + `invsize' if inlist(`DifGroup', `groupids')
    }


    qui replace `Dif' = .

  }

  gen `trim' = 0
  replace `trim' = 1 if `treat' == 0 & `nummatches' == 0

end

******************************************************************************
