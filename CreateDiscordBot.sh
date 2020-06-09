#!/bin/sh
#Declare distinguishable features
bold=$(tput bold)
normal=$(tput sgr0)
#Delcare Input Strings Required
PROCESS=""
INPUT=""
TOKENINPUT=""
STRINGINPUT=""
#Directory is equal to the directory of the bash script
#Which should be /home/username/.Create.sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#Start Functions
CheckSudo() {
#sudo is root, root is EUID 0, if not 0 then not sudo
	if (( $EUID != 0 )); then {
#Show the Warning
	clear
	echo -e "${bold}Simple Discord Bot Creator must be run with sudo!${normal}\n"
	echo "Press enter to quit.."
#Get Response and don't show the input as indicated by -s
	read -s Response
#If there is or isn't any input, exit
		if [[ ! -z $Response ]] || [[ -z $Response ]]; then {
		exit 1
		}
		fi
	}
	fi
}
MainOptions() {
#Make Title Bold to make distinguishable
	clear
#-e to allow backslash and backslash interpreter
	echo -e "${bold}Simple Discord Bot Creator ${normal}\n"
#Start by presenting numerical options
	echo -e "1: Create Discord.js v12 Bot\n2: Create Node Application\n3: Install Node.js v12.18.0 and NPM v6.14.4\n\nFor information on the option, put ? before"
#Choice is the Input
	read Choice
#foreach choice, give a different function
	if [[ $Choice == "1" ]]; then {
	clear
	echo -e "${bold}Discord.js Bot Creator ${normal}\n"
	BotNameInput
	}
	elif [[ $Choice == "2" ]]; then {
	clear
	echo -e "${bold}Node Application Creator ${normal}\n"
	NodeNameInput
	}
	elif [[ $Choice == "3" ]]; then {
	clear
	echo -e "${bold}Node.js v12.18.0 Installation ${normal}\n"
	Installation
	clear
	echo -e "${bold}Node.js v12.18.0 Installed and Node Package Manager v6.14.4 Installed ${normal}\n"
	}
	fi
}
NpmProcess() {
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

}
PmProcess() {
	echo "Installing PM2"
	sudo npm install pm2@latest -g
	sudo npm install express
	sudo pm2 init
	WriteProcessConfig
	sudo pm2 start ${BotName}.js
	echo ${bold}
	sudo pm2 save
	clear
	sudo pm2 status
	echo -e "Installation Complete!\nType 'sudo pm2 logs "${BotName}"' to see the result!"
}
DiscordProcess() {
	echo "Installing Discord.js"
	sudo npm install discord.js -y
	WriteBasicDiscordBot
	PmProcess
	EmptyID
}
DiscordInputCheck() { 
while [[ $BotName = '' ]]
do
    	echo -e "The Bot Name cannot be Empty!\nAborting!"
	return;
done
clear
	sudo mkdir "${DIR}/${BotName}"
	clear
	cd "${DIR}/${BotName}"
TokenInput
}
# A Basic Javascript Discord Bot
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
    let reason = args.slice(1).join(" ");
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
    let reason = args.slice(1).join(" ");
    if(!reason) reason = "No reason provided";
    await member.ban(reason).catch(error => message.reply("I failed to ban the user. Error: "+error));
    message.reply(member.user.tag + " has been banned by " + message.author.tag);
}
//End Commands
});

