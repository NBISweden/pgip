##' Wright Fisher model - follow population of individuals
##'
##' @param n Population size
##' @param generations Number of generations to simulate
##' @param p0 Mutation starting frequency or count
##' @param init_gen Add alleles at specific generation
##'
##' @importFrom tidygraph tbl_graph
##'
##' @returns tbl_graph instance
##'
wright_fisher_pop <- function(n, generations, p0 = NULL,
                              init_gen = 0, s = 0,
                              mu = 0.0) {
  if (!is.null(p0)) {
    stopifnot(is.numeric(p0))
    if (is.integer(p0)) {
      stopifnot((p0 >= 1) & (p0 <= n))
    } else {
      stopifnot((p0 >= 0.0) & (p0 <= 1.0))
    }
  }
  stopifnot(init_gen >= 0)
  stopifnot(is.numeric(mu) & mu >= 0.0)
  wf <- expand.grid(0:(n - 1), 0:(generations - 1))
  colnames(wf) <- c("x", "y")
  wf <- cbind(node = as.numeric(rownames(wf)), wf)
  wf$allele <- rep("a", length(wf$node))
  # Neutral process
  if (s == 0) {
    parents <- as.data.frame(do.call(
      "rbind", tapply(
        wf$node,
        wf$y,
        function(x) {
          y <- sort(
            sample(x, length(x), replace = TRUE),
            index.return = TRUE
          )
          cbind(y$x, y$ix + min(x) - 1)
        }
      )
    ))
    wf$parent <- parents[, 1]
    wf$tangled <- parents[, 2]
    edges <- data.frame(
      from = subset(wf, y < (generations - 1))$parent,
      to = subset(wf, y >= 1)$node
    )
    graph <- tidygraph::tbl_graph(wf, edges)
    if (!is.null(p0)) {
      j <- sample(igraph::V(graph)$node[1:n], p0 * n)
      igraph::V(graph)$allele[j] <- "A"
      igraph::V(graph)[unlist(
        igraph::ego(graph,
          order = 16,
          nodes = j,
          mode = "out"
        )
      )]$allele <- "A"
    }
  } else {

  }
  attr(graph, "popsize") <- n
  attr(graph, "generations") <- generations
  class(graph) <- c("wf", class(graph))
  graph
}
