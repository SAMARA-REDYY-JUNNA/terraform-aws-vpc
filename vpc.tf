resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    instance_tenancy = "default"
    enable_dns_hostnames = var.enable_dns_hostnames

    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name
        }
    )
    }

    resource "aws_internet_gateway" "gw" {
        vpc_id = aws_vpc.main.id

        tags = merge(
            var.common_tags,
            var.igw_tags,
            {
                Name = local.resource_name
            }
        )

        }

    ## public subnet creation ####
    resource "aws_subnet" "public" {
        count = length(var.public_subnet_cidr)
        availability_zone = local.az_names[count.index]
        map_public_ip_on_launch = true
        vpc_id = aws_vpc.main.id
        cidr_block = var.public_subnet_cidr[count.index]

        tags = merge(
            var.common_tags,
            var.public_subnet_cidr_tags,
            {
                Name = "${local.resource_name}-public-${local.az_names[count.index]}"
            }
        )
    }

    ## private subnet creation ####
     resource "aws_subnet" "private" {
        count = length(var.private_subnet_cidr)
        availability_zone = local.az_names[count.index]
        vpc_id = aws_vpc.main.id
        cidr_block = var.private_subnet_cidr[count.index]

        tags = merge(
            var.common_tags,
            var.private_subnet_cidr_tags,
            {
                Name = "${local.resource_name}-private-${local.az_names[count.index]}"
            }
        )
    }

    ## database subnet creation ####
     resource "aws_subnet" "database" {
        count = length(var.database_subnet_cidr)
        availability_zone = local.az_names[count.index]
        vpc_id = aws_vpc.main.id
        cidr_block = var.database_subnet_cidr[count.index]

        tags = merge(
            var.common_tags,
            var.database_subnet_cidr_tags,
            {
                Name = "${local.resource_name}-database-${local.az_names[count.index]}"
            }
        )
    }

    resource "aws_db_subnet_group" "default" {
        name = "${local.resource_name}"
        subnet_ids = aws_subnet.database[*].id

        tags = merge (
            var.common_tags,
            var.database_subnet_group_tags,
            {
                Name = "${local.resource_name}"
            }
        )
    }

    resource "aws_eip" "nat" {
        domain = "vpc"
    }

    resource "aws_nat_gateway" "nat" {
        allocation_id = aws_eip.nat.id
        subnet_id = aws_subnet.public[0].id

        tags = merge(
            var.common_tags,
            var.nat_gateway,
            {
                Name = "${local.resource_name}"
            }
        )

        depends_on = [ aws_internet_gateway.gw ]
    }

    ### public route table creation ####
    resource "aws_route_table" "public" {
        vpc_id = aws_vpc.main.id

        tags = merge(
            var.common_tags,
            var.public_route_table_tags,
            {
                Name = "${local.resource_name}-public"
            }
        )
    }

    ### private route table creation ####
    resource "aws_route_table" "private" {
        vpc_id = aws_vpc.main.id

        tags = merge(
            var.common_tags,
            var.private_route_table_tags,
            {
                Name = "${local.resource_name}-private"
            }
        )
    }

    ### database route table creation ####
    resource "aws_route_table" "database" {
        vpc_id = aws_vpc.main.id

        tags = merge(
            var.common_tags,
            var.database_route_table_tags,
            {
                Name = "${local.resource_name}-database"
            }
        )
    }


    ### routes creation ####
    resource "aws_route" "public_route" {
        route_table_id = aws_route_table.public.id
        destination_cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    resource "aws_route" "private_route" {
        route_table_id = aws_route_table.private.id
        destination_cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    resource "aws_route" "database_route" {
        route_table_id = aws_route_table.database.id
        destination_cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    ### public subnet association ####
    resource "aws_route_table_association" "public" {
        count = length(var.public_subnet_cidr)
        subnet_id = element(aws_subnet.public[*].id, count.index)
        route_table_id = aws_route_table.public.id
    }

    ### private subnet association ####
    resource "aws_route_table_association" "private" {
        count = length(var.private_subnet_cidr)
        subnet_id = element(aws_subnet.private[*].id, count.index)
        route_table_id = aws_route_table.private.id
    }

    ### database subnet association ####
    resource "aws_route_table_association" "database" {
        count = length(var.database_subnet_cidr)
        subnet_id = element(aws_subnet.database[*].id, count.index)
        route_table_id = aws_route_table.database.id
    }