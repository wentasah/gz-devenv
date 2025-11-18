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

            # Dependencies from package.xml files
            assimp
            binutils
            bullet
            cli11
            cmake
            cppzmq
            curl
            eigen
            elfutils
            ffmpeg
            freeglut
            freeimage
            gbenchmark
            gdal
            gflags
            glew
            jsoncpp
            libdwarf
            libwebsockets
            libxml2
            libyaml
            libzip
            ogre1_9
            pkg-config
            protobuf
            python3
            python3Packages.protobuf
            python3Packages.psutil
            python3Packages.pybind11
            python3Packages.pytest
            qt6.qt5compat
            qt6.qtbase
            qt6.qtdeclarative
            qt6.qtsvg
            rubocop
            ruby
            spdlog
            sqlite
            tinyxml-2
            urdfdom
            util-linux
            vulkan-loader
            xorg.libXi
            xorg.libXmu
            xorg.xorgserver

            # this is for the shellhook portion
            qt6.wrapQtAppsHook
            makeWrapper
            bashInteractive

            cppcheck

            (with pkgs.rosPackages.rolling; buildEnv {
              paths = [
                gz-ogre-next-vendor
                gz-dartsim-vendor
                zenoh-cpp-vendor

                ament-clang-format
                ament-cpplint
              ];
            })
          ];
          LD_LIBRARY_PATH = "${pkgs.libsodium}/lib";

          shellHook = ''
            # Add Qt-related environment variables.
            # https://discourse.nixos.org/t/python-qt-woes/11808/10
            setQtEnvironment=$(mktemp)
            random=$(openssl rand -base64 20 | sed "s/[^a-zA-Z0-9]//g")
            makeWrapper "$(type -p sh)" "$setQtEnvironment" "''${qtWrapperArgs[@]}" --argv0 "$random"
            sed "/$random/d" -i "$setQtEnvironment"
            source "$setQtEnvironment"
          '';
        };
      });
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
