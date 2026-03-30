# sample is the resource name,
# like a variable name, it is an arbitrary name that you choose,
# which is used to reference this resource in other parts of the configuration.
resource "local_file" "sample" {
  content  = "Hello Terraform!!! :)"
  filename = "${path.module}/sample.txt"
}