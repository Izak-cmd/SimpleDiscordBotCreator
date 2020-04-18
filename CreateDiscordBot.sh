#!/bin/sh
bold=$(tput bold)
normal=$(tput sgr0)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IsNodePackageManagerInstalled() {
if which npm > /dev/null
    then # 0 = true
    return 0 
  else return 1
  fi
}
IsNodeInstalled() {
if which node > /dev/null
	then return 0 
	else return 1
  fi
}
IsEmptyID() { 
if [[ ! -z $BotID ]] || [[ -z $BotID ]]; then 
return 1 
else 
return 0 
fi 
}
IsEmptyCreator() { 
if [[ ! -z $BotCreator ]] || [[ -z $BotCreator ]]; then 
return 1 
else 
return 0 
fi 
}
IsEmptyDescription() {
if [[ ! -z $BotDescription ]] || [[ -z $BotDescription ]]; then 
return 1 
else 
return 0 
fi 
}
IsEmptyEmail() { 
if [[ ! -z $Email ]] || [[ -z $Email ]]; then 
return 1 
else 
return 0 
fi 
}
IsEmptyLicense() {
if [[ ! -z $License ]] || [[ -z $License ]]; then 
return 1 
else 
return 0 
fi 
}
IsEmptyVersion() {
if [[ ! -z $BotVersion ]] || [[ -z $BotVersion ]]; then 
return 1
else 
return 0 
fi 
}
Acknowledgement(){
echo "The following modules will be installed to the system"
echo "and to ${DIR}/${BotName}:"
echo "${bold}"
echo "Discord.js"
if [[ IsNodePackageManagerInstalled ]]; then {
	echo
	echo "Node Package Manager is already installed." 
	echo "Warning! Node Package Manager will be updated!"
}
else 
echo "Node Package Manager";
fi
if [[ IsNodeInstalled ]]; then {
	echo
        echo "NodeJs is already installed."
	echo "Warning! NodeJs will be updated!"
	}
	else 
	echo "NodeJs v12"
	fi
echo "${normal}"
echo "Do you wish to continue? (Y/N)"
read Answer
	if [[ $Answer = "Y" || $Answer = "y" || $Answer = "" ]]; then {
	InstallModules
	}
	else {
	sudo rm -r "${DIR}/${BotName}"
	echo "Aborted Install!"
	exit 1
	}
fi
}

ConfigCreator(){
	echo "Please follow the instructions to create your Discord Bot & Node Environment"
	echo
	echo "[Required]"
	echo "Enter the new Bot Name:"
	read BotName
	sudo mkdir "${DIR}/${BotName}"
	clear
	cd "${DIR}/${BotName}"
	echo "[Optional]"
	echo "Enter the Creator Name:"
	read BotCreator
	clear
	echo "[Required]"
	echo "Enter Bot Token:"
	read BotToken
	clear
	echo "[Optional] Creates an OAuth2 Link at the end of the installation"
	echo "Enter Bot Client ID:"
	read BotID
	clear
	echo "[Optional]"
	echo "Enter the Version Number:"
	echo "Example: 1.0.1"
	read BotVersion
	clear
	echo "[Optional]"
	echo "Enter the Creator Email:"
	read Email
	clear	
	echo "[Optional]"
	echo "Enter the Bot Description:"
	read BotDescription
	clear
	echo "[Optional]"
	echo "Enter the License Type:"
	echo "Example: MIT or CC0"
	read License
	clear	
	echo "Name: ${BotName}"
if [[ ! IsEmptyLicense ]]; then 
{
	echo "Version: v${BotVersion}"
}
else
	echo "Version: v1.0.0"
fi
	echo "Bot Directory: ${DIR}/${BotName}"
if [[ ! IsEmptyCreator ]]; then 
	{
	echo "Creator: ${BotCreator}"
	}
fi
if [[ ! IsEmptyDescription ]]; then 
	{
	echo "Description:"
	echo "${BotDescription}"
	}
fi
if [[ ! IsEmptyEmail ]]; then 
	{
	echo "Email: ${Email}"
	}
fi
if [[ ! IsEmptyLicense ]]; then 
{
	echo "License: ${License}"
}
fi
echo		
	Acknowledgement
}

InstallModules()
{
echo "Updating"
sudo apt update -y
echo "Installing/Updating NodeJS..."
sudo apt install nodejs -y
echo "Installing/Updating Node Package Manager"
sudo apt install npm -y
echo "Installing/Updating Curl"
sudo apt install curl -y
echo "Downloading latest NodeJS Version"
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
echo "Updating..."
sudo apt update -y
echo "Initializing Node Environment"
	if [[ ! IsEmptyDescription ]]; then
	{
	echo "${BotDescription}" | tee "${DIR}/${BotName}/README.md"
	sudo npm set init.description README.md
	}
	fi
	if [[ ! IsEmptyCreator ]] ; then
	{
	sudo npm set init.author.name $BotCreator
	}
	fi
	if [[ ! IsEmptyEmail ]] ; then
	{
	sudo npm set init.author.email $Email
	}
	fi
	if [[ ! IsEmptyVersion ]] ; then
	{
	sudo npm set init.version $BotVersion
	}
	fi
	if [[ ! IsEmptyLicense ]] ; then
	{
	sudo npm set init.license $License
	}
	fi
	sudo npm set init.author.author $BotName
	sudo npm set init.main "${BotName}.js"
	
	sudo npm init --yes
echo "Installing NPM"
sudo npm install
echo "Installing PM2"
sudo npm install pm2@latest -g
echo "Installing Discord.js"
sudo npm install discord.js -y
WriteBasicDiscordBot
sudo nodejs --version
sudo npm --version
sudo pm2 init
WriteProcessConfig
sudo pm2 start ${BotName}.js
echo ${bold}
clear
sudo pm2 status
echo "Installation Complete!"
echo ${normal}
echo
echo -e 'https://discordapp.com/oauth2/authorize?&client_id='${BotID}'&scope=bot&permissions=10\a

Hold CTRL and click the link above to Invite your bot to your server!\a' 
}
WriteProcessConfig(){
PM='module.exports = {
  apps : [{
    script: "'${BotName}'.js",
    watch: "."
  }, {
    script: "./service-worker/",
    watch: ["./service-worker"]
  }],

  deploy : {
    production : {
      user : "SSH_USERNAME",
      host : "SSH_HOSTMACHINE",
      ref  : "origin/master",
      repo : "GIT_REPOSITORY",
      path : "DESTINATION_PATH",
      "pre-deploy-local": "",
      "post-deploy" : "npm install && pm2 reload ecosystem.config.js --env production",
      "pre-setup": ""
    }
  }
};'
sudo rm ecosystem.config.js
echo "${PM}" | tee "${DIR}/${BotName}/ecosystem.config.js"
}
CheckSudo() {
	if (( $EUID != 0 )); then {
	echo "Simple Discord Bot Creator must be run with sudo!"
	read -s Respose
		if [[ ! -z $Response ]] || [[ -z $Response ]]; then {
		exit 1
		}
		fi
	}
	fi
}
WriteBasicDiscordBot(){
BasicBot='const Discord = require("discord.js");
 const client = new Discord.Client();
 const token = "'${BotToken}'";
 client.on("ready", () => { console.log("A simple Discord Bot has started"); });
 client.login(token);'
echo "${BasicBot}" | tee "${DIR}/${BotName}/${BotName}.js"
}
## Start Script
clear
CheckSudo
	echo "${bold}"
	clear
	echo "Simple Discord Bot Creator"
	echo "${normal}"
	echo
	ConfigCreator
