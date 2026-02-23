# Klaxon sandbox

This repo contains snapshots of real web pages we can use to test the Klaxon extension.

Pages here are downloaded using the `fetch-page.sh` script. Download a new page like this:

```sh
./fetch-page https://www.roslindale.net/vacancies roslindale-vacancies
```

That will create a directory called `roslindale-vacancies` with all necessary files to serve the page.

Serve locally using [`serve`](https://www.npmjs.com/package/serve) or [`python -m http.server`](https://docs.python.org/3/library/http.server.html#command-line-interface).
