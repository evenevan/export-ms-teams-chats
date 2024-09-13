# Microsoft Teams Chat Exporter

![Example of Exported Chat](example.png)

## Introduction

I want to export my Microsoft Teams messages. Despite being both a dominant product in the market segment and run by a trillion dollar company, Teams doesn't have a native way for end users to export messages for work or school accounts.

The repository contains a PowerShell script that allows you to export your Microsoft Teams chat conversations, in HTML format, to your local disk.

## Important

If you are using Microsoft Teams with a personal Microsoft account, you can simply export your chats and other data with https://go.microsoft.com/fwlink/?linkid=2128346. This guide is for people using Microsoft Teams with work or school accounts.

## Advantages

Compared to other repos or methods that strive to achieve the same goal, [this method](#credit) is better in some respects:

- It is not necessary to create an application with Azure Active Directory.
- You (usually) do not need to have admin permissions in your organization to use this tool.
- It works! Some other implementations are outdated and do not work properly. This method works as of 25/7/2023 (d/m/y).
- Not too difficult. The hardest part is (hopefully) typing/copying one line into a PowerShell terminal and having the patience to wait.

## Guide

This process will probably take you about **30s** on a Windows system to get running or about **5m** on MacOS or Linux and roughly **20m** of unattended time to export 60 chats.

### 1. Install PowerShell 7

#### Windows

You should be able to skip this step! Continue to step 2.

#### MacOS

See [Microsoft&#39;s guide on installing PowerShell on MacOS](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos).

#### Linux

See [Microsoft&#39;s guide on installing PowerShell on Linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux).

### 2. Run the Script

Open a PowerShell terminal. Type or copy the following into the terminal and hit enter.

```
irm https://raw.githubusercontent.com/evenevan/export-ms-teams-chats/main/ps.ps1 | iex
```

<details>
  <summary>Legacy/Alternate Method</summary>

  **Only use this method if the above doesn't work for you. This is almost certainly more difficult.**

  [Download my code](https://github.com/evenevan/export-ms-teams-chats/archive/refs/heads/main.zip). Then, extract the downloaded folder to wherever is convenient to you.

#### [Easier] Windows - Through File Explorer

1. Find the `Get-MicrosoftTeamsChat.ps1` file in File Explorer and right click it.
2. Click `Run with PowerShell`.
   - If you get a security warning when clicking run, press open to continue. For doubts of the code's intentions, you can verify the code yourself since it is open source.
   - You may need to run `Set-ExecutionPolicy RemoteSigned` to allow the script to run.
   - You may be prompted to confirm if you want to change the execution policy to continue.

#### [Harder] All OSs - Through the terminal

1. Open PowerShell.
2. In the terminal, navigate to the folder with the `Get-MicrosoftTeamsChat.ps1` file.
3. Run `./Get-MicrosoftTeamsChat.ps1`.

</details>

### 3. Authenticate

The script will ask you to authenticate an app named PnP Management Shell. Follow the instructions given. Sign in with your work/school email. If copying the device code, be careful as Ctrl + C is the same shortcut that halts the terminal; only press Ctrl + C once to copy.

If you run into issues with authentication, specifically with permissions requiring admin consent, there is not much I can do.

### 4. Wait

A few seconds after you finish authenticating, you should start seeing activity in the PowerShell terminal. Now, your chats will be fetched, processed, and exported. This may take a while. For me, it takes about 20 minutes for about 60 chats. As the script goes through the conversations, HTML files will start to appear in the output folder. Once done, put the contents of the output folder in a safe spot.

### 5. View

To view the exported chats, open the HTML files with your favorite browser.

Hopefully that is it! If you run into any issues, please let me know.

## Notes

### General

- The output is less than perfect. Some things, like system messages, are less than ideal. Polls, location, and other widgets don't appear.
- My fork of olljanat's code heavily improves the quality of the output with attachments fixed, multi image handling fixed, image sizing improved, group chat names improved, system messages visible, performance improvements, message urgency, edit indicators, dark mode, Windows PowerShell (version < 6.0) compatibility, easier execution, and more.

### Debugging

- I have not tested this on MacOS.
- If the script seems to be stuck and not doing anything, wait a few minutes. Make sure you didn't accidentally end the script by pressing Ctrl + C too many times. If it still isn't doing anything, you can kill the script and try again. You can also try running the script with verbose mode enabled (see below).
- If you are having trouble, you can enable verbose output by using one of the following.
  - Run `irm https://raw.githubusercontent.com/evenevan/export-ms-teams-chats/main/ps-verbose.ps1 | iex` in a PowerShell terminal.
  - Run `./Get-MicrosoftTeamsChat.ps1 -Verbose` in a PowerShell terminal in the directory with the `Get-MicrosoftTeamsChat.ps1` file.
- If you are running into odd issues on a Windows based system, you can try using PowerShell 7. Note that PowerShell 7 is different than Windows PowerShell, where the latter is probably preinstalled with your system. See [Microsoft&#39;s guide on installing PowerShell on Windows](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows) for PowerShell 7 install instructions.

## Credit

This repo is based on my improvements to the codebase of a pull request by [olljanat](https://github.com/olljanat) (https://github.com/olljanat/MSTeamsChatExporter) on a repository by [telstrapurple](https://github.com/telstrapurple) (https://github.com/telstrapurple/MSTeamsChatExporter).

## Disclaimer

I don't know what I'm doing. All I know is that this works (hopefully). There may be serious vulnerabilities or issues with the methods discussed. Under the MIT license, this comes with no warranty. Please don't sue me.
