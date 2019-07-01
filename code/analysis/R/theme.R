library("ggplot2");

my_theme <- function() {

    text_16 = element_text(size = 16)
    text_18 = element_text(size = 18)

    my_theme_base   = theme_gray(base_size = 15) #theme_minimal
    my_theme_color  = scale_color_grey()
    my_theme_fill   = scale_fill_grey()
    my_theme_shape  = scale_shape_manual(values = c(15, 16, 17, 18, 8))
    my_theme_tweaks = theme(axis.text = text_16, axis.title = text_18, legend.text = text_16, legend.title = text_18)

    return(list(my_theme_base, my_theme_color, my_theme_fill, my_theme_shape, my_theme_tweaks))
}

my_dev <- function(file, width, height) {

    default_ppi = 72

    width  = width / default_ppi
    height = height / default_ppi
    file   = sprintf("%s/%s.png", figs_path, file)


    png(file = file, width = width, height = height, units = "in", res = 600)
}