{pkgs, ...}: {
  packages = with pkgs; [
    bash
    git
    git-lfs
    gnumake
    hugo
    nodejs
    perl
    prettier
    wrangler
  ];
}
