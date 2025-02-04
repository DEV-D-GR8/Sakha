variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "sakha"
}

variable "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "database_url" {
  description = "Database URL for Django"
  type        = string
}

variable "redis_url" {
  description = "Redis URL for caching"
  type        = string
}

variable "firebase_credentials" {
  description = "Firebase credentials JSON string or file path"
  type        = string
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
}

variable "pinecone_api_key" {
  description = "Pinecone API key"
  type        = string
}

variable "pinecone_env" {
  description = "Pinecone environment"
  type        = string
}

variable "secret_key" {
  description = "Django secret key"
  type        = string
}
