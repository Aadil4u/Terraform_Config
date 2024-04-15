module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = "myapp-eks-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  vpc_id     = module.myapp-vpc.default_vpc_id
  subnet_ids = module.myapp-vpc.private_subnets


  eks_managed_node_groups = {
    dev = {
      min_size     = 1
      max_size     = 3
      desired_size = 3

      instance_types = ["t2.small"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

}
