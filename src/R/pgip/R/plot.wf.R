##' Plot wf model
##'
plot.wf <- function(graphObj, permutation, which = 1, ...) {
    g <- graphObj[[which]]
    plot(igraph::permute(g, permutation), ...)
}
