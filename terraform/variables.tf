variable "doi_api_password" {
  type        = string
  description = "The password for the Datacite API, used to mint new DOIs during publish."
  default     = "doi_api_password"
}

variable "test_doi_api_password" {
  type        = string
  description = "The password for the Datacite Test API, used to mint new DOIs on staging during publish."
  default     = "doi_api_password"
}

variable "dev_email" {
  type        = string
  description = "The core developer email list."
  default     = "dev_email@devemail.com"
}
