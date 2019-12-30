library("ggplot2");

update_geom_defaults("point" , list(size = 7, fill="white", stroke=1.25))
update_geom_defaults("line"  , list(size=1.25))
update_geom_defaults("ribbon", list(alpha=.15))

my_theme <- function(legend.labels = waiver(), legend.position="bottom", legend.direction = NULL, legend.key.width = NULL) {

    text_s = element_text(size = 18)
    text_m = element_text(size = 21)
    text_l = element_text(size = 25)

    my_theme_base   = theme_bw(base_size = 15) #theme_minimal
    my_theme_color  = scale_color_manual(values=c("gray0", "gray40", "gray60", "gray75", "gray100"), labels = legend.labels)
    my_theme_fill   = scale_fill_grey(end = 0.6, labels = legend.labels)
    my_theme_shape  = scale_shape_manual(values = c(21, 22, 24, 23, 25), labels = legend.labels)
    my_theme_line   = scale_linetype_manual(values = c("solid", "dashed", "dotted"), labels = legend.labels)
    my_theme_tweaks = theme(plot.title=text_l, legend.title = text_l, axis.title = text_l, legend.text = text_m, axis.text = text_s, legend.position = legend.position, legend.direction = legend.direction, legend.key.width = legend.key.width, strip.text = text_m)
    
    return(list(my_theme_base, my_theme_color, my_theme_shape, my_theme_line, my_theme_tweaks, my_theme_fill))
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