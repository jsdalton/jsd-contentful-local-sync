# Local Sync

Local Sync is a Sinatra-based Ruby application that provides an API for accessing and synchronizing Contentful entries locally (i.e. offline).

## Problem Statement

A company has some agents that are traveling through the countryside and are offline most of the time. These agents get updates on products from a contentful space.

Your assignment is to produce an application written in Ruby that runs on the agent laptop.

This application should:

* use the [sync api][1] to synchronize the products data with a local datastore
* have an HTTP endpoint that presents all the product entries in order of creation in JSON form that reflects the structure of the [Content Delivery API][2]

At any point it should be possible through HTTP calls

* to trigger a sync that incrementally updates the local data.
* to completely reset the local data by triggering a full initial sync.

[1] http://docs.contentfulcda.apiary.io/#reference/synchronization
[2] https://cdn.contentful.com/spaces/cfexampleapi/entries?access_token=b4c0n73n7fu1

## Install

### Using Vagrant

To install and run the application using Vagrant, the following are required on the host computer:

* Vagrant >= 1.8.1
* Ansible >= 2.0
* Virtual Box

To install, cd into the project directory and run:

```
$ vagrant up
```

This command will launch a virtual machine and provision in with all required project dependencies.



