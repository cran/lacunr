## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  dev = "png", dev.args = list(type = "cairo-png"),
  fig.retina=2,
  pngquant = "--speed=1 --quality=50"
)

## -----------------------------------------------------------------------------
library(lacunr)
# create a data.frame of simulated point cloud data
set.seed(5678)
pc <- data.frame(X = rnorm(1000, 10), Y = rnorm(1000, 50), Z = rnorm(1000, 25))
# convert to voxels of size 0.5
vox <- voxelize(pc, edge_length = c(0.5, 0.5, 0.5))
# generate 3D array
box <- bounding_box(vox)
# calculate lacunarity curve
lac_curve <- lacunarity(box)

## ----fig.width=6, out.width="97%", fig.asp=1/2--------------------------------
# plot lacunarity curve
plot <- lac_plot(lac_curve)
print(plot)

## -----------------------------------------------------------------------------
# add two layers of empty space to the Z axis of the array
box_pad1 <- pad_array(box, z = 2)
# add two layers of occupied space to the Y axis of the array
box_pad2 <- pad_array(box, y = 2, fill = 1)

