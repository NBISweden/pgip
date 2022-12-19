##' Plot wf model
##'
plot.wf <- function(G, which=1, ...) {
    plot(permute(G[[which]], G[[1]]$perm), ...)
}
