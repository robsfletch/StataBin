program DHSLabel, rclass
version 10
    syntax , local(string) [numbers(numlist) ONE]

    if "`numbers'" == "" {
      local numbers = "-100 -50 -20 0 20 50 100 200 500"
    }

    local lab = ""
    foreach p of numlist `numbers' {
      local x = (`p'/100) + 1
      if "`one'" == "" {
        local g = (2*(`x' - 1))/(`x'  + 1)
      }
      else {
        local g = (`x' - 1)/(`x'  + 1)
      }
      local lab =`"`lab' `g' "`p'%" "'
    }

    c_local `local' `"`lab'"'
    return local label = `"`lab'"'

end
