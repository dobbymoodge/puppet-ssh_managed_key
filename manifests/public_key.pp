# == Define: public_key
#
# Wrap builtin
# {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]
# for use with ssh_managed_key
#
# This resource should not be used directly, it is created by the
# key_pair resource
#
# === Parameters:
#
# [*namevar*]
#   An unique name, shared between private_key, public_key,
#   key_master_sync, who receive the value from key_pair
#
# [*ensure*]
#   Acceptable values include "absent" or "present".
#
#   Passed directly to +ssh_authorized_key+, see
#   {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]
#   for details
#
# [*user*]
#   Public key recipient on target node, Passed directly to
#   +ssh_authorized_key+, see
#   {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]
#   for details
#
# [*target*]
#   Alternative location for +authorized_keys+ content, Passed
#   directly to +ssh_authorized_key+, see
#   {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]
#   for details
#
define ssh_managed_key::public_key ( $ensure, $options = undef, $target = undef, $user = undef, ) {
    include ssh_managed_key

    $key_content = file("${ssh_managed_key::keystore}/${title}/pubkey", "/dev/null")

    if $ensure == "absent" {
        ssh_authorized_key { $title:
            ensure => "absent",
        }
    }
    else {
        if $key_content =~ /^(ssh-[^ ]+) ([^ ]+) ([^@]+)@(.+)$/ {
            $type = $1
            $key_str = $2
            ssh_authorized_key { $title:
                ensure  => $ensure,
                key     => $key_str,
                options => $options,
                target  => $target,
                type    => $type,
                user    => $user ? { undef => $3, default => $user },
            }
        }
        else {
            $emsg = "Can't find/read public key ${ssh_managed_key::keystore}/${title}/pubkey for key ${title} on keymaster"
            err($emsg)
            notify { "${emsg}": }
        }
    }
}
