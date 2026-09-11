{pkgs, ...}: {
  packages = with pkgs; [
    bash
    git
    git-lfs
    gnumake
    hugo
    perl
    wrangler
  ];
}
