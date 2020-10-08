#!/bin/bash

available=( "vuetify" "axios" "i18n" );

check_module() {
	tmp=();
	does_exist=0;

	for module in "${available[@]}"
	do
		if [ "$module" == $1 ]
		then
			does_exist=1;
		fi
	done

	if [ $does_exist -eq 1 ]
	then
		modules+=$1
	else
		echo "Module not found : $1"
		echo "Modules available for update :"
		for print_module in "${available[@]}"
		do
			echo "- " $print_module
		done
	fi
}

update() {
	npm update $1
	version="$(npm info $1 | grep "latest" | cut -f2 -d " ")"
	new_version=$1"@"$version
	npm install -S $new_version
}

ask_for_update() {
	for module in "${modules[@]}"
	do
		read -p "Update module: $module ? [y/n]" yn
		case $yn in
			[Yy]* ) update $module;;
			[Nn]* ) echo "Well ...";;
			* ) echo "Pls enter [Yy] or [Nn]";;
		esac
	done
}

if [ $1 == "--help" ] || [ $1 == "-h" ]
then
	echo "usage: bash update_modules.sh [modules]"
	echo "Modules available:"
	echo "- No arg will update all modules"
	for module in "${available[@]}"
	do
		echo "- " $module
	done
	exit
fi

if [ $# -gt 0 ]
then
	for i in "$@"
	do
		check_module $i
		if [ ${#modules[@]} -eq 0 ]
		then
			echo "No module available for update"
		else
			for module in "${modules[@]}"
			do
				update $module
			done
		fi
	done
else
	modules=("${available[@]}")
	ask_for_update
fi
