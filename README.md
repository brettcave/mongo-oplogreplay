# Oplogreplayer

Oplogreplayer connects to a replica set and monitors write operations by monitoring the oplog, replaying them
onto another replica set / mongo instance.

## Installation

Add this line to your application's Gemfile:

    gem 'oplogreplayer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oplogreplayer

## Usage

TODO: confirm usage once parameter syntax has been finalized.

## Configuration

    resume: true

    source:
      replicaSet:	rs_name
      host:		    "rs_host_1:27017,rs_host_2:27017"
      username:     rsUser
      password:     rsPass
      initialDb:	admin

    dest:
      mode:		single
      host:		"localhost:27017"
      username:	localUser
      password:	localPass
      initialDb:	admin


## Contributing

1. Fork it ( http://github.com/brettcave/oplogreplayer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
