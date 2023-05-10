##' Plot wf model with ggplot2
##'
##'
ggplot_wf <- function(obj, edge_color = "lightgray", edge_width = .8,
                      point_shape = 21, point_size = 3, ...) {
  if (is.null(igraph::V(obj)$fill)) {
    fill <- "white"
  } else {
    fill <- igraph::V(obj)$fill
  }
  if (is.null(igraph::V(obj)$color)) {
    color <- "black"
  } else {
    color <- igraph::V(obj)$color
  }
  p <- ggraph::ggraph(obj, layout = obj$layout) +
    ggraph::geom_edge_link(color = edge_color, width = edge_width) +
    ggraph::geom_node_point(
      fill = fill,
      color = color,
      shape = point_shape,
      size = point_size
    ) +
    ggplot2::theme(axis.text.x = ggplot2::element_blank()) +
    ggplot2::scale_y_reverse()
  p
}
