resource "google_compute_instance" "primary_db" {
  name         = "primary-db"
  machine_type = "n1-standard-2"
  zone         = var.zone
  tags         = ["database", "ssh"]

  boot_disk {
    initialize_params {
      image = var.image 
    }
  }

  network_interface {
    network = google_compute_network.database_vpc_network.name
    subnetwork = google_compute_subnetwork.database_subnet.name
    access_config {}
  }

  metadata = {
    postgres-password = "mysecretpassword",
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }

  connection {
    type  = "ssh"
    user  = var.user
    host  = self.network_interface[0].access_config[0].nat_ip
    timeout = "60s"
    private_key = file(var.privatekeypath)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sh -c 'echo \"deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main\" > /etc/apt/sources.list.d/pgdg.list'",
      "sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -",
      "sudo apt-get update -y",
      "sudo apt-get -y install postgresql postgresql-contrib-15",
      "sudo sed -i \"s/#listen_addresses = 'localhost'/listen_addresses = '*'/\" /etc/postgresql/15/main/postgresql.conf",
      "sudo echo \"host all all 0.0.0.0/0 md5\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo echo \"host all all ${google_compute_instance.primary_db.network_interface[0].access_config[0].nat_ip} md5\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo echo \"host all all 127.0.0.1/32   md5\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo echo \"host all all ::1/128    trust\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo echo \"local all all   trust\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo echo \"host all postgres 0.0.0.0/0  md5\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo echo \"local all all peer\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo echo \"local all postgres md5\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo echo \"local all postgres ident sameuser\" | sudo tee -a /etc/postgresql/15/main/pg_hba.conf",
      "sudo systemctl restart postgresql",
      "cat /etc/postgresql/15/main/postgresql.conf",

      
      /* "sudo psql -h localhost -U postgres -d projects -c 'CREATE SCHEMA pgbench;'" */
    ]

    connection {
      type  = "ssh"
      user  = var.user
      host  = self.network_interface[0].access_config[0].nat_ip
      agent = false
      timeout = "60s"
      private_key = file(var.privatekeypath)
    }
  }

  lifecycle {
    ignore_changes = [
      network_interface,
      boot_disk[0].initialize_params[0].image
    ]
  }

  depends_on = [ google_compute_firewall.ssh_firewall, 
                 google_compute_firewall.database_firewall,
                  google_compute_network.database_vpc_network]
}

resource "google_compute_instance" "standby_db" {
  name         = "standby-db"
  machine_type = "n1-standard-2"
  zone         = var.zone
  tags         = ["database", "ssh"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = google_compute_network.database_vpc_network.name
    subnetwork = google_compute_subnetwork.database_subnet.name
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }

  connection {
    type  = "ssh"
    user  = var.user
    host  = self.network_interface[0].access_config[0].nat_ip
    agent = false
    timeout = "60s"
    private_key = file(var.privatekeypath)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo sh -c 'echo \"deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main\" > /etc/apt/sources.list.d/pgdg.list'",
      "sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -",
      "sudo apt-get update -y",
      "sudo apt-get -y install postgresql postgresql-contrib-15",
      "sudo systemctl stop postgresql",
      "sudo rm -rf /var/lib/postgresql/15/main",
      "sudo pg_basebackup -h ${google_compute_instance.primary_db.network_interface[0].access_config[0].nat_ip} -D /var/lib/postgresql/15/main -U postgres -v -P --wal-method=stream",
      "sudo touch /var/lib/postgresql/15/main/standby.signal",
      "sudo sed -i \"s/#hot_standby = off/hot_standby = on/\" /etc/postgresql/15/main/postgresql.conf",
      "sudo echo \"primary_conninfo = 'host=${google_compute_instance.primary_db.network_interface[0].access_config[0].nat_ip} port = 5432 user=replicator password=mysecretpassword application_name=${self.name}\" | sudo tee -a /etc/postgresql/13/main/postgresql.conf",
      "sudo systemctl start postgresql"
    ]
    
    connection {
      type  = "ssh"
      user  = var.user
      host  = self.network_interface[0].access_config[0].nat_ip
      agent = false
      timeout = "60s"
      private_key = file(var.privatekeypath)
    }
  }

  lifecycle {
    ignore_changes = [
      network_interface,
      boot_disk[0].initialize_params[0].image
    ]
  }

  depends_on = [ google_compute_firewall.ssh_firewall, 
                google_compute_firewall.database_firewall,
                google_compute_network.database_vpc_network]
}
