# Simple Discord Bot Creator

A Shell Script designed to bring your Discord Bot online within seconds!

## Getting Started

Simply place the CreateDiscordBot.sh where you wish to initialize your Bot.
i.e. /home/username/Desktop
You do not need to create a folder.

### Prerequisites

```
Discord.js
NodeJs v12.6.2
NPM v6.14.4
PM2 v4.3.0
```

A clean virtual private server is best. 
If you have previously installed any of the above modules of a lower version, they may be updated.

### Installing

Simply run the CreateDiscordBot.sh script using ```sudo bash CreateDiscordBot.sh```

The Script will ask your for your Bot's name, this will be the folder name that is created.
The Script will also ask you for a Bot Token and Client ID.
Fields are marked with the [Optional] or [Required] tag.

The Script will continue to install NodeJs, NPM, PM2 and Discord.js.
Upon Completion, if you have provided a Client ID, the Script will provide an OAuth Invite.
The Script will also put the Bot online after installation.

## Authors

* **Isaac Goodrick** - *Initial work* - [Izak](https://github.com/Izak-cmd)

## License

This project is licensed under the CC0 License and is free for distribution, modification and use in commercial applications - see the [LICENSE.md](LICENSE.md) file for details.
