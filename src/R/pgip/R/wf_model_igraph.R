##' iGraph representation of Wright-Fisher model
##'
##' Generate small toy examples of Wright-Fisher model.
##'
##' @title iGraph representation of Wright-Fisher model
##'
##' @param popsize Population size
##' @param generations Number of generations
##'
wf_model_igraph <- function(popsize = 10, generations = 10, p0 = 0, ...) {
  stopifnot(p0 >= 0 & p0 <= 1)
  g <- igraph::make_empty_graph()
  g <- igraph::add_vertices(g, popsize * generations, allele = "a")
  g$layout <- igraph::layout_on_grid(g,
    width = popsize,
    height = generations
  )
  nodes <- seq(popsize * generations)
  if (p0 > 0) {
    nmut <- round(p0 * popsize)
    i <- sample(subset(nodes, g$layout[, 2] == 0), nmut)
    igraph::V(g)$allele[i] <- "A"
  }
  parents <- do.call("rbind", tapply(
    nodes, g$layout[, 2],
    function(x) {
      y <- sort(
        sample(x, length(x), replace = TRUE),
        index.return = TRUE
      )
      cbind(y$x, y$ix + min(x) - 1)
    }
  ))
  g$tangled <- parents[, 2]
  edges <- unlist(Map(
    c, parents[1:(length(parents[, 1]) - popsize), 1],
    nodes[(popsize + 1):length(nodes)]
  ))
  g <- igraph::add_edges(g, edges)
  if (p0 > 0) {
    ## Make edo from A alleles and copy state
  }
  g
}
