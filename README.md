
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lacunr

<!-- badges: start -->

[![License: GPL
v3](https://img.shields.io/badge/License-GPL--3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![R-CMD-check](https://github.com/ElliottSmeds/lacunr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ElliottSmeds/lacunr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

`lacunr` is an R package for calculating 3D lacunarity from voxel data.
It is designed to be used with LiDAR point clouds to measure the
heterogeneity or “gappiness” of 3-dimensional structures such as forest
stands. It provides fast C++ functions to efficiently convert point
cloud data to voxels and calculate lacunarity using different variants
of Allain & Cloitre’s well-known gliding-box algorithm.

## Installation

You can install `lacunr` from CRAN with:

``` r
install.packages("lacunr")
```

Or you can install the development version of `lacunr` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ElliottSmeds/lacunr")
```

## Basic Usage

The standard workflow for `lacunr` is fairly simple:

1.  Convert point cloud data to voxels using `voxelize()`
2.  Arrange the voxels into a 3-dimensional binary map using
    `bounding_box()`
3.  Calculate a lacunarity curve using `lacunarity()`

``` r
library(lacunr)
# create a data.frame of simulated point cloud data
pc <- data.frame(X = rnorm(1000, 10), Y = rnorm(1000, 50), Z = rnorm(1000, 25))
# convert to voxels of size 0.5
vox <- voxelize(pc, edge_length = c(0.5, 0.5, 0.5))
# generate binary map
box <- bounding_box(vox)
# calculate lacunarity curve
lac_curve <- lacunarity(box)
```

## Interfacing with `lidR`

The [`lidr` package](https://github.com/r-lidar/lidR) offers a robust
suite of tools for processing LiDAR data. While `lacunr` does not
require `lidR` as a dependency, it is assumed that most users will be
working with point cloud data imported using `lidR`, and the package is
designed to mesh well with `lidR`’s data objects. The following tips
will help make combining these packages as seamless as possible.

### Working with `LAS` objects

Users should take special care when using a `lidR` `LAS` object as input
for the `voxelize()` function. Since `LAS` is an S4 class, it is
important to extract the point cloud data from the `LAS` object using
`@data`, otherwise `voxelize()` will throw an error:

``` r
library(lidR)
# read in LAS point cloud file
las <- readLAS("<file.las>")
# voxelize the LAS point cloud, taking care to input the correct S4 slot
vox <- voxelize(las@data, edge_length = c(0.5, 0.5, 0.5))
```

### Voxelization using `lidR`

`lidR` offers its own extremely versatile voxelization function,
[`voxel_metrics()`](https://r-lidar.github.io/lidRbook/vba.html). This
provides a useful alternative to `voxelize()`, although it is important
to note that both functions utilize different algorithms and will not
produce identical results (see the following section for more details).

`voxel_metrics()` returns a `lasmetrics3d` object. `lacunr`’s
`bounding_box()` function can accept this as an input, but it also
requires that it contain a column named `N`, recording the number of
points in each voxel. This column can be generated by `voxel_metrics()`
using the following:

``` r
# read in LAS point cloud file
las <- readLAS("<file.las>")
# voxelize at 1m resolution, creating a column N containing the number of points
vox <- voxel_metrics(las, ~list(N = length(Z)), res = 1)
# convert to array
box <- bounding_box(vox)
```

### Details on `voxelize()` vs `lidR::voxel_metrics()`

`voxelize()` is adapted from the function `voxels()`, originally written
by J. Antonio Guzmán Q. for the package
[`rTLS`](https://github.com/Antguz/rTLS). It is intended as a complement
rather than a replacement for `lidR`’s more elaborate `voxel_metrics()`.
Each function has a different underlying algorithm and will produce
distinct results from the same input data. The chief advantages of
`voxelize()` over `voxel_metrics()` are:

1.  It allows – and in fact requires – the user to specify all three
    dimensions of the desired voxel resolution independently. This makes
    it possible to completely customize the shape of the voxels, in the
    rare instance that one wishes to divide up a point cloud into a
    non-cubic voxel grid. `voxel_metrics()` permits at most two
    dimensions.
2.  The point cloud can be divided into an even number of voxel bins.
    For example, if you have a point cloud that spans 12 meters in the X
    dimension, and voxelize it at a resolution of 1 meter, the resulting
    data will be binned into 12 1-meter voxels along the X axis. The
    same point cloud will be binned into 13 voxels by `voxel_metrics()`.
    This is due to differences in how each function aligns the point
    cloud data within the voxel grid.