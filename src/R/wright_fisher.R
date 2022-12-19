##' Wright Fisher model - follow allele frequency distribution
##'
wright_fisher <- function(p0, N, generations) {
    x <- vector(mode="numeric", length=generations)
    x[1] <- p0
    for (i in seq(2, length(x)))
        x[i] <- rbinom(1, size=N, prob=x[i-1]) / N
    x
}

