data "sentry_organization" "this" {
  slug = "sandbox-dandi"
}

data "sentry_team" "this" {
  organization = data.sentry_organization.this.id
  slug         = "sandbox-dandi-devs"
}

data "sentry_project" "this" {
  organization = data.sentry_organization.this.id
  slug         = "sandbox-dandi-api"
}

data "sentry_key" "this" {
  organization = data.sentry_organization.this.id
  project      = data.sentry_project.this.id
}
