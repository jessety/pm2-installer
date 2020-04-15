# pm2-installer

`pm2-installer` is designed to automate installation of pm2 as a service, particularly on Windows, even in environments without Internet access.

### Windows Support

Setup on Windows is largely based on [this excellent gist](https://gist.github.com/maxfierke/a85ba9d717d6e121405c).

There are a couple issues that make automated deployment of a pm2 service difficult on Windows:

- Unlike on Linux, `pm2` has no built-in startup script support for Windows
- The `npm` directory must be accessible to the Local Service user
- The `pm2_home` folder must be writeable by the Local Service user
- The `PM2_HOME` environmental variable must be set on a machine level

When running on Windows, `pm2-installer` will do the following:

- Configure `npm` to keep it's global files in `C:\ProgramData\npm`, instead of keeping them in the current user's `%APPDATA%`
- Install `pm2` globally (using an offline cache if one is available)
- Create a folder at `C:\ProgramData\pm2` and set the `PM2_HOME` environmental variable to it at the machine level
- Set permissions both the new `npm` and `pm2` folders so that the Local Service user may access them
- Leverage a fork of `pm2-windows-service` to create a pm2 Windows service that will persist across reboots
- Install the `pm2-logrotate` module so that log files don't fill up the disk

After that, `pm2` will be installed as a service. It will persist across reboots and continue running regardless of which user is logged in. To add your app, run `pm2 start app.js` from an admin command line interface. Make sure to run `pm2 save` to serialize the process list.

## Install

Download the latest version [here](https://github.com/jessety/pm2-installer/archive/master.zip).

Copy the entire `pm2-installer` directory onto the target machine, then run:

```bash
npm run setup
```

On Windows, the `setup` script assumes you have already configured `npm` to use `prefix` and `cache` directories in a location accessible to the `LocalService` user. To do this automatically, run `configure` first:

```bash
npm run configure
npm run setup
```

That's it.

## Offline Install

`pm2-installer` is also designed to function without an internet connection. It does this by installing `pm2` on an internet-connected build machine to create a cache, then installing from cache when run on the deployment machine.

On an internet-connected build machine of the same OS as the deployment target, run the following:

```bash
npm run bundle
```

This will install pm2 locally, and save the resources required to do so into the project's directory. Transfer the entire `pm2-installer` directory onto the deployment target, then run:

```bash
npm run setup
```

`pm2-installer` will automatically detect the resources required to install without an internet connection and use them. Otherwise, it will attempt to download them from the npm registry.

## Removal

To remove the pm2 service, run:

```bash
npm run remove
```

This will remove the service and completely uninstall pm2.

If you used the `configure` script on Windows to configure `npm`, you can revert those settings by running:

```bash
npm run deconfigure
```

## License

MIT © Jesse Youngblood
