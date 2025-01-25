{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vscode
    vscode-extensions.yzhang.markdown-all-in-one
    vscode-extensions.yzane.markdown-pdf
    vscode-extensions.golang.go
    vscode-extensions.ms-python.python
    vscode-extensions.ms-python.pylint
    vscode-extensions.rust-lang.rust-analyzer
  ];
}
