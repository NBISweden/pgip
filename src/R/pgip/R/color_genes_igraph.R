##' Color genes in an igraph model
##'
##'
color_genes_igraph <- function(g, frame_color = "black", min_color = "white",
                               maj_color = "darkgray", parent_color = "black",
                               ...) {
  v_color <- igraph::V(g)$color
  v_color_index <- which(!is.na(igraph::V(g)$color))
  if (is.na(frame_color)) {
    min_frame_color <- min_color
    maj_frame_color <- maj_color
    parent_frame_color <- parent_color
  } else {
    min_frame_color <- frame_color
    maj_frame_color <- frame_color
    parent_frame_color <- frame_color
  }
  i_min <- which(igraph::vertex_attr(g)$allele == "a")
  igraph::V(g)[i_min]$color <- min_color
  igraph::V(g)[i_min]$frame.color <- min_frame_color

  i_maj <- which(igraph::vertex_attr(g)$allele == "A")
  igraph::V(g)[i_maj]$color <- maj_color
  igraph::V(g)[i_maj]$frame.color <- maj_frame_color

  i_show <- which(igraph::vertex_attr(g)$show.parent)
  igraph::V(g)[i_show]$color <- parent_color
  igraph::V(g)[i_show]$frame.color <- parent_frame_color

  ## Set some default values on edges and vertices
  igraph::V(g)$size <- 3
  igraph::V(g)$label <- NA
  igraph::E(g)$color <- "black"
  igraph::E(g)$width <- 2
  igraph::E(g)$arrow.size <- 0

  ## Reset custom colors
  igraph::V(g)$color[v_color_index] <- v_color[v_color_index]

  g
}
