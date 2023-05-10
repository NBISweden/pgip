##' Color graph for ggplot_wf
##'
##'
ggcolor_graph <- function(obj, from = 0, to = NULL, parents_fill = NULL,
                          efrom = 0, eto = NULL,
                          pfrom = 0, pto = NULL,
                          ...) {
  if (is.null(to)) {
    to <- max(obj$layout[, 2])
  }
  if (is.null(eto)) {
    eto <- max(obj$layout[, 2])
  }
  if (is.null(pto)) {
    pto <- max(obj$layout[, 2])
  }
  vertices <- which(obj$layout[, 2] >= from &
    obj$layout[, 2] <= to)
  igraph::V(obj)$fill <- NA
  igraph::V(obj)[vertices]$fill <- "white"
  if (!is.null(parents_fill)) {
    i <- which(igraph::degree(obj, mode = "out") > 0)
    j <- which(obj$layout[, 2] >= pfrom &
      obj$layout[, 2] <= pto)
    igraph::V(obj)[intersect(i, j)]$fill <- parents_fill
  }
  igraph::V(obj)$color <- NA
  igraph::V(obj)[vertices]$color <- "black"
  if (efrom == eto) {
    obj <- igraph::delete_edges(obj, igraph::E(obj))
  } else {
    evertices <- which(obj$layout[, 2] >= efrom &
      obj$layout[, 2] < eto)
    obj <- igraph::delete_edges(obj, igraph::E(obj)[-evertices])
  }
  obj
}
