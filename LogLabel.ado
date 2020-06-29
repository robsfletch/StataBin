program LogLabel, rclass
version 10
    syntax , numbers(numlist) local(string) [ADDONE THOUSANDS ABREV]

    local lab = ""
    if "`thousands'" != "" {
      foreach x of numlist `numbers' {
        local prettyx = "`x'"
        if "`addone'" != "" {
          local val = log(1 + `x')
        }
        else {
          local val = log(`x')
        }
        if `x' == 1000 {
          local prettyx = "1"
        }
        if `x' == 2000 {
          local prettyx = "2"
        }
        if `x' == 5000 {
          local prettyx = "5"
        }
        if `x' == 10000 {
          local prettyx = "10"
        }
        if `x' == 20000 {
          local prettyx = "20"
        }
        if `x' == 50000 {
          local prettyx = "50"
        }
        if `x' == 100000 {
          local prettyx = "100"
        }
        if `x' == 200000 {
          local prettyx = "200"
        }
        if `x' == 500000 {
          local prettyx = "500"
        }
        if `x' == 1000000 {
          local prettyx = "1,000"
        }
        if `x' == 2000000 {
          local prettyx = "2,000"
        }
        if `x' == 5000000 {
          local prettyx = "5,000"
        }
        if `x' == 10000000 {
          local prettyx = "10,000"
        }
        if `x' == 20000000 {
          local prettyx = "20,000"
        }
        if `x' == 50000000 {
          local prettyx = "50,000"
        }
        if `x' == 100000000 {
          local prettyx = "100,000"
        }
        if `x' == 200000000 {
          local prettyx = "200,000"
        }
        if `x' == 200000000 {
          local prettyx = "200,000"
        }
        if `x' == 1000000000 {
          local prettyx = "1,000,000"
        }
        if `x' == 2000000000 {
          local prettyx = "2,000,000"
        }
        if `x' == 5000000000 {
          local prettyx = "5,000,000"
        }
        local lab =`"`lab' `val' "`prettyx'" "'
      }
    }
    *******************************************************************************
    **
    *******************************************************************************
    else if "`abrev'" != "" {
      foreach x of numlist `numbers' {
        local prettyx = "`x'"
        if "`addone'" != "" {
          local val = log(1 + `x')
        }
        else {
          local val = log(`x')
        }
        if `x' == 1000 {
          local prettyx = "1 K"
        }
        if `x' == 10000 {
          local prettyx = "10 K"
        }
        if `x' == 100000 {
          local prettyx = "100 K"
        }
        if `x' == 1000000 {
          local prettyx = "1 Mil"
        }
        if `x' == 10000000 {
          local prettyx = "10 Mil"
        }
        if `x' == 100000000 {
          local prettyx = "100 Mil"
        }
        local lab =`"`lab' `val' "`prettyx'" "'
      }
    }
*******************************************************************************
**
*******************************************************************************
    else {
      foreach x of numlist `numbers' {
        local prettyx = "`x'"
        if "`addone'" != "" {
          local val = log(1 + `x')
        }
        else {
          local val = log(`x')
        }
        local lab =`"`lab' `val' "`prettyx'" "'
      }
    }

    c_local `local' `"`lab'"'
    return local label = `"`lab'"'

end
