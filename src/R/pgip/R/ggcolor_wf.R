##' Color graph for ggplot_wf
##'
##'
ggcolor_wf <- function(graph, from = 0, to = NULL, parents_fill = NULL,
                       efrom = 0, eto = NULL,
                       pfrom = 0, pto = NULL,
                       ...) {
  if (is.null(to)) {
    to <- max(igraph::V(graph)$y)
  }
  if (is.null(eto)) {
    eto <- max(igraph::V(graph)$y)
  }
  if (is.null(pto)) {
    pto <- max(igraph::V(graph)$y)
  }
  vertices <- which(
    (igraph::V(graph)$y >= from) &
      (igraph::V(graph)$y <= to)
  )
  igraph::V(graph)$fill <- NA
  igraph::V(graph)[vertices]$fill <- "white"
  if (!is.null(parents_fill)) {
    i <- which(igraph::degree(graph, mode = "out") > 0)
    j <- which((igraph::V(graph)$y >= pfrom) &
      (igraph::V(graph)$y <= pto))
    igraph::V(graph)[intersect(i, j)]$fill <- parents_fill
  }
  igraph::V(graph)$color <- NA
  igraph::V(graph)[vertices]$color <- "black"
  if (efrom == eto) {
    graph <- tidygraph::as_tbl_graph(
      igraph::delete_edges(graph, igraph::E(graph))
    )
  } else {
    evertices <- which((igraph::V(graph)$y >= efrom) &
      (igraph::V(graph)$y < eto))
    graph <- tidygraph::as_tbl_graph(
      igraph::delete_edges(
        graph,
        igraph::E(graph)[-evertices]
      )
    )
  }
  class(graph) <- c("wf", class(graph))
  graph
}
