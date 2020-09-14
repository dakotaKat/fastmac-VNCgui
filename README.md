# fastmac-gui

> Get a MacOS desktop over VNC, for free, in around 5 minutes

This repo extends upon fastmac, enabling the built in MacOS VNC server, doing a hacky trick to set a VNC password and a new admin user account, and adds ngrok to your system to set up a tcp tunnel for VNC/Apple Screen Sharing.

Things you'll need to do:

* Clone this repo
* Add these secrets to your cloned repo:
  * `NGROK_AUTH_TOKEN` with your auth key from https://dashboard.ngrok.com/auth
  * `TELEGRAM_TOKEN` for Telegram bot auth (see below)
  * `TELEGRAM_CHAT` for a Telegram user/chat (see below)
* Start the workflow (as described below)

Once the flow is started, you'll get Telegram messages with startup and username/password/host information.

*NOTE* If you're using Apple Screen Sharing or RealVNC Viewer, use the system username and password ("VNC User"/your set password), NOT your VNC-only password!

# Telegram Integration (req'd setup)
This branch, `telegram-notifications`, uses the code from https://github.com/fabianonline/telegram.sh to provide Telegram notifications of script up and hostname/port to connect in.

To set up the bot, you'll need to reach out to @BotFather on Telegram and create a new bot. You'll be given a token string, which must go in a secret called `TELEGRAM_TOKEN`.

Message the bot you've set up at least once to get it 'intialized' for yourself.

Set your user ID in the secret `TELEGRAM_CHAT`. If you add the bot to a channel or group, you can also use the ID of a given channel or group. (Getting your user ID / chat ID is beyond scope of this document.)

It's that easy, you'll get a ping from the bot when the VM is starting and a ping with the VNC user info from ngrok.

----
# Lessons learned in my hacking this to bits:

## We don't know the password to `runner`.
Okay, let's reset the passwor-

    # passwd runner
    Changing password for runner.
    Enter old password:

... right. macOS, at some point, implemented SecureToken-based users. You can't reset the password with `passwd`, it asks for your old password -- even trying to change it from root!

Workaround: Create a new user, `VNC User` aka `vncuser`. We don't *really* need to run as runner, plus, we get the 'out of box' new user setup when we VNC in. Because we're root... we can just straight up add new users. Early iterations of this script I was still learning how to add users and got to see weird behavior when macOS doesn't have a home folder for a user (dumped right to a non-working desktop, for instance).

## macOS Catalina won't let you purportedly configure VNC from the CLI, or at least, set the password anymore...

`Warning: macos 10.14 and later only allows control if Screen Sharing is enabled through System Preferences`

Easy fix: set the password by hand by hashing it into the preferences file. See http://hints.macworld.com/article.php?story=20071103011608872.

## VNC is slow.
Well, this thing isn't exactly GPU accelerated. It's running on an ESXi powered Mac sitting at MacStadium...

----
# fastmac

> Get a MacOS or Linux shell, for free, in around 2 minutes

I don't have a Mac, but I often want to test my software on a Mac, or build software for folks using Macs. Rather than shelling out thousands of dollars to buy a Mac, it turns out we can use GitHub Actions to give us access to one for free! `fastmac` makes this process as simple as possible. Note that this only gives us access to a terminal shell, not a full GUI. See below for how to get started. Here's a little video that shows all the steps (click it for a full-size version):

<a href="https://files.fast.ai/images/fastmac.png"><img src="https://files.fast.ai/images/fastmac-optimize.gif" width="727" /></a>

**NB**: Please check the [GitHub Actions Terms of Service](https://docs.github.com/en/github/site-policy/github-additional-product-terms#5-actions-and-packages). Note that your repo needs to be public, otherwise you have a strict monthly limit on how many minutes you can use. Note also that according to the TOS the repo that contains these files needs to be the same one where you're developing the project that you're using it for, and specifically that you are using it for the "*production, testing, deployment, or publication of [that] software project*".

## Clone template

First, [click here](https://github.com/fastai/fastmac/generate) to create a copy of this repo in your account. Type `fastmac` under "repository name" and then click "Create repository from template". After about 10 seconds, you'll see a screen that looks just like the one you're looking at now, except that it'll be in your repo copy.

**NB**: Follow the  rest of the instructions in repo copy you just made, not in the `fastai/fastmac` repo.

## Run the `mac` workflow

Next, <a href="../../actions?query=workflow%3Amac">click here</a> to go to the GitHub actions screen for the `mac` workflow, and then click the "Run workflow" dropdown on the right, and then click the green "Run workflow" button that appears.

<img width="365" src="https://user-images.githubusercontent.com/346999/92965396-91320680-f42a-11ea-9bc3-90682e740343.png" />

## Access the shell using ssh or browser

After a few seconds, you'll see a spinning orange circle. Click the "mac" hyperlink next to it.

On the next screen, you'll  see another spinning orange circle, this time with "build" next to it. Click "build".

This will show the progress of your Mac that's getting ready for you. After a while, the "Setup tmate session" section will open, and once it's done installing itself, it will repeatedly print lines like this:
```
WebURL: https://tmate.io/t/rXbusP3qkYsfALDSLMQZVwG3d

SSH: ssh rXbusP3qkYsfALDSLMQZVwG3d@sfo2.tmate.io
```

Copy and paste the ssh line (e.g `ssh rXbusP3qkYsfALDSLMQZVwG3d@sfo2.tmate.io` in this case) into your terminal (Windows users: I strongly recommend you use [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) if possible) and press <kbd>Enter</kbd>.

You'll see a welcome message. Press <kbd>q</kbd> to remove it, and you'll be in a Mac shell! The shell already has [brew](https://brew.sh/) installed, so you can easily add any software you need.

Instead of using ssh in your terminal, you can paste the "WebURL" value into your browser, to get a terminal in your browser. Whilst this is adequate if you're in a situation that you can't access a terminal (e.g. you have to do some emergency work on your phone or tablet), it's less reliable than the ssh approach and not everything works.

## Stop your session

Your session will run for up to six hours. When you're finished, you should close it, since otherwise you're taking up a whole computer that someone else could otherwise be using!

To close the session, click the red "Cancel workflow" on the right-hand side of the Actions screen (the one you copied the `ssh` line from).

## Auto-configuration of your sessions

In your `fastmac` repo, edit the `script-{linux,mac}.sh` files to add configuration commands that you want run automatically when you create a new session. These are bash scripts that are run whenever a new session is created.

Furthermore, any files that you add to your repo will be available in your sessions. So you can use this to any any data, scripts, information, etc that you want to have access to in your fastmac/linux sessions.

## Behind the scenes

`fastmac` is a very thin wrapper around [tmate](https://tmate.io/), so all the features of tmate are available. tmate itself is based on [tmux](https://github.com/tmux/tmux/wiki), so you have all that functionality too. In practice, that means other people can connect to the same ssh session, and you'll all be sharing the same screen! This can be very handy for debugging and support. The integration with Github Actions is provided by [action-tmate](https://github.com/mxschmitt/action-tmate).
