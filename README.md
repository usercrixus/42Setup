# 42Setup

## Reset

    # be carefull with that cmd, you will reset all your session
    ./reset_session.sh


## Install

    # install app from tar.gz, first arg is the source link, second arg is the app alias (commonly, the app name)
    ./tar-gz-installer.sh "https://vscode.download.prss.microsoft.com/dbazure/download/stable/0870c2a0c7c0564e7631bfed2675573a94ba4455/code-stable-x64-1772587898.tar.gz" "code"

## Uninstall

    # uninstall an app installed with the tar-gz-installer.sh
    ./tar-gz-uninstaller.sh "code"
