library("ggplot2");

my_theme <- function(legend.labels = waiver(), legend.position="bottom") {

    text_16 = element_text(size = 16)
    text_18 = element_text(size = 18)

    my_theme_base   = theme_gray(base_size = 15) #theme_minimal
    my_theme_color  = scale_color_grey(end = 0.6, labels = legend.labels)
    my_theme_fill   = scale_fill_grey(end = 0.6, labels = legend.labels)
    my_theme_shape  = scale_shape_manual(values = c(15, 16, 17, 18, 12, 10, 9), labels = legend.labels)
    my_theme_size   = scale_size_manual(values = c(2))
    my_theme_tweaks = theme(axis.text = text_16, axis.title = text_18, legend.text = text_16, legend.title = text_18, strip.text = text_18, legend.position = legend.position)

    return(list(my_theme_base, my_theme_color, my_theme_fill, my_theme_shape, my_theme_size, my_theme_tweaks))
}

my_dev <- function(file, width, height, type = "pdf") {

    default_ppi = 72

    width  = width / default_ppi
    height = height / default_ppi
    file   = sprintf("%s/%s.%s", figs_path, file, type)

    if (type == "png") {
        png(file = file, width = width, height = height, units = "in", res = 600)
    }
    else if (type == "pdf") {
        pdf(file = file, width = width, height = height)
    }
    else {
        stop("unsupported type")
    }
}