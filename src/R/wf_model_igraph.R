##' iGraph representation of Wright-Fisher model
##'
##' Generate small toy examples of Wright-Fisher model.
##'
##' @title iGraph representation of Wright-Fisher model
##'
##'
wf_model_igraph <- function(popsize=10, generations=10, offspring_first=TRUE, untangled=TRUE, p0=NULL, transient_parent=TRUE) {
    G <- list()
    class(G) <- c("wf", "list")
    attr(G, "popsize") <- popsize
    attr(G, "generations") <- generations
    g <- make_empty_graph()
    g <- add_vertices(g, popsize * generations, color=NA, size=0, label=NA, frame.color=NA, allele="a")
    if (!is.null(p0)) {
        stopifnot(0.0 <= p0, 1.0 >= p0)
        alleles <- sample(1:popsize, as.integer(p0 * popsize))
        V(g)[alleles]$allele <- "A"
    }
    g$perm <- unlist(lapply(seq(vcount(g), 1, - popsize), function(x) {seq(x - popsize + 1, x)}))
    g$layout <- layout_on_grid(g, width=popsize, height=generations)
    i <- 1
    for (i in seq(1, generations)) {
        n0 <- (i - 1) * popsize + 1
        n1 <- i * popsize
        if (i >= 2) {
            p0 <- (i - 2) * popsize + 1
            p1 <- (i - 1) * popsize
            parents <- sample(p0:p1, popsize, replace=TRUE)
            if (untangled)
                parents <- sort(parents)
            offspring <- seq((i - 1) * popsize + 1, i * popsize)
            if (offspring_first) {
                V(g)[n0:n1]$frame.color <- "black"
                V(g)[n0:n1]$color <- NA
                V(g)[n0:n1]$size <- 3
                i.A <- which(vertex_attr(g)$allele == "A")
                V(g)[i.A]$color <- "gray"
                G[[length(G) + 1]] <- g
            }
            edges <- unlist(Map(c, parents, offspring))
            V(g)[parents]$color <- "black"
            V(g)[n0:n1]$allele <- V(g)[parents]$allele
            G[[length(G) + 1]] <- g
            g <- add_edges(g, edges, color="black", width=2, arrow.size=0)
        }
        V(g)[n0:n1]$frame.color <- "black"
        V(g)[n0:n1]$color <- NA
        i.A <- which(vertex_attr(g)$allele == "A")
        V(g)[i.A]$color <- "gray"
        V(g)[n0:n1]$size <- 3
        G[[length(G) + 1]] <- g
    }
    G
}
