#!/bin/bash
# Calculates and sets the correct DPI settings for the display

# Conversion factor
typeset -r _MM_TO_INCHES=0.0393701

get_res_and_dims_mm() {
        # Echoes the string "${res} ${dims}", where "${res}" and "${dims}" each
        # take the form "<num>x<num>", e.g. "1366x768 256x144" (physical
        # dimensions are in millimeters)

        local num='[0-9]\+'
        read -r -d '' sed_scr <<-SED
                / connected /{s/.* \(${num}x${num}\).* \(${num}\)mm x \(${num}\)mm/\1 \2x\3/p;q}
	SED
        sed -n "$sed_scr" <(xrandr)
        return $?
}

get_dpi() {
        IFS='x ' read -r width_pix height_pix width_mm height_mm < <(get_res_and_dims_mm)
        echo "${width_mm}mm x ${height_mm}mm" "${width_pix} x ${height_pix}" >&2
        bc <<-BC 2>/dev/null
                scale = 2
                define dpi(res, dim) {
                    return res / (dim*${_MM_TO_INCHES})
                }
                avg = 0.5*( \
                    dpi(${width_pix}, ${width_mm}) \
                    + dpi(${height_pix}, ${height_mm}) \
                )
                scale = 0; avg / 1
	BC
        return $?
}

set_xorg_dims() {
        dims_mm="$(get_res_and_dims_mm | cut -f 2 -d ' ')"
        # A disgusting hack taken from linuxreviews.org/HOWTO_set_DPI_in_Xorg
        for idx in 1 2; do
                xrandr --fbmm "${dims_mm}"
        done
        return $?
}

x_server_dpi() {
        # Useful for verifying that the correct DPI setting is being used
        xdpyinfo | grep -B2 resolution
}

main() {
    read -n 1 -sp "Set DPI to $(get_dpi)? " && echo
    if [[ "$REPLY" =~ ^[yY]$ ]]; then
        set_xorg_dims
    fi
        exit $?
}

main "$@"
