library("ggplot2");

my_theme_base  = theme_minimal()
my_theme_color = scale_color_grey()
my_theme_fill  = scale_fill_grey()
my_theme_shape = scale_shape_manual(values = c(15, 16, 17, 18, 8))

my_theme = list(my_theme_base, my_theme_color, my_theme_fill, my_theme_shape)

my_dev <- function(file, width, height) {
    png(file = sprintf("%s/%s.png", figs_path, file), width = width, height = height)
}