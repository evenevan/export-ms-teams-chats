# Microsoft Teams Chat Exporter

The repository contains a PowerShell script that allows you to export your Microsoft Teams chat conversations, in HTML format, to your local disk.

![Example of Export HTML file](example-of-export.png=600x)

![Example of Exports in directory](example-of-exports.png=600x)

## Getting Started

### Prerequisites

- An Azure AD app registration needs to be created with User.Read, Chat.Read and User.ReadBasic.All delegated permissions. Follow the steps at https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app and https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-access-web-apis

- You must be running PowerShell 7. See https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7

### Steps

1. Download this repository

1. Create a blank folder where you'll have your chat history exported to

1. Run the Powershell script

   ```PowerShell
   PS> Get-Help ./Get-MicrosoftTeamsChat.ps1
   ...
   PS> ./Get-MicrosoftTeamsChat.ps1 -ExportFolder C:\Users\<you>\OneDrive\ExportChat\ -clientId "0728c136-cc8c-4b29-bbb7-e20c5c35f53a" -tenantId "b2541388-a22b-4b8d-b027-883ad6b445a7" -domain "contoso.com"
   ```

1. Watch the slow crawl magic happen, exporting your chat history.

## Contribute

Feel free to contribute and make this script better! Licensed is MIT

## Ideas

Here are some suggested improvements ideas:

- Script support for PowerShell 5.1 so it can be run by anyone with a Windows 10 machine (without needing to install PSCore)

- The script could be refined to be a bit (a lot) quicker. Lots of foreach loops and not a lot of time spent on possibly making it asynchronous which help it be speedier.

- HTTP 429 retries to manage throttling. See [Microsoft Docs](https://docs.microsoft.com/en-us/graph/throttling).

- The script makes all the images base64 encoded in the HTML files.
  This is okay for 95% of the time but there are potentially some threads out there with big images in them.
  Might make the HTML files quite large!

- Scripts need better commenting for documentation purposes.
