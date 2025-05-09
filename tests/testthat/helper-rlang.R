# Load downstream deps ahead of time to avoid pkgload issues
is_installed("tibble")
is_installed("lifecycle")

zap_attributes <- function(x) {
  attributes(x) <- NULL
  x
}
zap_srcref_attributes <- function(x) {
  attr(x, "srcref") <- NULL
  attr(x, "srcfile") <- NULL
  attr(x, "wholeSrcref") <- NULL
  x
}

run_script <- function(file, envvars = chr()) {
  skip_on_os("windows")

  # Suppress non-zero exit warnings
  suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", file),
    stdout = TRUE,
    stderr = TRUE,
    env = envvars
  ))
}

run_code <- function(code) {
  file <- withr::local_tempfile()
  writeLines(code, file)

  out <- run_script(file)
  list(
    success = identical(attr(out, "status"), 0L),
    output = vec_unstructure(out)
  )
}

local_methods <- function(..., .frame = caller_env()) {
  local_bindings(..., .env = global_env(), .frame = .frame)
}
with_methods <- function(.expr, ...) {
  local_methods(...)
  .expr
}

# Some backtrace tests use Rscript, which requires the last version of
# the backtrace code to be installed locally
skip_if_stale_backtrace <- local({
  current_backtrace_ver <- "1.0.1"

  ver <- system.file("backtrace-ver", package = "rlang")
  has_stale_backtrace <- ver == "" ||
    !identical(readLines(ver), current_backtrace_ver)

  function() {
    skip_if(has_stale_backtrace)
  }
})

skip_if_big_endian <- function() {
  skip_if(
    identical(.Platform$endian, "big"),
    "Skipping on big-endian platform."
  )
}

Rscript <- function(args, ...) {
  out <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    args,
    ...,
    stdout = TRUE,
    stderr = TRUE
  ))

  list(
    out = vec_unstructure(out),
    status = attr(out, "status")
  )
}
run <- function(code) {
  cat_line(run0(code)$out)
}
run0 <- function(code) {
  # To avoid "ARGUMENT '~+~~+~~+~~+~foo __ignored__" errors on R <= 3.5
  code <- gsub("\n", ";", code)

  Rscript(shQuote(c("--vanilla", "-e", code)))
}

expect_reference <- function(object, expected) {
  expect_true(is_reference(object, expected))
}

rlang_compats <- function(fn) {
  list(
    .rlang_compat(fn),
    .rlang_compat(fn, try_rlang = FALSE)
  )
}

# Deterministic behaviour on old R versions
data.frame <- function(..., stringsAsFactors = FALSE) {
  base::data.frame(..., stringsAsFactors = stringsAsFactors)
}

skip_if_not_windows <- function() {
  system <- tolower(Sys.info()[["sysname"]])
  skip_if_not(is_string(system, "windows"), "Not on Windows")
}

arg_match_wrapper <- function(arg, ...) {
  arg_match(arg, ...)
}
arg_match0_wrapper <- function(arg, values, arg_nm = "arg", ...) {
  arg_match0(arg, values, arg_nm = arg_nm, ...)
}

checker <- function(foo, check, ...) {
  check(foo, ...)
}

import_or_skip <- function(ns, names, env = caller_env()) {
  skip_if_not_installed(ns)
  ns_import_from(ns, names, env = env)
}

friendly_types <- function(x, vector = TRUE) {
  out <- c(
    object = obj_type_friendly(x),
    object_no_value = obj_type_friendly(x, value = FALSE)
  )

  if (vector) {
    out <- c(
      out,
      vector = vec_type_friendly(x),
      vector_length = vec_type_friendly(x, length = TRUE)
    )
  }

  out
}
