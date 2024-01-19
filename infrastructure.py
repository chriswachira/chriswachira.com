from diagrams import Diagram, Edge, Cluster
from diagrams.aws.network import CloudFront
from diagrams.aws.storage import S3
from diagrams.aws.network import Route53
from diagrams.aws.general import Users
from diagrams.onprem.vcs import Github

graph_attr = {
    "pad": "0.5"
}

with Diagram(
        "chriswachira.com Infrastructure",
        outformat="png",
        filename="assets/infrastructure",
        graph_attr=graph_attr,
        show=False
):
    users = Users("Users")

    with Cluster("AWS VPC"):
        aws_services = [
            Route53("\nAmazon\nRoute53"),
            CloudFront("\nAmazon\nCloudFront"),
            S3("\nAmazon S3")
        ]
        
    route53 = aws_services[0]
    cloudfront = aws_services[1]
    s3_bucket  = aws_services[2]

    github = Github("\nGitHub\nActions")

    # Users' browsers querying the chriswachira.com domain DNS from Route 53
    users >> Edge(label="chriswachira.com") >> route53

    # An alias A record on Route 53 mapped to CloudFront distribution's domain
    route53 >> Edge(label="alias A record") >> cloudfront

    # S3 bucket acting as the origin for the CloudFront distribution
    cloudfront << Edge(label="S3 bucket origin") << s3_bucket

    # Website files pushed from GitHub Actions to S3 bucket
    s3_bucket << Edge(label="website static files") << github
