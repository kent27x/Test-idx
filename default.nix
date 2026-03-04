{ pkgs, ... }:

{
  channel = "stable-24.11";

  packages = [
    pkgs.qemu
    pkgs.cloudflared
    pkgs.git
    pkgs.wget
    pkgs.python3
    pkgs.htop
  ];

  idx.workspace.onStart = {
    qemu = ''
      set -e

      VM_DIR="$HOME/qemu"
      RAW_DISK="$VM_DIR/windows.qcow2"
      WIN_ISO="$VM_DIR/windows11.iso"
      VIRTIO_ISO="$VM_DIR/virtio-win.iso"
      NOVNC_DIR="$HOME/noVNC"

      mkdir -p "$VM_DIR" "$NOVNC_DIR"

      # Download Windows ISO
      if [ ! -f "$WIN_ISO" ]; then
        wget -O "$WIN_ISO" https://github.com/kmille36/idx-windows-gui/releases/download/1.0/automic11.iso
      fi

      # Download VirtIO drivers
      if [ ! -f "$VIRTIO_ISO" ]; then
        wget -O "$VIRTIO_ISO" https://github.com/kmille36/idx-windows-gui/releases/download/1.0/virtio-win-0.1.271.iso
      fi

      # Create QCOW2 disk if missing
      if [ ! -f "$RAW_DISK" ]; then
        qemu-img create -f qcow2 "$RAW_DISK" 11G
      fi

      # Start QEMU with RealVNC
      nohup qemu-system-x86_64 \
        -enable-kvm \
        -cpu host \
        -smp 4,sockets=1,cores=4,threads=1 \
        -m 11264 \
        -drive file="$RAW_DISK",format=qcow2,if=virtio \
        -cdrom "$WIN_ISO" \
        -drive file="$VIRTIO_ISO",media=cdrom,if=ide \
        -vnc :0,password \
        -vga virtio \
        -device virtio-balloon-pci \
        -net nic -net user,hostfwd=tcp::3389-:3389 \
        > /tmp/qemu.log 2>&1 &

      echo "QEMU started. Connect via RealVNC on port 5900."
    '';
  };
}
