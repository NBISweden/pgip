##' Plot wf model
##'
plot.wf <- function(G, which=1, ...) {
    g <- G[[which]]
    plot(permute(g, perm), ...)
}
