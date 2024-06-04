## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = requireNamespace("lidR")
)

## ----setup--------------------------------------------------------------------
library(lacunr)

## -----------------------------------------------------------------------------
# convert 'glassfire' to LAS format
las_glassfire <- lidR::LAS(data = glassfire)

## ----error=TRUE---------------------------------------------------------------
# the wrong way to call voxelize() for a 'LAS' object:
vox <- voxelize(las_glassfire, edge_length = c(0.5, 0.5, 0.5))

## -----------------------------------------------------------------------------
# voxelize the LAS point cloud, taking care to input the correct S4 slot
vox <- voxelize(las_glassfire@data, edge_length = c(0.5, 0.5, 0.5))

## -----------------------------------------------------------------------------
# voxelize at 1m resolution, creating a column N containing the number of points
vox <- lidR::voxel_metrics(las_glassfire, ~list(N = length(Z)), res = 1)
# convert to array
box <- bounding_box(vox)

