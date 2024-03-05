resource "heroku_app" "webdav" {
  name   = "dandidav"
  region = "us"
  acm    = true

  organization {
    name = data.heroku_team.dandi.name
  }

  buildpacks = [
    "https://buildpack-registry.s3.amazonaws.com/buildpacks/emk/rust.tgz"
  ]
}

resource "heroku_formation" "webdav_heroku_web" {
  app_id   = heroku_app.webdav.id
  type     = "web"
  size     = "basic"
  quantity = 1
}

# Enable this feature so that the Rust application can access the git commit hash.
resource "heroku_app_feature" "webdav_runtime_dyno_metadata" {
  app_id = heroku_app.webdav.id
  name   = "runtime-dyno-metadata"
}

resource "heroku_domain" "webdav" {
  app_id   = heroku_app.webdav.id
  hostname = "webdav.dandiarchive.org"
}

resource "aws_route53_record" "heroku" {
  zone_id = aws_route53_zone.dandi.zone_id
  name    = "webdav"
  type    = "CNAME"
  ttl     = "300"
  records = [heroku_domain.webdav.cname]
}
