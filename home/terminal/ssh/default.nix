{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "confirm";
    matchBlocks = {
      deck = {
        hostname = "steamdeck";
        user = "deck";
        port = 22;
      };
      dockervm = {
        hostname = "192.168.178.67";
        user = "nydragon";
        port = 22;
      };
      vps = {
        hostname = "vps.ccnlc.eu";
        user = "root";
        port = 56528;
      };
    };
  };
}
