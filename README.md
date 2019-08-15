# pm2-offline-installer

> Install pm2 globally offline on Windows or Linux

Do you need to install pm2 on a machine without internet access? You're in the right place.

This project downloads `pm2` on an internet-connected build machine, then expands and installs it globally on a deployment target. It also leverages `pm2-windows-startup` to set pm2 to persist across reboots on Windows.

## Setup

On an internet-connected build machine of the same OS as the deployment target, run the following:

```bash 
$ npm install
$ npm run bundle
```

This will install pm2 globally, and copy the resources required to do so into the project's directory. `pm2-offline-installer` will detect the host operating system and execute the correct script for it's current environment. On Windows, this requires removing all global packages first.

## Deployment

Transfer the entire `pm2-offline-installer` directory to the target deployment machine. Then, execute the following:

```bash
$ npm run setup
```

This will install pm2 globally and set it to persist across reboots.

## Removal

To remove pm2 from the target machine, run 

```bash
$ npm run remove
```

## License

MIT © Jesse Youngblood
