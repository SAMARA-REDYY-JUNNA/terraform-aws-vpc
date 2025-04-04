resource "aws_vpc_peering_connection" "peering" {
    count = var.is_peering_required ? 1 : 0
    vpc_id = aws_vpc.main.id #requster vpc
    peer_vpc_id = var.acceptor_vpc_id == "" ? data.aws_vpc.default.id : var.acceptor_vpc_id #acceptor vpc
    auto_accept = var.acceptor_vpc_id == "" ? true : false #if acceptor vpc is not provided, then auto accept the peering connection
    tags = merge(
        var.common_tags,
        var.vpc_peering_tags,
        {
            Name = "${local.resource_name}" #expense-dev
        } 
    )
}

# count is useful to control when resource is required
resource "aws_route" "public_peeting" {
        count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
        route_table_id = aws_route_table.public.id
        destination_cidr_block = data.aws_vpc.default.cidr_block
        vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
    }

    resource "aws_route" "private_peering" {
        count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
        route_table_id = aws_route_table.private.id
        destination_cidr_block = data.aws_vpc.default.cidr_block
        vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
    }

     resource "aws_route" "database_peerig" {
        count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
        route_table_id = aws_route_table.database.id
        destination_cidr_block = data.aws_vpc.default.cidr_block
        vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
    }

     resource "aws_route" "default_peerig" {
        count = var.is_peering_required && var.acceptor_vpc_id == "" ? 1 : 0
        route_table_id = data.aws_route_table.main.id
        destination_cidr_block = var.vpc_cidr
        vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
    }

