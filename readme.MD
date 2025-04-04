# custom AWS VPC Module

This module is developed of joindevops.com. we are creating following resources. This module creats resources in forst AZ for HA

* VPC
* Internet Gateway
* Internet and VPC attachment
* 2 public subnets
* 2 private subnets
* 2 database subnets
* EIP
* NAT Gateway
* public route table
* private route table
* Database route table
* Route table association
* Routes in all tables
* Peering if requried for user
* Routes of peering in requster and acceptor VPC.
* Database subnet group

### Inputs
* Project_name (required): User should mention their project name.
* environment (optional): Default value is dev. Type is string
* common_tags (required): Users should provide their tags related to their project. Type is map.
* vpc_cidr(optional): Default value is 10.0.0.0/16. Type is string
* enable_dns_hostnames(optional): Default value is true. Type is bool
* vpc_tags (optional): Default value is empty. Type is map.
* igw_tags (optional): Default value is empty. Type is map.
* public_subnet_cidrs (Required): User has to provide 2 valid subnet CIDR.
* public_subnet_cidr_tags(optional): Default value is empty. Type is map.
* private_subnet_cidrs (Required): User has to provide 2 valid subnet CIDR.
* private_subnet_cidr_tags(optional): Default value is empty. Type is map.
* database_subnet_cidrs (Required): User has to provide 2 valid subnet CIDR.
* databse_subnet_cidr_tags(optional): Default value is empty. Type is map.
* database_subnet_group_tags (optional): default value is empty. Type is map.
nat_gateway_tags(optional): Default value is empty. Type is map.
* public_route_table_tags (optional): Default value is empty. Type is map.
* private_route_table_tags (optional): Default value is empty. Type is map.
* databse_route_table_tags (optional): Default value is empty. Type is map.
* is-peering_required(optional): Default value is false. Type is bool.
* acceptor_vpc_id(optional): Default is empty. Default VPC ID would be taken. Type is string.
* vpc_peering_tags(optional): Default value is empty. Type is map.



