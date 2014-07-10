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

## Configuration

Here is a sample configuration file that can be used.

    resume: true

    source:
      replicaSet:	rs_name
      host:		    "rs_host_1:27017,rs_host_2:27017"
      username:     rsUser
      password:     rsPass

    dest:
      host:		"localhost:27017"
      onlyDbs:  "foo,bar"

The example above shows how use a replicaset with authentication enabled as a source, and a single instance with no
authentication as a target.

`resume` - determines if the oplog replay is to be resumed from the last known point. A timestamp is stored at `dest` in local.oplog.status that is used for resumes.

`source` and `dest` are the "from" and "to" servers. The source should be a replicaset (for the oplog). The example above shows all the used keys. The following affects how the connection to mongo is made, in both source and dest

 * If there is no username and password, then authentication is disabled
 * the presence of `replicaSet` in the config is used to determine whether to use a regular client or replica set client. Removing `replicaSet` but leaving a comma-seperated list of hosts may produce unpredictable results.

`onlyDbs` will enable filtering on the replay, so that only the databases in the list will have operations executed on them.

## Usage

`oplogreplayer mongo2mongo -c path/to/oplogConf.yaml`

### Options

`-t / --timestamp` - Specifies a timestamp to resume from. Note that this resume, regardless of configuration file setting, and it will overwrite the persisted timestamp for future resumes.


## Contributing

1. Fork it ( http://github.com/brettcave/oplogreplayer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
