source("https://tinyurl.com/r-module/import_module.R")

import_module("greet/main.R", deep = TRUE)
#> Note: 'greet' now attached as 'module:greet'

hello_world()
#> [1] "Hello world!"