# = Define: key_master_sync
#
# Collects new public keys from hosts for storage in central keystore
# (see key_master).
#
# This resource should not be used directly, it is created by the
# key_pair resource
#
# == Parameters:
#
# [*namevar*]
#   An unique name, shared between private_key, public_key,
#   key_master_sync, who receive the value from key_pair
#
# [*ensure*]
#   Acceptable values include "absent" or "present".
#
#   "present" will pull in (via +scp+) the public key from the
#   appropriate host and store it in the central keystore
#
#   "absent" will remove the matching key from the central keystore
#
# [*host*]
#   Address of the host where the private/public key pair originate
#   from (see private_key)
#
# [*target*]
#   Filename base for the private/public key pair on the originating
#   host
#
# [*user*]
#   User name of the account to which the key pair belong
#
define ssh_managed_key::key_master_sync ( $ensure, $host, $target, $user, ) {
    include ssh_managed_key
    Exec { path => ['/bin', '/usr/bin'] }
    $pubkey = "${ssh_managed_key::keystore}/${title}/pubkey"

    if $ensure == "absent" {
        # remove $key_content file
        file { "key_master_remove_keystore_${title}":
            ensure  => absent,
            path    => "${ssh_managed_key::keystore}/${title}",
            purge   => true,
            recurse => true,
            force   => true,
        }
    }
    else {
        # Create pubkey store if missing
        $kmck = "key_master_create_keystore_${title}"
 
        file { $kmck:
            ensure  => directory,
            path    => "${ssh_managed_key::keystore}/${title}",
            require => File[$ssh_managed_key::keystore],
        }
        $kmsp = "key_master_sync_pubkey_${title}"
        # scp local server's public key into $key_content if needed
        exec { $kmsp:
            command => "scp root@${host}:~${user}/.ssh/${target}.pub ${pubkey}",
            unless  => "bash -c \"test -e ${pubkey}\"",
            require => File["${ssh_managed_key::keystore}/${title}"],
        }
    }
}
