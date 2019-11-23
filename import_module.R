# Author: Bobae Kang (@bobaekang)
# License: MIT

#' Import an R "module"
#' 
#' Import a "module" from \code{path} using an optional \code{name}.
#' See \url{https://github.com/bobaekang/r-module} for a detailed explanation.
#' 
#' @param path A character string for the path to a module file.
#' @param name A character string for an optional module name.
#' @param attach A logical value. If \code{attach = TRUE}, attach module to
#'  the search path. If \code{attach = FALSE} (default), create a module object
#'  in the global environment.
#' @param deep A logical value. If \code{deep = TRUE}, allow hierachical
#'  structure for module. Local use only.
#' @param force A logical value. If \code{force = TRUE}, force to import
#'  a module even if another with the same name already exists.
#' @param quitely A logical value. If \code{quitely = TRUE}, skip message.
#' @seealso \code{\link[base]{attach}} for attaching R object to search path.
#' @seealso \code{\link[base]{assign}} for assigning a value to name.
#' @examples
#' # import a local module
#' import_module("module.R")                            # assign to a name
#' import_module("module.R", attach = TRUE)             # attach to search path
#' import_module("module.R", name = "awesome_module")   # pick a name
#' 
#' # import a remote module
#' path <- "https://tinyurl.com/r-module/examples/getting-started/module.R"
#' import_module(path = path)
#' 
#' # import a "deep" module, local use only
#' # see https://github.com/bobaekang/r-module#deep-module
#' import_module(path = "greet/main.R", deep = TRUE)
import_module <- function(
  path,
  name,
  attach = FALSE,
  deep = FALSE,
  force = FALSE,
  quietly = FALSE
) {
  # sanity checks
  if (missing(path))
    stop("argument 'path' missing")
  
  if (!grepl("\\.R$", path))
    stop ("argument 'path' not an R file")

  if (!is.logical(attach))
    stop("argument 'attach' not logical")

  if (grepl("^http?s", path) && deep)
    stop ("argument 'deep' allowed for local use only")

  # define module name to use if missing
  if (missing(name)) {
    flatsplit <- function(str, ...) unlist(strsplit(str, ...))

    if (deep) {
      name <- tail(flatsplit(path, '/'), 2)[1]
    } else {
      filename <- tail(flatsplit(path, '/'), 1)
      name <- head(flatsplit(filename, '\\.'), -1)
    }
  }

  # import module from path
  mod <- local(source(path, local = TRUE, chdir = deep)$value)

  if (attach) {
    mod_name <- paste0("module:", name)
    
    if (mod_name %in% search()) {
      if (force) {
        do.call("detach", list(mod_name))
      } else
        stop("'", mod_name, "' already attached. Use detach() if needed.")
    }
    
    attach(what = mod, name = mod_name)
      
    msg <- paste0("Note: '", name, "' now attached as '", mod_name, "'")
  } else {
    if (exists(name) && !force)
      stop("object '", name, "' already exists. Use remove() if needed.")
    
    assign(x = name, value = mod, envir = parent.frame())
    
    msg <- paste0("Note: '", name, "' now available in the current environment")
  }

  # print message
  if (!quietly)
    message(msg)
}

#' Open documentation for \code{import_module}
#' 
#' Open a rendered HTML page of \code{import_module} documentation.
#' See \url{https://github.com/bobaekang/r-module} for a detailed explanation.
#' 
#' @param self A logical value. If \code{self = FALSE} (default), show
#'  documentation for \code{import_module}. If \code{self = TRUE}, show
#'  docuemntation for this function.
import_module_help <- function(self = FALSE) {
  filename <- if (self) "import_module_help.Rd" else "import_module.Rd"
  Rd <- url(paste0("https://tinyurl.com/r-module/man/", filename))
  html <- tools::Rd2HTML(Rd, tempfile(fileext = ".html"))
  
  if ("rstudioapi" %in% installed.packages() && rstudioapi::isAvailable()) {
    rstudioapi::viewer(html)
  } else
    browseURL(html)
}
