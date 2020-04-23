#!/bin/sh
bold=$(tput bold)
normal=$(tput sgr0)
PROCESS = ""
INPUT = ""
TOKENINPUT = ""
STRINGINPUT = ""
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
IsEmptyProcess(){
if which $PROCESS > /dev/null
    then # 0 = true
    return 0 
  else return 1
  fi
}
InputCheck() { 
while [[ $BotName = '' ]]
do
    echo "The Bot Name cannot be Empty!"
	echo "Aborting!"
	return;
done
clear
	sudo mkdir "${DIR}/${BotName}"
	clear
	cd "${DIR}/${BotName}"
TokenInput
}
TokenCheck() { 
while [[ $BotToken = '' ]]
do
    echo "The Bot Token cannot be Empty!"
	echo "Aborting!"
sudo rm -r "${DIR}/${BotName}"
	return;
done
clear
ConfigCreator
}
StringCheck(){
while [[ $STRINGINPUT = '' ]]
do
    #If the String is Empty, Continue
	continue;
done
}
EmptyID(){
while [[ $BotID = '' ]]
do
    echo "Client ID has not been provided, so no OAuth link has been provided."
	return;
done
echo -e 'https://discordapp.com/oauth2/authorize?&client_id='${BotID}'&scope=bot&permissions=10\a

Hold CTRL and click the link above to Invite your bot to your server!\a' 
}

Acknowledgement(){
echo "The following modules will be installed to the system"
echo "and to ${DIR}/${BotName}:"
echo "${bold}"
echo "Discord.js"
echo "PM2"
echo "Curl"
set PROCESS = "npm"
if [[ IsEmptyProcess ]]; then {
	echo
	echo "Node Package Manager is already installed." 
	echo "Warning! Node Package Manager will be updated!"
}
else 
echo "Node Package Manager";
fi
set PROCESS = "node"
if [[ IsEmptyProcess ]]; then {
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
BotNameInput(){
echo "Please follow the instructions to create your Discord Bot & Node Environment"
	echo
	echo "[Required]"
	read -p "Enter a new Bot Name: " BotName
	set INPUT = "${BotName}"
	InputCheck
}
TokenInput(){
	echo "[Required]"
	read -p "Enter the Bot Token: " BotToken
	set TOKENINPUT = "${BotToken}"
	TokenCheck
}
ConfigCreator(){
	echo "[Optional]"
	echo "Enter the Creator Name:"
	read BotCreator
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
	echo "Version: v${BotVersion}"
	echo "Bot Directory: ${DIR}/${BotName}"
	echo "Creator: ${BotCreator}"
	echo "Description:"
	echo "${BotDescription}"
	echo "Email: ${Email}"
	echo "License: ${License}"
	echo		
	Acknowledgement
}
InstallModules() {
sudo apt update -y
sudo apt install nodejs -y
sudo apt install npm -y
sudo apt install curl -y
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
sudo apt update -y
	echo "Initializing Node Environment"
	set STRINGINPUT = "${BotDescription}"
	if [[ StringCheck ]]; then {
	echo "${BotDescription}" | tee "${DIR}/${BotName}/README.md"
	sudo npm set init.description README.md
	}
	fi
	sudo npm set init.author.name $BotCreator
	sudo npm set init.author.email $Email
	sudo npm set init.version $BotVersion
	sudo npm set init.license $License
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
	sudo pm2 init
	WriteProcessConfig
	sudo pm2 start ${BotName}.js
	echo ${bold}
	clear
	sudo pm2 status
	echo "Installation Complete!${normal}"
	echo
	EmptyID
}
WriteProcessConfig(){
PM='module.exports = {
  apps : [{
    script: "'${BotName}'.js",
    watch: "."
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
 const prefix = ">";
 client.on("ready", () => { console.log("A simple Discord Bot has started"); });
 client.on("message", async message => { 
if(message.author.bot) return; //Makes bot ignore itself to avoid a a spam loop
if(message.content.indexOf(prefix) !== 0) return; // Ignore if does not contain prefix (>)
 const args = message.content.slice(prefix.length).trim().split(/ +/g);
 const command = args.shift().toLowerCase();
// Discord.js v12 Roles (note cache)
 var admin = message.member.roles.cache.some(r => r.name === "Administrator");
//Simple Command
 if(command === "ping") { message.channel.send("pong"); }
//Kick Command
if(command === "kick") { 
 if(!admin) // If Not Admin Return and return with a message
      return message.reply("You dont have permissions to do this!");
    let member = message.mentions.members.first() || message.guild.members.get(args[0]);
    if(!member)
      return message.reply("Please mention a valid member of this server");
    if(!member.kickable) 
      return message.reply("I cannot kick this user! Do they have a higher role?");
    let reason = args.slice(1).join(' ');
    if(!reason) reason = "No reason provided";
    await member.kick(reason).catch(error => message.reply("I failed to kick the user. Error: "+error));
     message.reply(member.user.tag + " has been kicked by " + message.author.tag);
}
//Ban Command
if(command === "ban") {
 if(!admin)
      return message.reply("You dont have permissions to do this!");
   let member = message.mentions.members.first();
    if(!member)
      return message.reply("Please mention a valid member of the server");
    if(!member.bannable) 
      return message.reply("I cannot ban this user! Do they have a higher role?");
    let reason = args.slice(1).join(' ');
    if(!reason) reason = "No reason provided";
    await member.ban(reason).catch(error => message.reply("I failed to ban the user. Error: "+error));
    message.reply(member.user.tag + " has been banned by " + message.author.tag);
}
//End Commands
});

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
	BotNameInput
