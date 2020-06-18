provider aws {
  region = "us-east-2"
  alias  = "a"
}

provider aws {
  region = "us-west-2"
  alias  = "b"
}

locals {
  key_path = "./key/key.pub"

  tags = {

  }
}
