{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    golangci-lint
    golangci-lint-langserver
    vscode-extensions.golang.go
  ];
}