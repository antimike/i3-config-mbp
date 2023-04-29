#!/bin/bash

me="$(realpath "${BASH_SOURCE[0]}")"
i3dir="$(dirname "$me")"

# Link config files in i3 directory, creating backups if destination already exists
while read source target; do
	mkdir -p "$(dirname "$HOME/$target")"
	source_path="${i3dir}/dotfiles/${source}"
	target_path="${HOME}/${target}"
	if [[ -d "$source_path" ]]; then
		stow . --dir="$source_path" --target="$target_path"
	elif [[ -f "$source_path" ]]; then
		ln -nsfb --suffix=".backup" "$source_path" "$target_path"
	else
		echo "Warning: source ${source_path} does not seem to exist"
	fi
done <<EOF
Xresources   .Xresources
gtkrc-2.0    .gtkrc-2.0
gtk3.css     .config/gtk-3.0/gtk.css
qt5ct.conf   .config/qt5ct/qt5ct.conf
systemd      .config/systemd/user
EOF

# Not sure why the following line would be useful...
# rm -f "$HOME/.config/gtk-3.0/settings.ini"
