Feature: Replayer
  In order to replay the oplog
  As a CLI
  I want to provide a mechanism to tail and replay the oplog

  Scenario: Mongo to mongo replay
    When I run `oplogreplayer mongo2mongo --test -c ../../sampleConf.yaml`
    Then the output should contain "Test mode enabled"

