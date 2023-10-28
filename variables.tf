variable "vpc_cidr_block" {
    type = string
    description = "cidr block for the main vpc"
    default = "10.0.0.0/16"
}

variable "web_subnet" {
    type = string
    description = "cidr block for the web subnet"
    default = "10.0.10.0/24"
}

variable "subnet_zone" {
    type = string
    description = "availability zone for subnet zone"
    # subnet_zone was set as environment variable
}


variable "main_vpc_name" {
    type = string
    description = "name of the main vpc"
}