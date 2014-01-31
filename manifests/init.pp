# = Class: ssh_managed_key
#
# This is a container class for the managed_key defined
# resources. This class should be included by nodes which need to
# host/create a private SSH key (ssh clients) or which need to permit
# remote login via SSH public key (ssh server).
#
# The central key_master node should only need to include key_master
#
# == Sample Usage:
#
# === SSH client (originating host):
#
#   node client_host {
#       include ssh_managed_key
#       ssh_managed_key::key_pair { "production_db_backup":
#           ensure     => present,
#           local_user => "db",
#       }
#   }
#
# === SSH server (target host):
#
#   node server_host {
#       include ssh_managed_key
#       ssh_managed_key::Public_key <<| title == "production_db_backup" |>> {
#           user  => "backup",
#       }
#   }
#
class ssh_managed_key {
    $keystore = "/etc/pki/puppet"
}
