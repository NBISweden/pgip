##' Wright Fisher model - follow population of individuals
##'
##' @param n Population size
##' @param generations Number of generations to simulate
##' @param p0 Mutation starting frequency or count
##' @param init_gen Add alleles at specific generation
##' @param s selection coefficient
##' @param mu mutation rate
##' @param major major allele symbol
##' @param minor minor (mutant) allele symbol
##'
##' @importFrom tidygraph tbl_graph
##'
##' @returns tbl_graph instance
##'
wright_fisher_pop <- function(n, generations, p0 = NULL,
                              init_gen = 0, s = 0,
                              mu = 0.0, major = "a", minor = "A") {
  if (!is.null(p0)) {
    stopifnot(is.numeric(p0))
    if (p0 >= 1.0) {
      p0 <- as.integer(p0)
    }
    if (is.integer(p0)) {
      stopifnot((p0 >= 1) & (p0 < n))
    } else {
      stopifnot((p0 > 0.0) & (p0 < 1.0))
    }
  }
  stopifnot(init_gen >= 0 & init_gen < (generations - 1))
  stopifnot(is.numeric(mu) & mu >= 0.0)
  wf <- expand.grid(0:(n - 1), 0:(generations - 1))
  colnames(wf) <- c("x", "y")
  wf <- cbind(node = as.numeric(rownames(wf)), wf)
  wf$allele <- rep(major, length(wf$node))
  if (!is.null(p0)) {
    if (!is.integer(p0)) {
      sample_size <- p0 * n
    } else {
      sample_size <- p0
    }
    i <- min(subset(wf, y == init_gen)$node)
    j <- max(subset(wf, y == init_gen)$node)
    k <- sample(wf$node[i:j], sample_size)
    wf$allele[k] <- minor
  }
  if (s == 0 && mu == 0.0) {
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
      i <- min(subset(wf, y == init_gen)$node)
      j <- max(subset(wf, y == init_gen)$node)
      k <- which(wf$allele[i:j] == minor)
      igraph::V(graph)[unlist(
        igraph::ego(graph,
          order = generations,
          nodes = k,
          mode = "out"
        )
      )]$allele <- minor
    }
  } else {
    for (t in 1:(generations - 1)) {
      i <- min(subset(wf, y == (t - 1))$node)
      j <- max(subset(wf, y == (t - 1))$node)
      x <- wf$node[i:j]
      weights <- 1 + (wf$allele[i:j] == minor) * s
      y <- sort(
        sample(x, length(x), replace = TRUE, prob = weights / sum(weights)),
        index.return = TRUE
      )
      alleles <- wf$allele[y$x]
      if (mu > 0.0) {
        # mutate minor -> major if mu
        k <- which(rpois(n, 2 * n * mu) > 0)
        alleles[k] <- minor
      }
      wf$parent[i:j] <- y$x
      wf$tangled[i:j] <- y$ix + min(x) - 1
      if (t > init_gen) {
        i <- min(subset(wf, y == t)$node)
        j <- max(subset(wf, y == t)$node)
        wf$allele[i:j] <- alleles
      }
    }
    edges <- data.frame(
      from = subset(wf, y < (generations - 1))$parent,
      to = subset(wf, y >= 1)$node
    )
    graph <- tidygraph::tbl_graph(wf, edges)
  }
  attr(graph, "popsize") <- n
  attr(graph, "generations") <- generations
  graph
}
