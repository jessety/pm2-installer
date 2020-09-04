# pm2-installer

`pm2-installer` is designed to automate installation of pm2 as a service, particularly on Windows, even in environments without Internet access.

### Windows Support

Unfortunately, PM2 has no built-in startup support for Windows. PM2's [documentation](https://pm2.keymetrics.io/docs/usage/startup/#windows-consideration) recommends using either `pm2-windows-service` or `pm2-windows-startup`. However, both of these projects have some real drawbacks.

`pm2-windows-startup` adds an entry to the registry to start pm2 after user login. Because it does not create a service, PM2 will not be running until a user has logged into the user interface, and will halt when they log out. It has not been updated since 2015.

`pm2-windows-service` uses `node-windows` to create a service that runs pm2. This is a much better approach, but it hasn't been maintained since 2018, has outdated dependencies that cause crashes on setup, and currently fails to run properly on Node 14. It also runs the service as the the `Local System` user instead of `Local Service`.

This project creates its own Windows Service using the current version of `node-windows` and a series of PowerShell scripts inspired by [this excellent gist](https://gist.github.com/mauron85/e55b3b9d722f91366c50fddf2fca07a4) by [@maxfierke](https://github.com/maxfierke) & [@mauron85](https://github.com/mauron85).

When running on Windows, `pm2-installer` will:

- Configure `npm` to keep its global files in `C:\ProgramData\npm`, instead of keeping them in the current user's `%APPDATA%`
- Install `pm2` globally, using an offline cache if necessary
- Create the `C:\ProgramData\pm2` directory and set the `PM2_HOME` environmental variable at the machine level
- Set permissions both the new `npm` and `pm2` folders so that the Local Service user may access them
- Leverage `node-windows` to install a new Windows service
- Use PowerShell to configure the service to run as the Local Service user (due to [node-windows#89](https://github.com/coreybutler/node-windows/issues/89))
- Confirm the service is running properly
- Install the `pm2-logrotate` module so that log files don't fill up the disk

After that, `pm2` will be running in the background the `Local Service` user. It will persist across reboots and continue running regardless of which user is logged in. To add your app, run `pm2 start app.js` from an admin command line interface. Make sure to run `pm2 save` to serialize the process list.

## Install

Download the latest version [here](https://github.com/jessety/pm2-installer/archive/main.zip).

Copy the entire `pm2-installer` directory onto the target machine, then run:

```bash
npm run setup
```

On Windows, the `setup` script assumes you have already configured `npm` to use `prefix` and `cache` directories in a location accessible to the `Local Service` user. If not, it will issue a warning and ask if you're sure you'd like to proceed.
To set up `npm` automatically, run `configure` first:

```bash
npm run configure
npm run setup
```

That's it.

## Offline Install

`pm2-installer` is also designed to function without an internet connection. It does this by creating a cache on an internet-connected build machine, then installing from that cache when run on the offline deployment machine.

On an internet-connected build machine running the same OS as the deployment target, run the following:

```bash
npm run bundle
```

This will populate the cache in the project's directory with the resources required to install offline. Transfer the entire `pm2-installer` directory onto the deployment target, then run:

```bash
npm run setup
```

`pm2-installer` will check if it can contact the npm registry and install online if possible, or use the offline cache if not.

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
