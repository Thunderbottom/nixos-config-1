{ config, lib, pkgs, my, ... }:
let
  cgitcAbbrs = (pkgs.callPackage my.drvs.cgitc { }).abbrs;
in
{
  programs = {
    direnv.enable = true;

    # https://www.youtube.com/watch?v=Oyg5iFddsJI
    zoxide.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type file --follow"; # FZF_DEFAULT_COMMAND
      defaultOptions = [ "--height 20%" ]; # FZF_DEFAULT_OPTS
      fileWidgetCommand = "fd --type file --follow"; # FZF_CTRL_T_COMMAND
    };

    fish = {
      enable = true;

      functions = {
        cprmusic = "mpv http://playerservices.streamtheworld.com/pls/KXPR.pls";
        mpv = "command mpv --player-operation-mode=pseudo-gui $argv";
        nix-locate = "command nix-locate --top-level $argv";
        ssh = "env TERM=xterm-256color ssh $argv";
        # std = "rustup doc --std";
        t = "todo.sh $argv";
        win10 = "doas virsh start windows10";
        fish_greeting = "";
      };

      shellAbbrs = {
        l = "exa";
        la = "exa -la";
        ll = "exa -l";
        ls = "exa";
        tree = "exa -T";
        vim = "nvim";
        vi = "nvim";
        "cd.." = "cd ..";
        "..." = "../..";
        "...." = "../../..";
        "....." = "../../../..";
        "......" = "../../../../..";
        "......." = "../../../../../..";
        weechat = "tmux -L weechat attach";
      } // cgitcAbbrs;

      shellInit = ''

        # Hydro prompt config
        set --global --export hydro_symbol_prompt '>'
        set --global --export hydro_symbol_git_dirty '*'
        set --global --export hydro_color_pwd green
        set --global --export hydro_color_error red
      '';

      loginShellInit = ''

        # tmux counts as a login shell
        if [ -z $TMUX ]
          # If terminal is login, unset __HM_SESS_VARS_SOURCED, because the
          # graphical session will inherit this (which means child applications
          # will never re-source when necessary)
          set -e __HM_SESS_VARS_SOURCED

          # Start sway
          if [ (tty) = "/dev/tty1" ]
              systemctl --user unset-environment SWAYSOCK I3SOCK WAYLAND_DISPLAY DISPLAY \
                        IN_NIX_SHELL __HM_SESS_VARS_SOURCED GPG_TTY NIX_PATH
              exec sway >/dev/null 2>/tmp/sway.log # TODO: log to syslog even without a unit pls
          end

          # Start windows VM
          if [ (tty) = "/dev/tty5" ]
            exec doas virsh start windows10
          end

          exit
        end
      '';

      interactiveShellInit = ''

        set --append fish_user_paths $HOME/.cargo/bin

        # GPG configuration
        ${pkgs.gnupg}/bin/gpg-connect-agent updatestartuptty /bye &>/dev/null
        set --global --export PINENTRY_USER_DATA gtk # nonstandard -- used by my pinentry script
        set --global --export GPG_TTY (tty)

        # For zoxide's fzf window
        set --global --export _ZO_FZF_OPTS '--no-sort --reverse --border --height 40%'

        # Miscellaneous exports
        set --global --export LS_COLORS 'ow=36:di=1;34;40:fi=32:ex=31:ln=35:'

        t ls
        printf '\n'
      '';
    };
  };
}
