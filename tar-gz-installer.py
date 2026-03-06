#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import shutil
import tarfile
from pathlib import Path
from urllib.error import URLError
from urllib.request import urlretrieve


def is_executable_file(path: Path) -> bool:
    return path.is_file() and os.access(path, os.X_OK)


def get_paths(program_name: str) -> tuple[Path, Path, Path, Path, Path]:
    appdir = Path.home() / "App"
    bindir = Path.home() / ".local" / "bin"
    bashrc = Path.home() / ".bashrc"
    archive = appdir / f"{program_name}.tar.gz"
    install_dir = appdir / program_name
    bin_path = bindir / program_name
    return appdir, bindir, bashrc, archive, install_dir, bin_path


def remove_alias_from_bashrc(bashrc: Path, program_name: str) -> None:
    if not bashrc.exists():
        return
    lines = bashrc.read_text(encoding="utf-8").splitlines()
    filtered = [line for line in lines if f"alias {program_name}=" not in line]
    bashrc.write_text("\n".join(filtered) + ("\n" if filtered else ""), encoding="utf-8")


def ensure_local_bin_in_path(bashrc: Path) -> None:
    marker = 'export PATH="$HOME/.local/bin:$PATH"'
    if bashrc.exists() and marker in bashrc.read_text(encoding="utf-8"):
        return
    with bashrc.open("a", encoding="utf-8") as fh:
        fh.write("\n# Add user local bin\n")
        fh.write(f"{marker}\n")


def cleanup_failed_install(install_dir: Path, archive: Path) -> None:
    shutil.rmtree(install_dir, ignore_errors=True)
    archive.unlink(missing_ok=True)


def delete_app(install_dir: Path, bin_path: Path, bashrc: Path, program_name: str) -> None:
    remove_alias_from_bashrc(bashrc, program_name)
    shutil.rmtree(install_dir, ignore_errors=True)
    if bin_path.exists() or bin_path.is_symlink():
        bin_path.unlink()



def extract_archive(archive: Path, install_dir: Path) -> None:
    with tarfile.open(archive, "r:gz") as tf:
        tf.extractall(path=install_dir, filter="data")


def locate_target_bin(install_dir: Path, program_name: str) -> Path | None:
    direct = install_dir / program_name
    if is_executable_file(direct):
        return direct

    print(f"Could not locate {program_name} at expected path: {direct}")
    while True:
        user_path = input(f"Enter the app relative path from {install_dir}, or q to quit: ").strip()
        if user_path == "q":
            return None
        candidate = install_dir / user_path
        if is_executable_file(candidate):
            return candidate
        print("Path is not an executable file. Try again, or enter q to quit.")


def install_app(url: str, program_name: str) -> int:
    appdir, bindir, bashrc, archive, install_dir, bin_path = get_paths(program_name)
    appdir.mkdir(parents=True, exist_ok=True)
    bindir.mkdir(parents=True, exist_ok=True)
    delete_app(install_dir, bin_path, bashrc, program_name)
    try:
        urlretrieve(url, archive)
    except URLError as exc:
        print(f"Error: failed to download {url}: {exc}")
        return 1
    install_dir.mkdir(parents=True, exist_ok=True)
    try:
        extract_archive(archive, install_dir, strip_components=1)
    except (tarfile.TarError, OSError) as exc:
        cleanup_failed_install(install_dir, archive)
        print(f"Error: failed to extract archive: {exc}")
        return 1
    target_bin = locate_target_bin(install_dir, program_name)
    if target_bin is None:
        cleanup_failed_install(install_dir, archive)
        print("Installation aborted. Downloaded/extracted files were removed.")
        return 1
    if bin_path.exists() or bin_path.is_symlink():
        bin_path.unlink()
    os.symlink(target_bin, bin_path)
    ensure_local_bin_in_path(bashrc)
    archive.unlink(missing_ok=True)
    print("Installation finished.")
    print("Run this now:")
    print("source ~/.bashrc")
    print("Then test:")
    print(f"which {program_name}")
    print(f"{program_name} --help")
    return 0


def uninstall_app(program_name: str) -> int:
    _, _, bashrc, _, install_dir, bin_path = get_paths(program_name)
    delete_app(install_dir, bin_path, bashrc, program_name)
    print("Uninstall finished.")
    print("Run this now:")
    print("source ~/.bashrc")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Install or uninstall apps from tar.gz archives.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    install_parser = subparsers.add_parser("install", help="Install app from a tar.gz URL")
    install_parser.add_argument("url", help="tar.gz download URL")
    install_parser.add_argument("program_name", help="Command name / symlink name")

    uninstall_parser = subparsers.add_parser("uninstall", help="Uninstall a previously installed app")
    uninstall_parser.add_argument("program_name", help="Command name / symlink name")

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    if args.command == "install":
        return install_app(args.url, args.program_name)
    if args.command == "uninstall":
        return uninstall_app(args.program_name)
    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
