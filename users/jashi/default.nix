{
  pkgs,
  ...
}:
{
  nix.settings.trusted-users = [ "jashi" ];

  users = {
    users = {
      jashi = {
        shell = pkgs.zsh;
        uid = 1000;
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "users"
          "video"
          "podman"
          "input"
        ];
        group = "jashi";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDvHl0ytMMURab4B9Z8gDV4phapzem5AUJgijE7xJu5HXJqP53y/2D2Mf2i10vKtV8Zd3P++9ob1N71HXcoxZSSd5wnp0FtnfkU4pqqqtSgguESyIVskLe6eNXOUNQLc7OljCC/xdQ3bdA8yS8NQrXlqNhk/Tdyw5AZMTIPBisdRXVCEQUYLMe4DUneC0hDjlh3EApWuN3FU35OTi1Hq2Y63mObz8Wm8YVBPIE+HX+sZ3wBnF9YRd+qL0ZkKl0+WMsNqgQiX62iZVF0Z+oi1Ffm58RXQDEC73zlFKlXxABqmqny4SMx5lgpbLP+5L6B5B3Q1F0X5o/pJr+nqhkTwR1z jashi@Jans-MacBook-Pro.local"
        ];
      };
    };
    groups = {
      jashi = {
        gid = 1000;
      };
    };

  {
  # Add this block if not present:
  users.groups.bluetooth = {};

  # Then make sure your user is added to it:
  users.users.jashi = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "bluetooth" ]; # add bluetooth here
  };
}
  programs.zsh.enable = true;

}
