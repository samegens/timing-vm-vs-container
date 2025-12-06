Vagrant.configure("2") do |config|
  # Use AlmaLinux 9 base box
  config.vm.box = "almalinux/9"

  # Configure VM settings
  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "2048"
    v.vmx["numvcpus"] = "2"
  end

  # Provision software
  config.vm.provision "shell", inline: <<-SHELL
    set -euo pipefail
    
    # Update system
    dnf update -y

    # Install EPEL repository
    dnf install -y epel-release

    # Install basic utilities
    dnf install -y \
      wget \
      curl \
      vim \
      nano \
      git \
      rsync \
      unzip \
      tar \
      which

    # Install network tools
    dnf install -y \
      net-tools \
      bind-utils \
      telnet \
      nmap-ncat \
      traceroute \
      tcpdump \
      iptraf-ng

    # Install monitoring and performance tools
    dnf install -y \
      htop \
      iotop \
      sysstat \
      strace \
      lsof

    # Install process management tools
    dnf install -y \
      screen \
      tmux

    # Install security tools
    dnf install -y \
      fail2ban \
      firewalld

    # Install container tools
    dnf install -y \
      podman \
      buildah \
      skopeo

    # Install Zabbix repository
    if ! rpm -q zabbix-release >/dev/null 2>&1; then
      rpm -Uvh https://repo.zabbix.com/zabbix/7.0/alma/9/x86_64/zabbix-release-latest-7.0.el9.noarch.rpm
    fi

    # Install Zabbix agent
    dnf install -y zabbix-agent2

    # Install nginx
    dnf install -y nginx

    # Start and enable firewalld
    systemctl start firewalld
    systemctl enable firewalld

    # Start and enable nginx
    systemctl start nginx
    systemctl enable nginx

    # Start and enable fail2ban
    systemctl start fail2ban
    systemctl enable fail2ban

    # Start and enable zabbix-agent2
    systemctl start zabbix-agent2
    systemctl enable zabbix-agent2

    # Allow HTTP and Zabbix agent traffic through firewall
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-port=10050/tcp
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --reload

    # Setup nginx container with podman
    # Pull nginx image
    podman pull docker.io/library/nginx:latest

    # Check if container already exists
    if ! podman container exists nginx-container; then
      # Create and run nginx container on port 8080
      podman run -d \
        --name nginx-container \
        -p 8080:80 \
        --restart=always \
        nginx:latest
    fi

    # Generate systemd service file for the container if it doesn't exist
    if [ ! -f /etc/systemd/system/container-nginx-container.service ]; then
      # Generate systemd service file
      cd /tmp
      podman generate systemd --new --name nginx-container --files

      # Move systemd file to system directory
      mv container-nginx-container.service /etc/systemd/system/

      # Enable lingering for root to allow user services to run without login
      loginctl enable-linger root

      # Reload systemd and enable the service
      systemctl daemon-reload
      systemctl enable container-nginx-container.service
    fi

    echo "Server provisioning complete - all software installed and services started"
  SHELL

  # Forward port 80 to host port 8080
  config.vm.network "forwarded_port", guest: 80, host: 8080

  # Forward port 8080 (container) to host port 8081
  config.vm.network "forwarded_port", guest: 8080, host: 8081
end
