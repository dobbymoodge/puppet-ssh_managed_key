# = Define: key_pair
#
# Manages a private/public ssh key pair on per-key and per-user basis.
#
# Allows specification of local user (private key holder) and remote
# user (public key holder), SSH key type and bit length (a la
# ssh_authorized_key), target filenames for private and public keys,
# and public key options.
#
# == Parameters:
#
# [*namevar*]
#   An unique name, used to coordinate depended defined resources
#   private_key, public_key, and key_master_sync
#
# [*ensure*]
#   Acceptable values include "absent" or "present".
#
#   Passed to dependent classes to create/distribute a key pair or to
#   remove said pair
#
# [*local_user*]
#   The account on the originating host to whom the private key will
#   belong
#
# [*remote_user*]
#   The username of the account on the target "server" host, if
#   different from +local_user+
#
# [*privkey_target*]
#   The base filename for the private/public key pair on the
#   originating host. This can be useful for cases where one account
#   needs to connect to multiple distinct accounts on multiple hosts,
#   but for security reasons sharing keys for said connections is A
#   Bad Idea.
#
#   In general, this can be left undefined.
#
# [*pubkey_target*]
#   The alternate filename for the authorized_keys file on the target
#   "server" host. Passed directly to +target+ param of
#   +ssh_authorized_key+, see
#   {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]
#   for details
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
# [*pubkey_options*]
#   Passed directly to the +options+ parameter in the Puppet built-in
#   {ssh_authorized_key}[http://docs.puppetlabs.com/references/stable/type.html#sshauthorizedkey]. This
#   defaults to +from="$ipaddress,$fqdn"+. Any specified values are
#   *appended* to this default.
#
# == Sample Usage:
# 
#
define ssh_managed_key::key_pair (
    $ensure,
    $local_user,
    $remote_user = undef,
    $privkey_target = undef,
    $pubkey_target = undef,
    $type = "rsa",
    $bits = 4096,
    $pubkey_options = undef,
    ) {

    include ssh_managed_key

    $privkey_name = $privkey_target ? {
        undef => "id_${type}",
        default => $privkey_target,
    }

    $privkey_path = "~${local_user}/.ssh/${key_name}"

    $from_option = "from=\"${ipaddress},${fqdn}\""

    ssh_managed_key::private_key { $title:
        ensure => $ensure,
        user   => $local_user,
        target => $privkey_name,
        type   => $type,
        bits   => $bits,
        tag    => $tag,
    }

    # Define method for copying (via scp) pubkey from private key
    # server to key store on puppet master:
    #   scp root@host1:~${user}/.ssh/${key_name} /key/store/${title}
    @@ssh_managed_key::key_master_sync { $title:
        ensure => $ensure,
        user   => $local_user,
        host   => $fqdn,
        target => $privkey_name,
        tag    => $tag,
    }

    if $ensure == "present" {
        $_pubkey_options = $pubkey_options ? {
            undef   => [$from_option, ],
            default => [$from_option, $pubkey_options, ],
        }
    }

    @@ssh_managed_key::public_key { $title:
        ensure  => $ensure,
        options => $_pubkey_options,
        target  => $pubkey_target,
        # type    => $type,
        user    => $remote_user,
        tag     => $tag,
    }
}
