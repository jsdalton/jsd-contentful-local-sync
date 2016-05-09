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

If at any time the dependencies need to be refreshed, just run...

```
$ vagrant provision
```

...from the host computer.

## Configure

Settings, including Contentful access token and space ID, should be configured in the `config.yml` file.

## Run

To start the application, from the VM: SSH on to the VM (via `vagrant ssh`) and run:

```
$ ./local-sync/bin/start
```

Or to run it from the host as a one-liner:

```
vagrant ssh -c "cd local-sync && ./bin/start"
```

This will start a Rack server on port `4567` bound to `0.0.0.0`. Vagrant is configured to forward port 14567 on your host machine, so you should be able to see a "Hello, World" message from your host at:

http://localhost:14567/

## Example Usage

With the server running, you can send requests to the various API endpoints. For example:

```
# Nothing in the local store yet
$ curl -X GET http://localhost:14567/api/entries
{"sys":{"type":"Array"},"total":0,"items":[]}

# Do an initial sync
$ curl -X POST -H "Content-Type: application/json" -d '{}' http://localhost:14567/api/sync-requests
{"id":"f55ab177-f0b5-4d0b-a075-1be047cd3174","created_at":"2016-05-09T02:55:49+00:00","next_sync_url":"https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCmULCncKSOsOGw58_w6jCoyVuMMKww74PSi1LwrwFJHbCvcO6WQhewptgDCMGwooLTwvDtsOTfXjDs0UXdsOMwqvCo3lVElIXRCtow7HCiTc3wqVnwqzCmQ","initial":true}

# Now we have some local data
$ curl -X GET http://localhost:14567/api/entries
{"sys":{"type":"Array"},"total":3,"items":[{"fields":{"name":"Piano","description":"A beautiful piano. Gently used.","price":40},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"5UM2X64H1SS204gK6quySW","type":"Entry","createdAt":"2016-05-07T03:20:30.867Z","updatedAt":"2016-05-07T23:43:34.965Z","revision":2,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}},{"fields":{"name":"Lounge Chair","description":"A comfortable lounge chair","price":15},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"78o4nLrLrOqUuAQaiMmUy6","type":"Entry","createdAt":"2016-05-07T03:20:52.887Z","updatedAt":"2016-05-07T03:20:52.887Z","revision":1,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}},{"fields":{"name":"Coffee Table","description":"It's a sturdy coffee table.","price":50},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"6tF2LfRmU0koWuUK2eQmqI","type":"Entry","createdAt":"2016-05-07T23:43:18.846Z","updatedAt":"2016-05-07T23:43:18.846Z","revision":1,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}}]}

# Add another entry in Contentful, then do another sync
$ curl -X POST -H "Content-Type: application/json" -d '{}' http://localhost:14567/api/sync-requests
{"id":"ccfb895f-af84-4ffc-9e11-14daeebfb944","created_at":"2016-05-09T02:57:10+00:00","next_sync_url":"https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyZlwoTCkcOUw69yw4oswrpiDsK2YsKgw6zCsVfCpMKvMEoqw5Y_w4lCw4Ibw7HDh3fCsSPDu3cgw5gwKQF8wqUUJwAvwrLDrMOcw7vCmzZwwq9fRzTCunodUBFRBw","initial":false}

# Our new entry got added to the end
$ curl -X GET http://localhost:14567/api/entries
{"sys":{"type":"Array"},"total":4,"items":[{"fields":{"name":"Piano","description":"A beautiful piano. Gently used.","price":40},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"5UM2X64H1SS204gK6quySW","type":"Entry","createdAt":"2016-05-07T03:20:30.867Z","updatedAt":"2016-05-07T23:43:34.965Z","revision":2,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}},{"fields":{"name":"Lounge Chair","description":"A comfortable lounge chair","price":15},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"78o4nLrLrOqUuAQaiMmUy6","type":"Entry","createdAt":"2016-05-07T03:20:52.887Z","updatedAt":"2016-05-07T03:20:52.887Z","revision":1,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}},{"fields":{"name":"Coffee Table","description":"It's a sturdy coffee table.","price":50},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"6tF2LfRmU0koWuUK2eQmqI","type":"Entry","createdAt":"2016-05-07T23:43:18.846Z","updatedAt":"2016-05-07T23:43:18.846Z","revision":1,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}},{"fields":{"name":"Bed","description":"A comfy bed.","price":80},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"bbE3lBZNTyWEC4KMu2qW4","type":"Entry","createdAt":"2016-05-09T02:56:45.511Z","updatedAt":"2016-05-09T02:56:45.511Z","revision":1,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}}]}

# (Turn off our wifi) Uh oh, lost our Internet connection!
$ curl -I https://cdn.contentful.com/spaces/cfexampleapi/entries?access_token=b4c0n73n7fu1
curl: (6) Could not resolve host: cdn.contentful.com

# Sync returns a 504 since Contentful is unavailble
$ curl -i -X POST -H "Content-Type: application/json" -d '{}' http://localhost:14567/api/sync-requests && echo
HTTP/1.1 504 Gateway Timeout
Content-Type: text/html;charset=utf-8
Content-Length: 0
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Server: WEBrick/1.3.1 (Ruby/2.2.4/2015-12-16)
Date: Mon, 09 May 2016 02:57:40 GMT
Connection: Keep-Alive


# Fortunately, we can still access our data, since it's saved locally
$ curl -X GET http://localhost:14567/api/entries
{"sys":{"type":"Array"},"total":4,"items":[{"fields":{"name":"Piano","description":"A beautiful piano. Gently used.","price":40},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"5UM2X64H1SS204gK6quySW","type":"Entry","createdAt":"2016-05-07T03:20:30.867Z","updatedAt":"2016-05-07T23:43:34.965Z","revision":2,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}},{"fields":{"name":"Lounge Chair","description":"A comfortable lounge chair","price":15},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"78o4nLrLrOqUuAQaiMmUy6","type":"Entry","createdAt":"2016-05-07T03:20:52.887Z","updatedAt":"2016-05-07T03:20:52.887Z","revision":1,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}},{"fields":{"name":"Coffee Table","description":"It's a sturdy coffee table.","price":50},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"6tF2LfRmU0koWuUK2eQmqI","type":"Entry","createdAt":"2016-05-07T23:43:18.846Z","updatedAt":"2016-05-07T23:43:18.846Z","revision":1,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}},{"fields":{"name":"Bed","description":"A comfy bed.","price":80},"sys":{"space":{"sys":{"type":"Link","linkType":"Space","id":"ti1zf61egylr"}},"id":"bbE3lBZNTyWEC4KMu2qW4","type":"Entry","createdAt":"2016-05-09T02:56:45.511Z","updatedAt":"2016-05-09T02:56:45.511Z","revision":1,"contentType":{"sys":{"type":"Link","linkType":"ContentType","id":"product"}}}}]}

# Clear out the local store
$ curl -X DELETE http://localhost:14567/api/entries
{"status":"ok"}

# And we're back where we started
$ curl -X GET http://localhost:14567/api/entries
{"sys":{"type":"Array"},"total":0,"items":[]}
```


