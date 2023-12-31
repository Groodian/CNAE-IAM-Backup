variable "GROUP_ACCESS_TOKEN" {
  description = "Value of $GROUP_ACCESS_TOKEN from gitlab-ci"
  type        = string
}

variable "GROUP_ACCESS_TOKEN_USERNAME" {
  description = "Value of $GROUP_ACCESS_TOKEN_USERNAME from gitlab-ci"
  type        = string
}

variable "MICROSERVICE_NAME" {
  description = "Deployment name of microservice"
  type        = string
}

data "terraform_remote_state" "infrastructure_state" {
  backend = "http"

  config = {
    address  = "https://code.fbi.h-da.de/api/v4/projects/29127/terraform/state/aws_infrastructure_state"
    username = "${var.GROUP_ACCESS_TOKEN_USERNAME}"
    password = "${var.GROUP_ACCESS_TOKEN}"
  }
}

# Retrieve information about an EKS Cluster.
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.infrastructure_state.outputs.cluster_name
}

# Get an authentication token to communicate with an EKS cluster.
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.infrastructure_state.outputs.cluster_name
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "${var.MICROSERVICE_NAME}-deployment"
    labels = {
      app = var.MICROSERVICE_NAME
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = var.MICROSERVICE_NAME
      }
    }
    template {
      metadata {
        labels = {
          app = var.MICROSERVICE_NAME
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = var.MICROSERVICE_NAME

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "${var.MICROSERVICE_NAME}-service"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.app
    }
    port {
      node_port   = 30201
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

# api gateway integration
data "aws_lb" "nginx" {
  name       = split("-", kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].hostname)[0]
  depends_on = [kubernetes_service.nginx]
}

data "aws_lb_listener" "nginx" {
  load_balancer_arn = data.aws_lb.nginx.arn
  port              = 80
}

resource "aws_apigatewayv2_integration" "nginx" {
  api_id             = aws_apigatewayv2_api.cnae_gateway.id
  integration_uri    = data.aws_lb_listener.nginx.arn
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.eks_link.id
  request_parameters = {
    "overwrite:path" = "/$request.path.proxy"
  }
}

resource "aws_apigatewayv2_route" "nginx" {
  api_id             = aws_apigatewayv2_api.cnae_gateway.id
  route_key          = "ANY /${var.MICROSERVICE_NAME}/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.nginx.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cnae_auth.id
}
