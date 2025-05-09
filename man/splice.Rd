% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dots.R
\name{splice}
\alias{splice}
\alias{is_spliced}
\alias{is_spliced_bare}
\title{Splice values at dots collection time}
\usage{
splice(x)

is_spliced(x)

is_spliced_bare(x)
}
\arguments{
\item{x}{A list or vector to splice non-eagerly.}
}
\description{
\code{splice()} is an advanced feature of dynamic dots. It is rarely
needed but can solve performance issues in edge cases.

The splicing operator \verb{!!!} operates both in values contexts like
\code{\link[=list2]{list2()}} and \code{\link[=dots_list]{dots_list()}}, and in metaprogramming contexts like
\code{\link[=expr]{expr()}}, \code{\link[=enquos]{enquos()}}, or \code{\link[=inject]{inject()}}. While the end result looks the
same, the implementation is different and much more efficient in
the value cases. This difference in implementation may cause
performance issues for instance when going from:

\if{html}{\out{<div class="sourceCode r">}}\preformatted{xs <- list(2, 3)
list2(1, !!!xs, 4)
}\if{html}{\out{</div>}}

to:

\if{html}{\out{<div class="sourceCode r">}}\preformatted{inject(list2(1, !!!xs, 4))
}\if{html}{\out{</div>}}

In the former case, the performant value-splicing is used. In the
latter case, the slow metaprogramming splicing is used.

A common practical case where this may occur is when code is
wrapped inside a tidyeval context like \code{dplyr::mutate()}. In this
case, the metaprogramming operator \verb{!!!} will take over the
value-splicing operator, causing an unexpected slowdown.

To avoid this in performance-critical code, use \code{splice()} instead
of \verb{!!!}:

\if{html}{\out{<div class="sourceCode r">}}\preformatted{# These both use the fast splicing:
list2(1, splice(xs), 4)
inject(list2(1, splice(xs), 4))
}\if{html}{\out{</div>}}

Note that \code{splice()} behaves differently than \verb{!!!}. The splicing happens
later and is processed by \code{list2()} or \code{dots_list()}. It does not work in any
other tidyeval context than these list collectors.
}
