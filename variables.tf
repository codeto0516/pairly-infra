variable "name" {
  description = "リソース名"
  type        = string
}
variable "region" {
  description = "リージョン名"
  type        = string
}

variable "route53" {
  type        = object({
    domain    = string
    zone_id   = string
  })
}

variable "rds" {
  type        = object({
    db_name   = string
    username  = string
    password  = string
  })
}

