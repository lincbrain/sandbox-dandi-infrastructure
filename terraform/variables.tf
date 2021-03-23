variable "girder_api_key" {
  type        = string
  description = "The API key on Girder, to be used by the Publish app."
}
variable "doi_api_password" {
  type        = string
  description = "The password for the Datacite API, used to mint new DOIs during publish."
}
