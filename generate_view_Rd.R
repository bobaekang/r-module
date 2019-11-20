# generate Rdocumentation for functions and view them locally

library(roxygen2)

generate_Rd <- function(path) {
  roc <- rd_roclet()

  results <- roclet_process(roc, blocks = parse_file(path), base_path = ".")

  roclet_output(roc, results = results, base_path = ".")
}

view_Rd <- function(fname) {
  Rd <- file.path(paste0("./man/", fname, ".Rd"))

  html <- tools::Rd2HTML(Rd, tempfile(fileext = ".html"))

  if ("rstudioapi" %in% installed.packages() && rstudioapi::isAvailable()) {
    rstudioapi::viewer(html)
  } else
    browseURL(html)
}

generate_Rd("import_module.R")

# view locally
# view_Rd("import_module")
# view_Rd("import_module_help")
