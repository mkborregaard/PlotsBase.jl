function add_backend(pkg::Symbol)
    info("To do a standard install of $pkg, copy and run this:\n\n")
    println(add_backend_string(_backend_instance(pkg)))
    println()
end
add_backend_string(b::AbstractBackend) = warn("No custom install defined for $(backend_name(b))")

# don't do anything as a default
_create_backend_figure(plt::Plot) = nothing
_prepare_plot_object(plt::Plot) = nothing
_initialize_subplot(plt::Plot, sp::Subplot) = nothing

_series_added(plt::Plot, series::Series) = nothing
_series_updated(plt::Plot, series::Series) = nothing

_before_layout_calcs(plt::Plot) = nothing

title_padding(sp::Subplot) = sp[:title] == "" ? 0mm : sp[:titlefont].pointsize * pt
guide_padding(axis::Axis) = axis[:guide] == "" ? 0mm : axis[:guidefont].pointsize * pt

"Returns the (width,height) of a text label."
function text_size(lablen::Int, sz::Number, rot::Number = 0)
    # we need to compute the size of the ticks generically
    # this means computing the bounding box and then getting the width/height
    # note:
    ptsz = sz * pt
    width = 0.8lablen * ptsz

    # now compute the generalized "height" after rotation as the "opposite+adjacent" of 2 triangles
    height = abs(sind(rot)) * width + abs(cosd(rot)) * ptsz
    width = abs(sind(rot+90)) * width + abs(cosd(rot+90)) * ptsz
    width, height
end
text_size(lab::AbstractString, sz::Number, rot::Number = 0) = text_size(length(lab), sz, rot)

# account for the size/length/rotation of tick labels
function tick_padding(axis::Axis)
    ticks = get_ticks(axis)
    if ticks == nothing
        0mm
    else
        vals, labs = ticks
        isempty(labs) && return 0mm
        # ptsz = axis[:tickfont].pointsize * pt
        longest_label = maximum(length(lab) for lab in labs)

        # generalize by "rotating" y labels
        rot = axis[:rotation] + (axis[:letter] == :y ? 90 : 0)

        # # we need to compute the size of the ticks generically
        # # this means computing the bounding box and then getting the width/height
        # labelwidth = 0.8longest_label * ptsz
        #
        #
        # # now compute the generalized "height" after rotation as the "opposite+adjacent" of 2 triangles
        # hgt = abs(sind(rot)) * labelwidth + abs(cosd(rot)) * ptsz + 1mm
        # hgt

        # get the height of the rotated label
        text_size(longest_label, axis[:tickfont].pointsize, rot)[2]
    end
end

# Set the (left, top, right, bottom) minimum padding around the plot area
# to fit ticks, tick labels, guides, colorbars, etc.
function _update_min_padding!(sp::Subplot)
    # TODO: something different when `is3d(sp) == true`
    leftpad   = tick_padding(sp[:yaxis]) + sp[:left_margin]   + guide_padding(sp[:yaxis])
    toppad    = sp[:top_margin]    + title_padding(sp)
    rightpad  = sp[:right_margin]
    bottompad = tick_padding(sp[:xaxis]) + sp[:bottom_margin] + guide_padding(sp[:xaxis])

    # switch them?
    if sp[:xaxis][:mirror]
        bottompad, toppad = toppad, bottompad
    end
    if sp[:yaxis][:mirror]
        leftpad, rightpad = rightpad, leftpad
    end

    # @show (leftpad, toppad, rightpad, bottompad)
    sp.minpad = (leftpad, toppad, rightpad, bottompad)
end

_update_plot_object(plt::Plot) = nothing

# ---------------------------------------------------------