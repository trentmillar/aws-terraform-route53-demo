variable vpcs {
  type = map
  default = {
    a = {
      cidr = "172.255.8.0/21"
      name = "r53-demo"
    }
    b = {
      cidr = "172.255.0.0/21"
      name = "r53-demo"
    }
  }
}
