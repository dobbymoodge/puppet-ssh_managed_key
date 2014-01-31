# = Define: private_key
#
# Manage a private ssh key similar to the Puppet built-in
# {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]
#
# This resource should not be used directly, it is created by the
# key_pair resource
#
# == Parameters:
# [*namevar*]
#   An unique name, shared between private_key, public_key,
#   key_master_sync, who receive the value from key_pair
#
# [*ensure*]
#   Acceptable values include "absent" or "present".
#
#   "present" will create a private/public key pair if none exists.
#
#   "absent" will remove the specified key pair.
#
# [*user*]
#   The user to create the private/public key pair for.
#
# [*target*]
#   The filename for deriving the private and public key filenames. By
#   default, this is "+id_$type+", i.e. "+id_rsa+". The private key
#   filename is this value unmodified; the public key filename appends
#   "+.pub+"
#
# [*type*]
#   The SSH key type to generate. Acceptable values are the same as
#   for the type parameter in the Puppet built-in
#   {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]
#
# [*bits*]
#   SSH key length to generate in bits. Acceptable values are the same
#   as for the bits parameter in the Puppet built-in
#   {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]
#
# == Sample Usage:
#
#
define ssh_managed_key::private_key ( $ensure, $user, $target = undef, $type = "rsa", $bits = 4096, ) {
    Exec { path => ['/bin', '/usr/bin'] }

    # key name (if different from default)
    $key_name = $target ? {
        undef   => "id_${type}",
        default => $target,
    }

    # path to user's .ssh directory, to be expanded by bash
    $key_path = "~${user}/.ssh/${key_name}"

    # catalog-wide unique ID for this keypair
    $key_id = "$title"
    if $ensure == "absent" {
        # delete the key
        exec { "ssh_privkey_delete_$key_id":
            command => "bash -c \"rm -f ${key_path}\"",
            onlyif  => "bash -c \"test -e ${key_path}\"",
        }
        exec { "ssh_pubkey_delete_$key_id":
            command => "bash -c \"rm -f ${key_path}.pub\"",
            onlyif  => "bash -c \"test -e ${key_path}.pub\"",
        }
    }
    else {
        exec { "ssh_keygen_$key_id":
            command  => "bash -c \"ssh-keygen -b ${bits} -t ${type} -f ${key_path} -N ''\"",
            unless   => "bash -c \"test -e ${key_path}\"",
            user     => $user,
        }
    }
}
