##' iGraph representation of Wright-Fisher model
##'
##' Generate small toy examples of Wright-Fisher model.
##'
##' @title iGraph representation of Wright-Fisher model
##'
##'
wf_model_igraph <- function(popsize=10, generations=10,
                            offspring_first=TRUE, untangled=TRUE,
                            p0=NULL, parent.transient=TRUE, ...) {
    G <- list()
    class(G) <- c("wf", "list")
    attr(G, "popsize") <- popsize
    attr(G, "generations") <- generations
    attr(G, "n") <- 3 * generations - 2
    g <- make_empty_graph()
    g <- add_vertices(g, popsize * generations, allele=NA, show.parent=FALSE, reproduce=NA)
    V(g)[1:popsize]$allele <- "a"
    if (!is.null(p0)) {
        stopifnot(0.0 <= p0, 1.0 >= p0)
        alleles <- sample(1:popsize, as.integer(p0 * popsize))
        V(g)[alleles]$allele <- "A"
    }
    attr(G, "perm") <- unlist(lapply(seq(vcount(g), 1, - popsize), function(x) {seq(x - popsize + 1, x)}))
    g$layout <- layout_on_grid(g, width=popsize, height=generations)
    i <- 1
    for (i in seq(1, generations)) {
        n0 <- (i - 1) * popsize + 1
        n1 <- i * popsize
        V(g)[n0:n1]$reproduce <- FALSE
        if (i >= 2) {
            p0 <- (i - 2) * popsize + 1
            p1 <- (i - 1) * popsize
            parents <- sample(p0:p1, popsize, replace=TRUE)
            #V(g)[n0:n1]$allele <- V(g)[parents]$allele
            if (untangled)
                parents <- sort(parents)
            offspring <- seq((i - 1) * popsize + 1, i * popsize)
            if (offspring_first) {
                V(g)[n0:n1]$allele <- "a"
                i.A <- which(vertex_attr(g)$allele == "A")
                G[[length(G) + 1]] <- g
            }
            edges <- unlist(Map(c, parents, offspring))
            V(g)[parents]$show.parent <- TRUE
            V(g)[parents]$reproduce <- TRUE
            V(g)[n0:n1]$allele <- V(g)[parents]$allele
            G[[length(G) + 1]] <- g
            g <- add_edges(g, edges)
            if (parent.transient)
                V(g)[parents]$show.parent <- FALSE
        }
        G[[length(G) + 1]] <- g
    }
    if (!parent.transient)
        V(G[[length(G)]])[n0:n1]$show.parent <- TRUE
    G
}
