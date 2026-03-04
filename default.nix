{ pkgs, ... }: {

  channel = "stable-24.11";

  packages = [
    pkgs.qemu
    pkgs.wget
    pkgs.htop
  ];

  idx.workspace.onStart = {
    startvm = ''
      set -e

      VM_DIR="$HOME/qemu"
      DISK="$VM_DIR/windows.qcow2"
      mkdir -p "$VM_DIR"

      # Create 11GB disk if missing
      if [ ! -f "$DISK" ]; then
        qemu-img create -f qcow2 "$DISK" 11G
      fi

      echo "Starting Windows VM..."

      # Start QEMU with VNC, log VNC info to file for RealVNC
      nohup qemu-system-x86_64 \
        -enable-kvm \
        -m 11264 \
        -smp 4 \
        -drive file="$DISK",format=qcow2 \
        -vnc :0,password \
        > /home/user/vnc-info.txt 2>&1 &

      echo "VNC info saved to /home/user/vnc-info.txt"

      # Keep workspace alive 12 hours
      for i in {1..720}; do
        echo "Running minute $i"
        sleep 60
      done
    '';
  };

  idx.previews = {
    enable = true;
    previews = {
      qemu = {
        manager = "web";
        command = [
          "bash" "-lc"
          "echo 'noVNC running on port 8888'"
        ];
      };
      terminal = {
        manager = "web";
        command = [ "bash" ];
      };
    };
  };
}
