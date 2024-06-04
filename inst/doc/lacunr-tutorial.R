## ----include = FALSE----------------------------------------------------------
knitr::knit_hooks$set(pngquant = knitr::hook_pngquant)
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  dev = "png", dev.args = list(type = "cairo-png"),
  fig.retina=2,
  pngquant = "--speed=1 --quality=50"
)

## ----setup--------------------------------------------------------------------
library(lacunr)

## -----------------------------------------------------------------------------
# 16*16*16 uniform array
uniform <- array(data = c(rep(c(rep(c(1,0),8), rep(c(0,1),8)),8),
                          rep(c(rep(c(0,1),8), rep(c(1,0),8)),8)), 
                 dim = c(16,16,16))

## -----------------------------------------------------------------------------
# 16*16*16 segregated array
segregated <- array(data = c(rep(1, 2048), rep(0, 2048)),
                    dim = c(16,16,16))

## -----------------------------------------------------------------------------
# 16*16*16 random array
set.seed(245)
random <- array(data = sample(c(rep(1,2048), rep(0,2048)), 4096, replace = FALSE),
                dim = c(16,16,16))

## -----------------------------------------------------------------------------
# 16*16*16 gradient array
set.seed(245)
gradient <- array(data = sample(c(rep(1,2048), rep(0,2048)), 4096, replace = FALSE,
                                prob = c(rep(0.9,2048), rep(0.1,2048))),
                  dim = c(16,16,16))

## ----echo=FALSE---------------------------------------------------------------
# store the default graphics parameters so they can be reset later
defaultpar <- par(no.readonly = TRUE)

## ----fig.width=6, fig.asp=1/4, out.width="97%"--------------------------------
par(mfrow = c(1, 4), mar = c(0.5,0.5,0.5,0.5), bg = "gray90")
image(t(uniform[1,,]),col = c("white","black"),axes = FALSE, asp = 1)
image(t(segregated[1,,]),col = c("white","black"),axes = FALSE, asp = 1)
image(t(random[1,,]),col = c("white","black"),axes = FALSE, asp = 1)
image(t(gradient[1,,]),col = c("white","black"),axes = FALSE, asp = 1)

## ----echo=FALSE---------------------------------------------------------------
# reset graphics parameters to default
par(defaultpar)

## -----------------------------------------------------------------------------
# calculate lacunarity at all box sizes for each array
lac_unif <- lacunarity(uniform, box_sizes = "all")
lac_segregated <- lacunarity(segregated, box_sizes = "all")
lac_random <- lacunarity(random, box_sizes = "all")
lac_grad <- lacunarity(gradient, box_sizes = "all")

## ----fig.width=6, out.width="97%", fig.asp=1/2--------------------------------
# plot all four lacunarity curves
lac_plot(lac_segregated, lac_grad, lac_random, lac_unif,
         group_names = c("Segregated","Gradient","Random","Uniform"))

## ----eval=FALSE---------------------------------------------------------------
#  library(ggplot2)
#  
#  # plot point cloud data at each time point
#  plot <- ggplot(data = glassfire, aes(x = X, y = Y)) +
#    geom_raster(aes(fill = Z)) +
#    facet_grid(cols = vars(Year)) +
#    scale_fill_viridis_c(option = "plasma") +
#    theme(panel.grid = element_blank(),
#          panel.background = element_rect(fill = "black"),
#          aspect.ratio = 1)
#  print(plot)

## ----echo=FALSE, fig.width=6, out.width="97%", fig.asp=1/2, cache=FALSE-------
library(ggplot2)
suppressPackageStartupMessages(library(data.table))

raster <- glassfire[, .(X,Y,Z,Year,
                        XY = paste0(as.character(X), ",", as.character(Y)))][
  , .(X = first(X),Y = first(Y),Z = max(Z)), by = .(Year, XY)]

# plot point cloud data at each time point
plot <- ggplot(data = raster, aes(x = X, y = Y)) +
  geom_raster(aes(fill = Z)) +
  facet_grid(cols = vars(Year)) +
  scale_fill_viridis_c(option = "plasma") +
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill = "black"),
        aspect.ratio = 1)
print(plot)

## -----------------------------------------------------------------------------
# voxelize the pre-fire point cloud
voxpre <- voxelize(glassfire[glassfire$Year == "2020",], edge_length = c(0.5,0.5,0.5))
# voxelize the post-fire point cloud
voxpost <- voxelize(glassfire[glassfire$Year == "2021",], edge_length = c(0.5,0.5,0.5))

## -----------------------------------------------------------------------------
# create array for pre-fire voxels
boxpre <- bounding_box(voxpre, threshold = 1)
# create array for post-fire voxels
boxpost <- bounding_box(voxpost, threshold = 1)

## -----------------------------------------------------------------------------
dim(boxpre)
dim(boxpost)

## -----------------------------------------------------------------------------
# pad the top of the pre-fire array with one layer of empty space
boxpre <- pad_array(boxpre, z = 1)

## -----------------------------------------------------------------------------
dim(boxpre) == dim(boxpost)

## -----------------------------------------------------------------------------
lac_pre <- lacunarity(boxpre, box_sizes = "all")
lac_post <- lacunarity(boxpost, box_sizes = "all")

## -----------------------------------------------------------------------------
sum(boxpre)/length(boxpre)
sum(boxpost)/length(boxpost)

## ----fig.width=6, out.width="97%", fig.asp=1/2--------------------------------
# plot normalized lacunarity pre- and post-fire
lacnorm_plot(lac_pre, lac_post, group_names = c("Pre-fire", "Post-fire"))

## ----fig.width=6, out.width="97%", fig.asp=1/2--------------------------------
# plot H(r) pre- and post-fire
hr_plot(lac_pre, lac_post,
        group_names = c("Pre-fire","Post-fire"))

