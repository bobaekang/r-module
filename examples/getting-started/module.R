hello_world <- function() {
  print("Hello world!")
}

# export
list(
  hello_world = hello_world,
  greet_to = function(name) {
    print(paste0("Hi, ", name, ". Using modules in R is easy!"))
  }
)