## API Documentation

The HTTP API is RESTful. It supports only JSON in requests and response.

### Authentication

Not implemented!

### Summary

| Endpoint | Description |
| --- | --- | --- |
| `GET /api` | Status check |
| `POST /api/sync-requests` | Create a new sync request |
| `GET /api/entries` | Get entries from local store |
| `DELETE /api/entries` | Clear local store |

### Endpoint Details

#### `GET /api`

Returns a basic status OK if the API is operational.

##### Usage

*Example: Get status*

Request:

```
curl -X GET http://localhost:14567/api
```

Response:

```
{ "status": "ok" }
```

#### `POST /api/sync-requests`

Creates a new request to sync content against Contentful space.

##### Parameters

* **`initial`** (optional). Set to `true` to do a complete resync and to clear the local data store. (Default is `false`)

##### Usage

*Example: Initiate a request for an update sync.*

Request:

```
curl -X POST -H "Content-Type: application/json" -d '{}' http://localhost:14567/api/sync-requests
```

Response:

```
{
  "id": "d6282de4-bb4a-4bf1-990f-48b0d1350ce4",
  "created_at": "2016-05-08T19:49:45+00:00",
  "next_sync_url": "https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCmULCncKSOsOGw58_w6jCoyVuMMKww74PSi1LwrwFJHbCvcO6WQhewptgDCPCp8O1FDjDjSLChCXCuk8Ow6vDhUzDtcOtERvCrgvDkMO_RsKWG8O_HcOlwrjDvwpe",
  "initial": false
}
```

