# This declares a job named "docs". There can be exactly one
# job declaration per job file.
job "vosk-node" {
  # Specify this job should run in the region named "us". Regions
  # are defined by the Nomad servers' configuration.
  region = "global"

  # Spread the tasks in this job between us-west-1 and us-east-1.
  datacenters = ["Miami1"]

  # Run this job as a "service" type. Each job type has different
  # properties. See the documentation below for more examples.
  type = "service"

  # Specify this job to have rolling updates, two-at-a-time, with
  # 30 second intervals.
  update {
    stagger      = "30s"
    max_parallel = 2
  }


  # A group defines a series of tasks that should be co-located
  # on the same client (host). All tasks within a group will be
  # placed on the same host.
  group "vosk-node" {
    # Specify the number of these tasks we want.
    count = 5

    network {

      port "vosk-node" {
        to = 2700
      }

    }

    
    # The service block tells Nomad how to register this service
    # with Consul for service discovery and monitoring.
    service {
      # This tells Consul to monitor the service on the port
      # labelled "http". Since Nomad allocates high dynamic port
      # numbers, we use labels to refer to them.
      port = "vosk-node"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    # Create an individual task (unit of work). This particular
    # task utilizes a Docker container to front a web application.
    task "vosk-node-16k" {
      # Specify the driver to be "docker". Nomad supports
      # multiple drivers.
      driver = "docker"

      # Configuration is specific to each driver.
      config {
        image = "neogenai/kaldi-beast-en:v1.0.0"
        ports = ["vosk-node"]
        auth {
          username = "mattriddell"
          password = "dockerhub_password"
        }
      }

      # Specify the maximum resources required to run the task,
      # include CPU and memory.
      resources {
        cpu    = 12004 # MHz
        memory = 5001 # MB
      }
    }
  }
}