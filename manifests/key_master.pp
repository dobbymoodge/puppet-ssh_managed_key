# = Class: ssh_managed_key::key_master
#
# This class implements a central public key aggregator for the
# ssh_managed_key class. In general, this class should only be
# included on the puppet master.
# 
# == Parameters:
#
#
# == Actions:
#
# Imports all exported ssh_managed_key::key_master_sync resources,
# which will trigger public key keystore management actions as
# appropriate. For example, keys which have ensure => present will be
# copied via SSH (scp) to the $ssh_managed_key::keystore directory if
# they don't already exist, keys with ensure => absent will be removed
# from the keystore
#
# == Requires:
# ssh_managed_key
#
# == Sample Usage:
#
#   node puppet_master {
#       include ssh_managed_key::key_master
#       ...
#   }
#
class ssh_managed_key::key_master {
    include ssh_managed_key

    file { $ssh_managed_key::keystore:
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 644,
    }

    Ssh_managed_key::Key_master_sync <<| |>>
}
