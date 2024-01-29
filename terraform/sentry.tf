data "sentry_organization" "this" {
  slug = "dandiarchive"
}

data "sentry_team" "this" {
  organization = data.sentry_organization.this.id
  slug         = "dandidevs"
}

data "sentry_project" "this" {
  organization = data.sentry_organization.this.id
  slug         = "dandi-api"
}

data "sentry_key" "this" {
  organization = data.sentry_organization.this.id
  project      = data.sentry_project.this.id
}
