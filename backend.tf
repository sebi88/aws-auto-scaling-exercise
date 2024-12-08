terraform {
  backend "remote" {
    organization = "sebi_private"

    workspaces {
      name = "auto-scaling-exercise"
    }
  }
}