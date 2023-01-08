##' Color genes in an igraph model
##'
##'
color.genes.igraph <- function(g, frame.color="black", a.color="white",
                               A.color="darkgray", parent.color="black", ...) {
    if (is.na(frame.color)) {
        a.frame.color <- a.color
        A.frame.color <- A.color
        parent.frame.color <- parent.color
    } else {
        a.frame.color <- frame.color
        A.frame.color <- frame.color
        parent.frame.color <- frame.color
    }
    i.a <- which(vertex_attr(g)$allele == "a")
    V(g)[i.a]$color <- a.color
    V(g)[i.a]$frame.color <- a.frame.color

    i.A <- which(vertex_attr(g)$allele == "A")
    V(g)[i.A]$color <- A.color
    V(g)[i.A]$frame.color <- A.frame.color

    i.show <- which(vertex_attr(g)$show.parent)
    V(g)[i.show]$color <- parent.color
    V(g)[i.show]$frame.color <- parent.frame.color

    ## Set some default values on edges and vertices
    V(g)$size = 3
    V(g)$label = NA
    E(g)$color = "black"
    E(g)$width = 2
    E(g)$arrow.size = 0

    g
}
