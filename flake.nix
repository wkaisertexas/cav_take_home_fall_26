{
  description = "A flake for Cavalier Autonomous Racing take-home tasks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, nix-ros-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # ROS 2 Humble packages (accessed via rosPackages.humble)
            pkgs.rosPackages.humble.ros-base
            pkgs.rosPackages.humble.ament-lint-auto
            pkgs.rosPackages.humble.ament-cmake-gtest
            
            # Dependencies mentioned in the README
            pkgs.rosPackages.humble.foxglove-bridge
            pkgs.rosPackages.humble.rosbag2-storage-mcap

            # Build tools
            pkgs.colcon # Use the standard colcon from nixpkgs/overlay
            pkgs.cmake
            pkgs.clang
            pkgs.lldb
            pkgs.git
          ];

          shellHook = ''
            # Source the setup script from the correct package path
            source ${pkgs.rosPackages.humble.ros-base}/setup.bash
            echo "ROS 2 Humble environment loaded. Run 'colcon build' to build the workspace."
          '';
        };
      });
}