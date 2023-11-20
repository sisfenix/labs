packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "autogenerated_1" {
  boot_command   = ["<esc><wait>", "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed_debian.cfg<wait>", "<enter><wait>"]
  http_directory = "http"
  boot_wait      = "10s"
  guest_os_type  = "Debian12_64"
  // iso_url          = "https://cdimage.debian.org/debian-cd/12.2.0/amd64/iso-cd/debian-12.2.0-amd64-netinst.iso"
  iso_url          = "d:/install/linux/debian-12.2.0-amd64-netinst.iso"
  iso_checksum     = "sha256:23ab444503069d9ef681e3028016250289a33cc7bab079259b73100daee0af66"
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_wait_timeout = "10000s"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  vboxmanage       = [["modifyvm", "{{ .Name }}", "--memory", "4096"], ["modifyvm", "{{ .Name }}", "--cpus", "4"]]
}

build {
  name    = "teste"
  sources = ["sources.virtualbox-iso.autogenerated_1"]

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    script          = "scripts/vagrant.sh"
  }

  // Convert machines to vagrant boxes
  post-processor "vagrant" {
    compression_level   = 9
    keep_input_artifact = true
    output              = "box/debian_sisfenix_{{ .Provider }}.box"
  }
}