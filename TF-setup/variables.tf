variable "home_ip" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "public_key_path" {
  type    = string
  default = "~/.ssh/test_vm_key.pub"
}
