# Stata Bin Package

*Still being edited heavily and far from a finished project*

## Overview
This is a collection of small tools that I’ve written over time that are just generally useful


## Installation
To install this package, use the package https://github.com/haghish/github.

``` stata
github install robsfletch/StataBin
```

## Use

### clc
Very straightforward command to clear the window.

``` stata
clc
```

### dr
Just like ds except that you can specify regular expressions. For example, if you want to list all variables that end in e,

``` stata
sysuse auto
dr .*e$
```

### findbase
When working in a project folder, this command gives you the relative path back to the main project folder. You can then use that to call code using its path relative to the base folder.
``` stata
findbase “SampleProject”
local base = r(base)
include `base'/Code/Stata/file_header.do
```




## Uninstallation


``` Stata
github uninstall StataBin
```

## Things to look into for updating code
- atts
- stepwise
- Stata lasso
- Statsby
- prefix
- _prefix
- _on_colon_parse
- estimates table
