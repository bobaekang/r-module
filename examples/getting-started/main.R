module <- local(source("module.R", local = TRUE))

module$hello_world()
#> [1] "Hello world!"

module$greet_to("friend")
#> [1] "Hi, friend. Using modules in R is easy!"
