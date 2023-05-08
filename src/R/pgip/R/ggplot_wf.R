##' Plot wf model with ggplot2
##'
ggplot_wf <- function(obj, permutation = NULL, generation = 1,
                      edge_color = "lightgray", edge_width = .8,
                      point_shape = 21, point_size = 3, ...) {
  generations <- max(obj$layout[, 2]) + 1
  color <- unlist(rev(
    split(igraph::V(obj)$color, cut(seq_along(igraph::V(obj)$color),
      generations,
      labels = FALSE
    ))
  ))
  if (!is.null(permutation)) {
    obj <- igraph::permute(obj, permutation)
  }

  p <- ggraph::ggraph(obj, layout = obj$layout) +
    ggplot2::geom_edge_link(color = edge_color, width = edge_width) +
    ggplot2::geom_node_point(
      fill = color, shape = point_shape,
      size = point_size
    ) +
    ggplot2::theme(axis.text.x = ggplot2::element_blank())
  p
}