client.login(token);'
echo "${BasicBot}" | tee "${DIR}/${BotName}/${BotName}.js"
}
# A Basic Javascript Express Bot
WriteBasicNodeBot(){
BasicBot='const express = require("express")
const app = express()
const port = 3000
app.get("/", (req, res) => res.send("Hello World!"))
app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`))'
echo "${BasicBot}" | tee "${DIR}/${BotName}/${BotName}.js"
}
NodeInputCheck() { 
while [[ $BotName = '' ]]
do
    	echo -e "The Bot Name cannot be Empty!\nAborting!"
	return;
done
clear
	
	sudo mkdir "${DIR}/${BotName}"
	clear
	cd "${DIR}/${BotName}"
NodeConfigCreator
}
TokenCheck() { 
while [[ $BotToken = '' ]]
do
   	echo -e "The Bot Name cannot be Empty!\nAborting!"
sudo rm -r "${DIR}/${BotName}"
	return;
done
clear
DiscordConfigCreator
}
DiscordAcknowledgement(){
echo "${normal}Do you wish to continue? (Y/N)"
read Answer
	if [[ $Answer = "Y" || $Answer = "y" || $Answer = "" ]]; then {
	
	DiscordProcess
	
	}
	else {
	sudo rm -r "${DIR}/${BotName}"
	echo "Aborted Install!"
	exit 1
	}
fi
}
NodeAcknowledgement(){
echo -e "The following modules will be installed to the system\n${normal}Do you wish to continue? (Y/N)"
read Answer
	if [[ $Answer = "Y" || $Answer = "y" || $Answer = "" ]]; then {
	
	WriteBasicNodeBot
	NpmProcess
	PmProcess
	}
	else {
	sudo rm -r "${DIR}/${BotName}"
	echo "Aborted Install!"
	exit 1
	}
fi
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
echo -e 'https://discordapp.com/oauth2/authorize?&client_id='${BotID}'&scope=bot&permissions=8\a

Hold CTRL and click the link above to Invite your bot to your server!\a' 
}

BotNameInput(){
echo -e "Please follow the instructions to create your Discord Bot & Node Environment\n\n [Required]"
	read -p "Enter a new Bot Name: " BotName
	set INPUT = "${BotName}"
	DiscordInputCheck
}
NodeNameInput(){
echo -e "Please follow the instructions to create your Node Environment\n\n[Required]"
	read -p "Enter a new Bot Name: " BotName
	set INPUT = "${BotName}"
	NodeInputCheck
}
TokenInput(){
	echo "[Required]"
	read -p "Enter the Bot Token: " BotToken
	set TOKENINPUT = "${BotToken}"
	TokenCheck
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

DiscordConfigCreator(){
	echo -e "[Optional]\nEnter the Creator Name:"
	read BotCreator
	clear
	echo -e "[Optional]\nCreates an OAuth2 Link at the end of the installation\Enter Bot Client ID:"
	read BotID
	clear
	echo -e "[Optional]\nEnter the Version Number:\nExample: 1.0.1"
	read BotVersion
	clear
	echo -e "[Optional]\nEnter the Creator Email:"
	read Email
	clear	
	echo "Enter the Bot Description:"
	read BotDescription
	clear
	echo -e "[Optional]\nEnter the License Type:\nExample: MIT or CC0"
	read License
	clear	
	echo -e "Name: ${BotName}\nVersion: v${BotVersion}\nBot Directory: ${DIR}/${BotName}\nCreator: ${BotCreator}\nDescription:\n${BotDescription}\nEmail: ${Email}\nLicense: ${License}\n"	
	DiscordAcknowledgement
}
NodeConfigCreator(){

	echo -e "[Optional]\nEnter the Creator Name:"
	read BotCreator
	clear
	echo -e "[Optional]\nEnter the Version Number:\nExample: 1.0.1"
	read BotVersion
	clear
	echo -e "[Optional]\nEnter the Creator Email:"
	read Email
	clear	
	echo -e "[Optional]\nEnter the Bot Description:"
	read BotDescription
	clear
	echo -e "[Optional]\nEnter the License Type:\nExample: MIT or CC0"
	read License
	clear	
	echo -e "Name: ${BotName}\nVersion: v${BotVersion}\nBot Directory: ${DIR}/${BotName}\nCreator: ${BotCreator}\nDescription:\n${BotDescription}\nEmail: ${Email}\nLicense: ${License}\n"	
	NodeAcknowledgement
}
function Installation() {
sudo apt update -y
sudo apt install nodejs -y
sudo apt install npm -y
sudo apt install curl -y
curl -sL https://deb.nodesource.com/setup_12.x | sudo bash - 
sudo apt update -y
sudo apt-get install nodejs -y
sudo apt update -y
}
#End Functions
#Start Script
#Check if run with Sudo
	CheckSudo
#Present Options and interpret the response
	MainOptions

