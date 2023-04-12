##' Plot wf model
##'
plot.wf <- function(graph_obj, permutation, which = 1, ...) {
  g <- graph_obj[[which]]
  plot(igraph::permute(g, permutation), ...)
}
