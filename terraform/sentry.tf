data "sentry_organization" "this" {
  slug = "mit-m3"
}

data "sentry_team" "this" {
  organization = data.sentry_organization.this.id
  slug         = "mit"
}

data "sentry_project" "this" {
  organization = data.sentry_organization.this.id
  slug         = "sandbox-dandi"
}

data "sentry_key" "this" {
  organization = data.sentry_organization.this.id
  project      = data.sentry_project.this.id
}
