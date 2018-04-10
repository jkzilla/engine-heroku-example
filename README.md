# Apollo Engine + Heroku
An example of how to deploy the Engine Proxy as a standalone container on Heroku, to run it in front of a GraphQL server hosted elsewhere (eg, on Amazon Lambda).  This guide assumes you already have a working Docker installation and have installed the Heroku CLI tools.

**These instructions aren't how you run a Node GraphQL server on Heroku with Engine built-in.** You don't need to do anything extra to do that: just follow the [basic Node Engine setup instructions](https://www.apollographql.com/docs/engine/setup-node.html): they work great with Engine with no extra config.  This is specifically about using Heroku to run a stand-alone Engine proxy.

## Setup
First, clone the example repo.
```
git clone git@github.com:apollographql/engine-heroku-example.git
cd engine-heroku-example
```

Then edit the `config-template.json` file with the configuration specific to your environment and include your API key. Be sure to rename it `config.json` so that the DockerFile will find it.
Note that `origins.http.overrideRequestHeaders.Host` MUST also be set to the origin hostname so Heroku's virtual hosting system can properly route to the origin.  If you leave out this override, Engine proxy will end up in a circular connection loop and eventually crash.

Heroku requires support for runtime configuration of the port that Engine listens on.  This is exposed to the container via the $PORT environment variable.  For this reason, it's important to set `portFromEnv` to be "PORT" and to NOT set the `port` variable in your `frontend`.

## Deployment
Next, login to Heroku's container registry:
```
heroku container:login
```

Now you can build and push your image to Heroku.  In the boilerplate below, replace `<engine-app-name>` with the name of the Heroku app that you'd like to deploy into.  Note: you will need to create another app to run Engine that is separate from your origin GraphQL API app.

```
## build the image
docker build . -t registry.heroku.com/<engine-app-name>/web
```

Optional: run the container locally and test it out.  Using curl, you can send an introspection query to the origin server using your locally running Engine as a proxy.
```
## run the container
docker run -it --rm -e PORT=3000 -e API_KEY=<your-api-key> -p 3000:3000 registry.heroku.com/<engine-app-name>/web

## send an introspection query to port 3000 (mapped above)
curl -X POST -H 'Content-Type:application/json'  -d '{"query": "{__schema { queryType { name, fields { name, description} }}}"}' http://localhost:3000/graphql
```

Finally, we can now push the image to Heroku's container registery, which will deploy it to your app.
```
docker push registry.heroku.com/<engine-app-name>/web
```

That's it!

For further reading, explore the [official documentation](https://devcenter.heroku.com/articles/container-registry-and-runtime) on using containers inside Heroku.
