{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/master";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";  # IMPORTANT!!!
  };
  outputs = { self, nix-ros-overlay, nixpkgs }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
          config.permittedInsecurePackages = [
            "freeimage-3.18.0-unstable-2024-04-18"
          ];
        };
      in {
        devShells.default = pkgs.mkShell {
          name = "Gazebo build";
          packages = with pkgs; [
            colcon
            vcstool
            pkg-config

            assimp
            cmake
            ffmpeg
            gdal
            gts
            pkg-config
            spdlog
            tinyxml-2
            util-linux

            cli11
            eigen
            protobuf
            python3Packages.pybind11

            jsoncpp
            curl
            zeromq
            libzip
            libyaml
            cppzmq

            qt6.qtbase
            qt6.qtdeclarative
            qt6.qtsvg
            qt6.qt5compat

            libwebsockets
            ruby
            libsodium

            # this is for the shellhook portion
            qt6.wrapQtAppsHook
            makeWrapper
            bashInteractive

            (with pkgs.rosPackages.rolling; buildEnv {
              paths = [
                gz-ogre-next-vendor
                gz-dartsim-vendor
                # ... other ROS packages
              ];
            })
          ];
          LD_LIBRARY_PATH = "${pkgs.libsodium}/lib";

          shellHook = ''
            bashdir=$(mktemp -d)
            makeWrapper "$(type -p bash)" "$bashdir/bash" "''${qtWrapperArgs[@]}"
            exec "$bashdir/bash"
          '';
        };
      });
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
