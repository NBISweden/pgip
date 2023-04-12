##' Wright Fisher model - follow allele frequency distribution
##'
##' @param p0 Starting frequency
##' @param n Population size
##' @param generations Number of generations to simulate
##'
wright_fisher <- function(p0, n, generations) {
  x <- vector(mode = "numeric", length = generations)
  x[1] <- p0
  for (i in seq(2, length(x))) {
    x[i] <- rbinom(1, size = n, prob = x[i - 1]) / n
  }
  x
}
