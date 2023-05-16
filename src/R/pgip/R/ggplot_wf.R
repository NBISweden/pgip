##' Plot wf model with ggplot2
##'
##' @param graph tidygraph::tbl_graph object
##'
##' @importFrom magrittr %>%
##'
ggplot_wf <- function(graph, fill, size, width, edge_color,
                      node_color = "black", point_shape = 21,
                      x_range = NULL, y_range = NULL, show_time =
                        FALSE,
                      ...) {
  set_defaults <- function(graph, x, default, is_node = TRUE) {
    gattr <- igraph::vertex_attr
    set_gattr <- igraph::set_vertex_attr
    if (!is_node) {
      gattr <- igraph::edge_attr
      set_gattr <- igraph::set_edge_attr
    }
    if (!(as.character(x) %in% names(gattr(graph)))) {
      graph <- set_gattr(graph, x, value = default)
    }
    graph
  }

  if (missing(fill)) {
    fill <- rlang::sym("fill")
  }
  graph <- set_defaults(graph, substitute(fill), "white")
  if (missing(size)) {
    size <- rlang::sym("size")
  }
  graph <- set_defaults(graph,
    x = ifelse(is.numeric(size), "size", substitute(size)),
    default = ifelse(is.numeric(size), size, 3)
  )
  if (missing(width)) {
    width <- rlang::sym("width")
  }
  graph <- set_defaults(graph,
    x = ifelse(is.numeric(width), "width",
      substitute(width)
    ),
    default = ifelse(is.numeric(width),
      substitute(width), .8
    ),
    is_node = FALSE
  )

  if (missing(edge_color)) {
    edge_color <- rlang::sym("edge_color")
  }
  graph <- set_defaults(graph,
    x = ifelse(is.character(substitute(edge_color)),
      substitute(edge_color),
      "edge_color"
    ),
    default = ifelse(is.character(substitute(edge_color)),
      substitute(edge_color),
      "lightgray"
    ),
    is_node = FALSE
  )

  fill_scale <- graph %>%
    tidygraph::activate(nodes) %>%
    dplyr::pull(., var = {{ fill }}) %>%
    unique(.)
  fill_scale <- gray.colors(
    n = length(fill_scale),
    start = 1.0,
    end = 0.0
  )

  edge_scale <- graph %>%
    tidygraph::activate(edges) %>%
    dplyr::pull(., var = {{ edge_color }}) %>%
    unique(.)
  edge_scale <- mapply(c, edge_scale)

  if (is.null(x_range)) {
    x_range <- range(igraph::vertex_attr(graph, "x"))
  }
  if (is.null(y_range)) {
    y_range <- range(igraph::vertex_attr(graph, "y"))
  }

  p <- ggraph::ggraph(graph,
    layout = cbind(
      x = igraph::V(graph)$x,
      y = igraph::V(graph)$y
    )
  ) +
    ggraph::geom_edge_link(ggplot2::aes(
      color = {{ edge_color }},
      width = {{ width }}
    )) +
    ggraph::geom_node_point(
      ggplot2::aes(
        fill = {{ fill }},
        size = {{ size }}
      ),
      color = node_color,
      shape = point_shape
    ) +
    ggplot2::scale_fill_manual(values = fill_scale) +
    ggraph::scale_edge_color_manual(values = edge_scale) +
    ggplot2::scale_size(range = range(igraph::vertex_attr(graph, "size"))) +
    ggraph::scale_edge_width(range = range(igraph::edge_attr(graph, "width"))) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_blank(),
      legend.position = "none"
    ) +
    ggplot2::scale_y_reverse()
  if (show_time) {
    x_range[1] <- x_range[1] - 4
    x1 <- x_range[1] + 1
    p <- p +
      ggplot2::geom_segment(
        ggplot2::aes(
          x = x1, y = y_range[1],
          xend = x1, yend = y_range[2]
        ),
        arrow = ggplot2::arrow(
          length = ggplot2::unit(0.5, "cm"),
          type = "closed"
        )
      ) +
      ggplot2::annotate("text",
        label = "time",
        x = x1 - 2, y = mean(y_range), size = 10, angle = 90
      )
  }
  p <- p + ggplot2::expand_limits(x = x_range, y = y_range)
  p
}
