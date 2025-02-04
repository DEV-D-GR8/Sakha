output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "api_gateway_endpoint" {
  description = "API Gateway endpoint (if created)"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
