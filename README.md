# R module

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository explains how to use modules in R and provides examples and a helper function.

This is the latest iteration of the same core idea. Find my previous attempt at it in [this repository](https://github.com/bobaekang/r-module-trick).

## Table of contents

* [Motivation](#motivation)
* [Using R module](#using-r-module)
  * [Getting started](#getting-started)
  * [How it works](#how-it-works)
  * [`import_module()` function](#import_module-function)
  * ["Deep" module](#deep-module)
  * [Caveats](#caveats)
* [References](#references)
* [License](#license)

## Motivation

R is a powerful and versatile tool that is great for most data analysis and data science projects. However, one of the weaknesses of R language is its lack of native support for the module pattern.

Yes, R has packages. And yes again, creating one is by no means a Herculean task, especially with the fantastic `devtools` package. Hadley Wickham, best known as the creator of popular `tidyverse`, also has written a free book, [*R Packages*](http://r-pkgs.had.co.nz/), to teach us everything about creating one! Nonetheless, in my personal experience, the convenience of quickly putting together some oft-used functionalities into a small reusable unit is still much to be desired.

To tackle this issue, a few fellow R users who are much skilled than I have already put together packages. One such package is [`modules` by Sebastian Warnholz](https://github.com/wahani/modules), which is available on CRAN. See the package vignette page [here](https://cran.r-project.org/web/packages/modules/vignettes/modulesInR.html). Another package is available at ["klmr/modules" Github repository](https://github.com/klmr/modules). The later is a rather strict translation of Python modules in R.

Here, I sought for a simple "base R" solution for implementing the module pattern. My solution is not as robust or elegant as the aforementioned alternatives. However, I am convinced that my little trick still merits any R user's consideration when it comes to simplicity and convenience.

## Using R module

### Getting started

> NOTE: Example R scripts can be found in `examples/getting-started/` 

The key idea here is to evaluate the module script in a local environment to keep its values encapsulated. This involves the following two elements:

1. set `local = TRUE` when `source()`-ing a module script, and
2. evaluate it in a local environment using `local()`.

```r
# main.R

module <- local(source("module.R", local = TRUE)$value)
```

Here, simply `source()`-ing our module script will give more than what we want and we have to extract the actual module using `$value`. I'll explain this point [later](#how-it-works).

So how does a module script look like?

```r
# module.R

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
```

The only requirement here is that the module script ends with a `list` of R functions and objects to export.

:sparkles: **And that's it!** :sparkles:

### How it works

When we "import" a module using `source()`, R evaluates the module script from top to bottom in an encapsulated, local environment and returns the last value--just as in a function. In our case, this return value is a list object, created by `list()` at the end of the script, to expose module functions and objects.

The fact that only the last value will be the return value means it is also possible to both 1) create a function or an object beforehand and then pass it to `list()` and 2) create a function or an object within the `list` call. This allows for implementing some operations that are "private", i.e. not exposed to module users.

However, as mentioned earlier, simply `source()`-ing a module script gives more than what we want. This is because `source()` returns a list containing two elements: 1) `$value`, which is the return value of the `source()`-d script, and 2) `$visible`, a boolean (logical) value for the "visibility" of the `$value`.

```r
typeof(source("module.R"))
#> [1] "list"

print(source("module.R"))           
#> $value
#> $value$hello_world
#> function () {
#>   print("Hello world!")
#> }
#> 
#> $value$greet_to
#> function (name) {
#>     print(paste0("Hi, ", name, ". Using modules in R is easy!"))
#>   }
#> 
#> 
#> $visible
#> [1] TRUE
```

Therefore, we must bind the `$value` of the `source()` output to a name to keep the actual module easily accessible. This is how we got the `main.R` code above for "importing" a module:

```r
# main.R

module <- local(source("module.R", local = TRUE)$value)

module$hello_world()
#> [1] "Hello world!"

module$greet_to("Bobae")
#> [1] "Hi, Bobae. Using modules in R is easy!"
```

:tada: **Congratulations! Now you know how to use modules in R!** :tada:

By the way, did you know that `source()` can also take a URL for its `file` argument? This means that you can `source(url)` to read a module script from a remote location, say, inside a GitHub repository. This ability to use a module script stored remotely opens up whole new possibilities!

### `import_module()` function

To make it easier to use R modules, this repository offers a helper function called `import_module()`. To use `import_module()`, first `source()` the `import_module.R` file in this repository.

> NOTE: `https://tinyurl.com/r-module/*` is redirected to `https://raw.githubusercontent.com/bobaekang/r-module/master/*`.

```r
# source from url
source("https://tinyurl.com/r-module/import_module.R")
```

This adds to the global environment the following two functions:

* `import_module(path, name, attach = FALSE, deep = FALSE, quietly = FALSE)` to import an R module
* `import_module_help()` to display documentation for `import_module()`

In essense, `import_module()` is a thin wrapper over `source()` with `local()`. But it also provides the following convenience features:

* If `name` is missing (default), `import_module()` will use the R file name as the module name when attaching it to the search path or creating an object in the current environment. If `name` is provided, its value will be used.
* Setting `attach = FALSE` (default) will automatically create an R object in the current environment. Alternatively, setting `attach = TRUE` will automatically attach the module to the search path as `module:[name]`.
* Seeting `deep = TRUE` will allow `import_module()` to load a module that `source()` other R scripts inside it. This behavior is useful when using ["deep" module](#deep-module). Using `deep` is allowed for _local use only_.
* Setting `quietly = TRUE` will prevent `import_module()` from printing a message at the end for a successful import. This behavior is useful when using ["deep" module](#deep-module).
* To avoid overwriting existing modules and objects, `import_module()` first inspects the current environment (if `attach = FALSE`) or the search path (if `attach = TRUE`). If the module with the same name already exists, `import_module()` will return an error.

Also see the documentation for quick reference.

```r
# see documentation for import_module
import_module_help()
```

With `import_module()`, the example above can be rewritten as follows:

```r
# main.R

source("https://tinyurl.com/r-module/import_module.R")
import_module("module.R")
#> Note: 'module' now available in the current environment

module$hello_world()
#> [1] "Hello world!"

module$greet_to("friend")
#> [1] "Hi, friend. Using modules in R is easy!"
```

To mirror the original behavior more closely, we can set `quietly = FALSE` to turn off the message. In my view, seeing the message can be helpful especially when working interactively.

We can also attach the module to the search path by setting `attach = TRUE`.

```r
# main.R

source("https://tinyurl.com/r-module/import_module.R")
import_module("module.R", attach = TRUE)
#> Note: 'module' now attached as 'module:module'

hello_world()
#> [1] "Hello world!"

greet_to("friend")
#> [1] "Hi, friend. Using modules in R is easy!"
```

### "Deep" module

> NOTE: Example R scripts can be found in `examples/deep-module/` 

We can push this trick a little further to get a "deep" R module that is hierarchically structured and consists of submodules.

Let's say we have a module folder `greet/` with the following file structure:

```
greet/
        main.R
        hello_world.R
        greet_to.R
```

Here, `greet/hello_world.R` and `greet/greet_to.R` contain module functions.

```r
# greet/hello_world.R

function() {
  print("Hello world!")
}
```

```r
# greet/greet_to.R

function(name) {
  print(paste0("Hi, ", name, ". Using modules in R is easy!"))
}
```

Note that here we do not create a `list` to export since each script only has one default function to export.

Now, on the other hand, `greet/main.R` serves as a module entrypoint script. Using `import_module()`, we can register module functions into `greet/main.R`.

```r
# greet/main.R

# import submodules
import_module("hello_world.R", quietly = TRUE)
import_module("greet_to.R", quietly = TRUE)

# export
list(
  hello_world = hello_world,
  greet_to = greet_to
)
```

The choice of calling this entrypoint script `main.R` is arbitrary. Since R module is not a built-in language feature, the name of an entrypoint script is ultimately irrelevant. We can name it `init.R` following Python or `index.R` as in JavaScript. In any case, it would be a good practice to choose one and stick to it.

Now that the module is ready, we can import and use it outside `greet/`. With `import_module()`, this looks like the following:

```r
# main.R

source("https://tinyurl.com/r-module/import_module.R")

import_module("greet/main.R", deep = TRUE)
#> Note: 'greet' now available in the current environment

greet$hello_world()
#> [1] "Hello world!"
```

Note that `import_module()` is smart enough to use the module directory name as the module name. This is only the default behavior and we can override it with `name` argument if needed.

We can push this even further to create a module that contains submodules that has submodules... Here is a possible structure of such a "deep" module, adapted from [Python documentation on packages](https://docs.python.org/3/tutorial/modules.html#packages):

```
sound/                        Top level module directory
        main.R                Top-level module entrypoint
        formats/              Submodule directory for file format conversions
                main.R        Submodule entrypoint
                wavread.R
                wavwrite.R
                aiffread.R
                aiffwrite.R
                auread.R
                auwrite.R
                ...
        effects/              Submodule directory for sound effects
                main.R        Submodule entrypoint
                echo.R
                surround.R
                reverse.R
                ...
        filters/              Submodule directory for filters
                main.R        Submodule entrypoint
                equalizer.R
                vocoder.R
                karaoke.R
                ...
```

Please note that "deep" R module can be used without relying on `import_module()` since `import_module()` is only a thin wrapper over `source()` with `local()`. I will leave how to you.

### Caveats

1. Clearly, R module as presented in this repository is *not* a replacement for full-fledged R package. Apart from the fact that there is no binary installation of a module, for instance, there is no easy way to add vignettes to module or documentation to its contents that can be accessed with `help()` or `?`.

2. If you are importing external packages within your module script, please note that the package will be also attached in the main script's global environment as you "import" the module script. Consider the implications of this behavior and revise your module script accordingly as needed.

3. Using a "deep" module hosted remotely can be difficult since reletive paths in remote scripts no longer makes much sense. For this reason, `import_module()` only supports local "deep" modules.

4. R module introduced here is ultimately a *trick*. Use it as you deem fit. However, if you are looking for a more robust and elaborate solution, check out existing packages designed to support the module pattern in R or simply create your own package.

## References

* ["klmr/modules" package Github repository](https://github.com/klmr/modules)
* [*R Packages*](http://r-pkgs.had.co.nz/) by Hadley Wickham
* ["wahani/modules" package Github repository](https://github.com/wahani/modules)

## License

[MIT](http://opensource.org/licenses/MIT)

Copyright (c) 2019 Bobae Kang