Note: The response will contain a value of `true` for "initial" if a previous sync was not found (and thus the local store needed to be reloaded). 

*Example: Initiate a request for a fresh sync.*

When initial is true, a complete sync will always be requested and the local data store cleared.

Request:

```
curl -X POST -H "Content-Type: application/json" -d '{"initial":"true"}' http://localhost:14567/api/sync-requests
```

Response:

```
{
  "id": "d6282de4-bb4a-4bf1-990f-48b0d1350ce4",
  "created_at": "2016-05-08T19:49:45+00:00",
  "next_sync_url": "https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdybCmULCncKSOsOGw58_w6jCoyVuMMKww74PSi1LwrwFJHbCvcO6WQhewptgDCPCp8O1FDjDjSLChCXCuk8Ow6vDhUzDtcOtERvCrgvDkMO_RsKWG8O_HcOlwrjDvwpe",
  "initial": true
}
```

#### `GET /entries`

Get a complete list of entries stored locally. If no sync has been performed, no entries will be returned.

##### Usage

*Example: Get entries when a sync has not yet been performed.*

Request:

```
curl -X GET http://localhost:14567/api/entries
```

Response:

```
{
  "sys": {
    "type": "Array"
  },
  "total": 0,
  "items": []
}
```

*Example: Get entries when a sync has already been performed*

Request:

```
curl -X GET http://localhost:14567/api/entries
```

Response:

```
{
  "sys": {
    "type": "Array"
  },
  "total": 3,
  "items": [{
    "fields": {
      "name": "Piano",
      "description": "A beautiful piano. Gently used.",
      "price": 40
    },
    "sys": {
      "space": {
        "sys": {
          "type": "Link",
          "linkType": "Space",
          "id": "ti1zf61egylr"
        }
      },
      "id": "5UM2X64H1SS204gK6quySW",
      "type": "Entry",
      "createdAt": "2016-05-07T03:20:30.867Z",
      "updatedAt": "2016-05-07T23:43:34.965Z",
      "revision": 2,
      "contentType": {
        "sys": {
          "type": "Link",
          "linkType": "ContentType",
          "id": "product"
        }
      }
    }
  }, {
    "fields": {
      "name": "Lounge Chair",
      "description": "A comfortable lounge chair",
      "price": 15
    },
    "sys": {
      "space": {
        "sys": {
          "type": "Link",
          "linkType": "Space",
          "id": "ti1zf61egylr"
        }
      },
      "id": "78o4nLrLrOqUuAQaiMmUy6",
      "type": "Entry",
      "createdAt": "2016-05-07T03:20:52.887Z",
      "updatedAt": "2016-05-07T03:20:52.887Z",
      "revision": 1,
      "contentType": {
        "sys": {
          "type": "Link",
          "linkType": "ContentType",
          "id": "product"
        }
      }
    }
  }, {
    "fields": {
      "name": "Coffee Table",
      "description": "It's a sturdy coffee table.",
      "price": 50
    },
    "sys": {
      "space": {
        "sys": {
          "type": "Link",
          "linkType": "Space",
          "id": "ti1zf61egylr"
        }
      },
      "id": "6tF2LfRmU0koWuUK2eQmqI",
      "type": "Entry",
      "createdAt": "2016-05-07T23:43:18.846Z",
      "updatedAt": "2016-05-07T23:43:18.846Z",
      "revision": 1,
      "contentType": {
        "sys": {
          "type": "Link",
          "linkType": "ContentType",
          "id": "product"
        }
      }
    }
  }]
}
```

#### `DELETE /entries`

Delete ALL entries and sync requests stored locally. This is a way of manually clearing out the local store to a pristine state.

##### Usage

*Example: Delete everything*

Request:

```
curl -X DELETE http://localhost:14567/api/entries
```

Response:

```
{ "status": "ok" }
```

## Limitations etc.

* No localization features are implemented; thus only a single locale is supported. A default locale can be set in `config.yml`.
* No authentication is provided.
* No content type support is provied. All entries in a space are pulled and synced.