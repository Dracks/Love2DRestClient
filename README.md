Love2DRestClient
================

Love2D Rest asyncronous client

Is a really young library, but it's a http rest asyncronous.

Usage
=====
  * Configure the url to request, and type of action to pass. 
  * Call to Request:update to refresh the job queue, and call Request:quit to end correctly the background thread
  * Call to Request:async(...) to add a new request to the queue.