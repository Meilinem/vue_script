#!/bin/bash

usage="usage: bash initiate_anam_front.sh [MyProjectName]"
appName=$1

if [ $# -lt 1 ]; then
	echo "Please enter the project name"
	echo $usage
	return
fi

if [ $# -gt 1 ] ; then
	echo "Please enter only one project name, you enter: $#"
	echo $usage
	return
fi

unameOut="$(uname -s)"

case "${unameOut}" in
	Linux)     machine=Linux;;
	Darwin)    machine=Mac;;
	CYGWIN)    machine=Cygwin;;
	MINGW)     machine=MinGw;;
	*)			machine="UNKNOWN:${unameOut}"
esac

echo "Initiate anam front project on $machine machine ..."

update_module() {
	version="$(npm info $1 | grep "latest" | cut -f2 -d " ")"
	new_version=$1"@"$version
	npm install -S $new_version
}

update_all() {
	echo "Updating ..."
	npm update
	update_module "vuetify"
	update_module "axios"
	update_module "i18n"
}

ask_for_update() {
	while true; do
		echo "Install latest versions ? [y/n]:"
		read -u 0 yn
		case $yn in
			[Yy]* )
				update_all
				break;;
			[Nn]* ) break;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

initiate_vuecli_project() {
	echo "Starting to initiate vue-cli project $appName"
	vue create $appName
	if [ -d $PWD/$appName ]; then
		echo "Project directory have been created [$appName]"
		cd $appName
		echo "You have been moved to $PWD/$appName"
		vue add vuetify
		npm install --save axios vue-axios
		vue add i18n
		npm install --save ../anam-library
		ask_for_update
		echo "Project [$appName] successfully initiate with vuetify && vue-axios"
		npm run serve
	else
		echo "Error in project creation"
		return
	fi
}

case "${machine}" in
	Mac)
		if [ $(node -v 2>&-) ]; then
			brew install node
		else
			echo "$(node -v) already installed"
		fi
		if [ $(npm -v 2>&-) ]; then
			echo "$(npm -v) already installed"
		else
			brew install npm
		fi
		if [ $(command -v vue 2>&-) ]; then
			echo "$(vue --version) already installed"
		else
			npm install -g @vue/cli && npm update -g @vue/cli
		fi
		initiate_vuecli_project
		;;
	Linux)
		if [ $(node -v 2>&-) ]; then
			sudo apt-get install nodejs
			echo "$(node -v) already installed - updating ..."
		else
			sudo apt-get install node
		fi
		if [ $(npm -v 2>&-) ]; then
			sudo apt-get install npm
			echo "$(npm -v) already installed - updating ..."
		else
			sudo apt-get install npm
		fi
		if [ $(vue --version 2>&-) ]; then
			echo "$(vue --version) already installed"
		else
			sudo npm install -g @vue/cli && sudo npm update -g @vue/cli
		fi
		initiate_vuecli_project
		;;
esac
