terraform {
  required_providers {
    hashicups = {
      version = "0.3.3"
      source  = "hashicorp.com/edu/hashicups"
    }
  }
}

provider "hashicups" {
  username = "education"
  password = "test123"
  host = "http://docker_compose_api_1:9090"
}

resource "hashicups_order" "edu" {
  items {
    coffee {
      id = 3
    }
    quantity = 3
  }
  items {
    coffee {
      id = 2
    }
    quantity = 1
  }
}
data "hashicups_ingredients" "first_coffee" {
  coffee_id = hashicups_order.edu.items[0].coffee[0].id
}

data "hashicups_ingredients" "second_coffee" {
  coffee_id = hashicups_order.edu.items[1].coffee[0].id
}

output "first_coffee_ingredients" {
  value = data.hashicups_ingredients.first_coffee
}

output "second_coffee_ingredients" {
  value = data.hashicups_ingredients.second_coffee
}

output "edu_order" {
  value = hashicups_order.edu
}
