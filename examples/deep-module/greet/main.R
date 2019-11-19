# import submodules
import_module("hello_world.R", attach = FALSE, quietly = TRUE)
import_module("greet_to.R", attach = FALSE, quietly = TRUE)

# export
list(
  hello_world = hello_world,
  greet_to = greet_to
)