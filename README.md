# 42Setup

## Reset

    # be carefull with that cmd, you will reset all your session
    ./reset_session.sh


## Install

    # shell installer: first arg is source link, second arg is app alias (commonly, app name)
    ./tar-gz-installer.sh "https://vscode.download.prss.microsoft.com/dbazure/download/stable/0870c2a0c7c0564e7631bfed2675573a94ba4455/code-stable-x64-1772587898.tar.gz" "code"

    # python installer
    python3 ./tar-gz-installer.py install "https://vscode.download.prss.microsoft.com/dbazure/download/stable/0870c2a0c7c0564e7631bfed2675573a94ba4455/code-stable-x64-1772587898.tar.gz" "code"

## Uninstall

    # shell uninstaller
    ./tar-gz-uninstaller.sh "code"

    # python uninstaller
    python3 ./tar-gz-installer.py uninstall "code"
