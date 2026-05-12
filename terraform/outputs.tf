output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "rds_endpoint" {
  value = aws_db_instance.mariadb.address
}

output "rds_port" {
  value = aws_db_instance.mariadb.port
}
