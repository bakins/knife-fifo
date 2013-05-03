knife-fifo
==========

Project Fifo Support for Chef's Knife Command

Examples
----------
Add somethign like the following to your knife.rb.  You can also just
set them on the command line.

    # HTTP API endpoint
    knife[:fifo_endpoint] = "http://192.168.1.100/api/0.1.0/"
    knife[:fifo_username] = "admin"
    knife[:fifo_password] = "admin"


To list ipranges:
    $ knife fifo iprange list                  
    ID                                    Tag    Vlan  Network      Netmask
    10982dac-4793-46e0-9550-da546521b564  admin  0     192.168.1.0 255.255.255.0
    
To list datasets:
    $ knife fifo dataset list
    ID                                    Name          OS     Type  Version
    da144ada-a558-11e2-8762-538b60994628  ubuntu-12.04  linux  kvm   2.4.1

To list packages:
    $ knife fifo package list
    ID                                    Name    RAM   Quota  CPU CAP
    bb22de19-5e00-43a8-8af9-bfc84839dfa4  medium  1024  16     25

To list servers:
    $ knife fifo server list
    ID                                    Alias       First IP    Dataset       Package  State
    16500499-52e7-4b40-949a-6660ff9f7017  test-node2  192.168.1.108  ubuntu-12.04  medium   running
    
Finally, to create a new vm:
    $ knife fifo server create --dataset da144ada-a558-11e2-8762-538b60994628 --package  bb22de19-5e00-43a8-8af9-bfc84839dfa4 --iprange  10982dac-4793-46e0-9550-da546521b564 -N test-node1 --run-list 'role[base]'
    
Bugs and TODOs
----------
    
