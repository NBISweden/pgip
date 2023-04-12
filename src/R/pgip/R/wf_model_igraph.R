##' iGraph representation of Wright-Fisher model
##'
##' Generate small toy examples of Wright-Fisher model.
##'
##' @title iGraph representation of Wright-Fisher model
##'
##' @param popsize Population size
##' @param generations Number of generations
##' @param offspring_first Start from offspring (?)
##' @param untangled Untangle graph
##' @param p0 Starting frequency
##' @param parent_transient
##'
##'
wf_model_igraph <- function(popsize = 10, generations = 10,
                            offspring_first = TRUE, untangled = TRUE,
                            p0 = NULL, parent_transient = TRUE, ...) {
  grobj <- list()
  class(grobj) <- c("wf", "list")
  attr(grobj, "popsize") <- popsize
  attr(grobj, "generations") <- generations
  attr(grobj, "n") <- 3 * generations - 2
  g <- igraph::make_empty_graph()
  g <- igraph::add_vertices(g, popsize * generations,
    allele = NA,
    show.parent = FALSE, reproduce = NA
  )
  igraph::V(g)[1:popsize]$allele <- "a"
  if (!is.null(p0)) {
    stopifnot(0.0 <= p0, 1.0 >= p0)
    alleles <- sample(1:popsize, as.integer(p0 * popsize))
    igraph::V(g)[alleles]$allele <- "A"
  }
  attr(grobj, "perm") <- unlist(
    lapply(
      seq(igraph::vcount(g), 1, -popsize),
      function(x) {
        seq(x - popsize + 1, x)
      }
    )
  )
  g$layout <- igraph::layout_on_grid(g, width = popsize, height = generations)
  i <- 1
  for (i in seq(1, generations)) {
    n0 <- (i - 1) * popsize + 1
    n1 <- i * popsize
    igraph::V(g)[n0:n1]$reproduce <- FALSE
    if (i >= 2) {
      p0 <- (i - 2) * popsize + 1
      p1 <- (i - 1) * popsize
      parents <- sample(p0:p1, popsize, replace = TRUE)
      if (untangled) {
        parents <- sort(parents)
      }
      offspring <- seq((i - 1) * popsize + 1, i * popsize)
      if (offspring_first) {
        igraph::V(g)[n0:n1]$allele <- "a"
        grobj[[length(grobj) + 1]] <- g
      }
      edges <- unlist(Map(c, parents, offspring))
      igraph::V(g)[parents]$show.parent <- TRUE
      igraph::V(g)[parents]$reproduce <- TRUE
      igraph::V(g)[n0:n1]$allele <- igraph::V(g)[parents]$allele
      grobj[[length(grobj) + 1]] <- g
      g <- igraph::add_edges(g, edges)
      if (parent_transient) {
        igraph::V(g)[parents]$show.parent <- FALSE
      }
    }
    grobj[[length(grobj) + 1]] <- g
  }
  if (!parent_transient) {
    igraph::V(grobj[[length(grobj)]])[n0:n1]$show.parent <- TRUE
  }
  grobj
}
