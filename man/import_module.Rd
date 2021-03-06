% Generated by roxygen2: do not edit by hand
% Please edit documentation in ./import_module.R
\name{import_module}
\alias{import_module}
\title{Import an R "module"}
\usage{
import_module(
  path,
  name,
  attach = FALSE,
  deep = FALSE,
  force = FALSE,
  quietly = FALSE
)
}
\arguments{
\item{path}{A character string for the path to a module file.}

\item{name}{A character string for an optional module name.}

\item{attach}{A logical value. If \code{attach = TRUE}, attach module to
the search path. If \code{attach = FALSE} (default), create a module object
in the global environment.}

\item{deep}{A logical value. If \code{deep = TRUE}, allow hierachical
structure for module. Local use only.}

\item{force}{A logical value. If \code{force = TRUE}, force to import
a module even if another with the same name already exists.}

\item{quitely}{A logical value. If \code{quitely = TRUE}, skip message.}
}
\description{
Import a "module" from \code{path} using an optional \code{name}.
See \url{https://github.com/bobaekang/r-module} for a detailed explanation.
}
\examples{
# import a local module
import_module("module.R")                            # assign to a name
import_module("module.R", attach = TRUE)             # attach to search path
import_module("module.R", name = "awesome_module")   # pick a name

# import a remote module
path <- "https://tinyurl.com/r-module/examples/getting-started/module.R"
import_module(path = path)

# import a "deep" module, local use only
# see https://github.com/bobaekang/r-module#deep-module
import_module(path = "greet/main.R", deep = TRUE)
}
\seealso{
\code{\link[base]{attach}} for attaching R object to search path.

\code{\link[base]{assign}} for assigning a value to name.
}
