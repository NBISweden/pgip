##' Color genes in an igraph model
##'
##'
color_genes_igraph <- function(g, frame.color = "black", a.color = "white",
                               A.color = "darkgray", parent.color = "black",
                               ...) {
    if (is.na(frame.color)) {
        a.frame.color <- a.color
        A.frame.color <- A.color
        parent.frame.color <- parent.color
    } else {
        a.frame.color <- frame.color
        A.frame.color <- frame.color
        parent.frame.color <- frame.color
    }
    i.a <- which(igraph::vertex_attr(g)$allele == "a")
    igraph::V(g)[i.a]$color <- a.color
    igraph::V(g)[i.a]$frame.color <- a.frame.color

    i.A <- which(igraph::vertex_attr(g)$allele == "A")
    igraph::V(g)[i.A]$color <- A.color
    igraph::V(g)[i.A]$frame.color <- A.frame.color

    i.show <- which(igraph::vertex_attr(g)$show.parent)
    igraph::V(g)[i.show]$color <- parent.color
    igraph::V(g)[i.show]$frame.color <- parent.frame.color

    ## Set some default values on edges and vertices
    igraph::V(g)$size <- 3
    igraph::V(g)$label <- NA
    igraph::E(g)$color <- "black"
    igraph::E(g)$width <- 2
    igraph::E(g)$arrow.size <- 0

    g
}
