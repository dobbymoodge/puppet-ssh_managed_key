name 'ssh_managed_key'
version '0.0.1'
author 'John Lamb - jolamb@redhat.com'
summary 'Provides automatic private/public SSH key generation and
distribution for setting up automatable key auth on Linux hosts'
description 'This module automates the process of generating a
 public/private SSH key pair and distributing the public key among
 target users@hosts under Puppet control. Use of this module assumes 3
 host roles:

 - Client: the private key holder, origin of SSH connections

 - Server: the public key holder, endpoint for SSH connections

 - Key Master: hosts the public key store; should have passwordless
   remote root SSH to Client and Server hosts already
   configured. Assumed to be the puppet master

 Example nodes.pp:
  node puppet_master {
      include ssh_managed_key::key_master
      ...
  }

  node client_host {
      include ssh_managed_key
      ssh_managed_key::key_pair { "production_db_backup":
          ensure     => present,
          local_user => "db",
      }
  }

  node server_host {
      include ssh_managed_key
      ssh_managed_key::Public_key <<| title == "production_db_backup" |>> {
          user  => "backup",
      }
  }'
license 'GPL'
project_page 'https://github.com/dobbymoodge/puppet-ssh_managed_key'
