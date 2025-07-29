package main

import (
	"github.com/pulumi/pulumi-aws/sdk/v7/go/aws/ec2"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		cfg := config.New(ctx, "")       // Default namespace
		awsCfg := config.New(ctx, "aws") // AWS namespace
		awsRegion := awsCfg.Require("region")
		sshPublicKey := cfg.Require("sshPublicKey")

		// These values are set in the `Pulumi.<namespace>.yaml` file
		type NetworkConfig struct {
			SSHIngressPort   int      `json:"sshIngressPort"`
			SSHIngressCidrs  []string `json:"sshIngressCidrs"`
			HTTPIngressCidrs []string `json:"httpIngressCidrs"`
		}

		var netCfg NetworkConfig
		cfg.RequireSecretObject("networkConfig", &netCfg)

		tags := pulumi.StringMap{
			"Name": pulumi.String("dev-env"),
		}

		// Create VPC
		vpc, err := ec2.NewVpc(ctx, "main-vpc", &ec2.VpcArgs{
			CidrBlock: pulumi.String("10.0.0.0/16"),
			Tags: pulumi.StringMap{
				"Name": pulumi.String("dev-env"),
			},
		})
		if err != nil {
			return err
		}

		// Create Internet Gateway
		igw, err := ec2.NewInternetGateway(ctx, "main-igw", &ec2.InternetGatewayArgs{
			VpcId: vpc.ID(),
			Tags:  tags,
		})
		if err != nil {
			return err
		}

		// Create public subnet
		publicSubnet, err := ec2.NewSubnet(ctx, "public-subnet", &ec2.SubnetArgs{
			VpcId:               vpc.ID(),
			CidrBlock:           pulumi.String("10.0.1.0/24"),
			AvailabilityZone:    pulumi.String(awsRegion + "a"),
			MapPublicIpOnLaunch: pulumi.Bool(true),
			Tags:                tags,
		})
		if err != nil {
			return err
		}

		// Create route table for public subnet
		publicRouteTable, err := ec2.NewRouteTable(ctx, "public-rt", &ec2.RouteTableArgs{
			VpcId: vpc.ID(),
			Tags:  tags,
		})
		if err != nil {
			return err
		}

		// Create route to internet gateway
		_, err = ec2.NewRoute(ctx, "public-route", &ec2.RouteArgs{
			RouteTableId:         publicRouteTable.ID(),
			DestinationCidrBlock: pulumi.String("0.0.0.0/0"),
			GatewayId:            igw.ID(),
		})
		if err != nil {
			return err
		}

		// Associate route table with public subnet
		_, err = ec2.NewRouteTableAssociation(ctx, "public-rta", &ec2.RouteTableAssociationArgs{
			SubnetId:     publicSubnet.ID(),
			RouteTableId: publicRouteTable.ID(),
		})
		if err != nil {
			return err
		}

		// Create security group
		securityGroup, err := ec2.NewSecurityGroup(ctx, "dev-env-sg", &ec2.SecurityGroupArgs{
			Name:        pulumi.String("dev-env-security-group"),
			Description: pulumi.String("Security group for development server"),
			VpcId:       vpc.ID(),

			// Ingress rules
			Ingress: ec2.SecurityGroupIngressArray{
				// SSH access (restrict source IP as needed)
				&ec2.SecurityGroupIngressArgs{
					Description: pulumi.String("SSH"),
					FromPort:    pulumi.Int(netCfg.SSHIngressPort),
					ToPort:      pulumi.Int(netCfg.SSHIngressPort),
					Protocol:    pulumi.String("tcp"),
					CidrBlocks:  pulumi.ToStringArray(netCfg.SSHIngressCidrs),
				},
				// Jaeger access
				&ec2.SecurityGroupIngressArgs{
					Description: pulumi.String("HTTP"),
					FromPort:    pulumi.Int(16686),
					ToPort:      pulumi.Int(16686),
					Protocol:    pulumi.String("tcp"),
					CidrBlocks:  pulumi.ToStringArray(netCfg.HTTPIngressCidrs),
				},
				// Prometheus access
				&ec2.SecurityGroupIngressArgs{
					Description: pulumi.String("HTTP"),
					FromPort:    pulumi.Int(9090),
					ToPort:      pulumi.Int(9090),
					Protocol:    pulumi.String("tcp"),
					CidrBlocks:  pulumi.ToStringArray(netCfg.HTTPIngressCidrs),
				},
				// Grafana access
				&ec2.SecurityGroupIngressArgs{
					Description: pulumi.String("HTTP"),
					FromPort:    pulumi.Int(5050),
					ToPort:      pulumi.Int(5050),
					Protocol:    pulumi.String("tcp"),
					CidrBlocks:  pulumi.ToStringArray(netCfg.HTTPIngressCidrs),
				},
			},

			// Egress rules (allow all outbound traffic)
			Egress: ec2.SecurityGroupEgressArray{
				&ec2.SecurityGroupEgressArgs{
					FromPort:   pulumi.Int(0),
					ToPort:     pulumi.Int(0),
					Protocol:   pulumi.String("-1"),
					CidrBlocks: pulumi.StringArray{pulumi.String("0.0.0.0/0")},
				},
			},

			Tags: tags,
		})
		if err != nil {
			return err
		}

		// Use Fedora 42
		amiResult, err := ec2.LookupAmi(ctx, &ec2.LookupAmiArgs{
			MostRecent: pulumi.BoolRef(true),
			Owners:     []string{"125523088429"}, // Fedora
			Filters: []ec2.GetAmiFilter{
				{
					Name:   "name",
					Values: []string{"Fedora-Cloud-Base-AmazonEC2.x86_64-42-2025*"}, // Latest version of Fedora 42
				},
				{
					Name:   "state",
					Values: []string{"available"},
				},
			},
		})
		if err != nil {
			return err
		}

		// Create key pair (you should create this beforehand or import existing one)
		keyPair, err := ec2.NewKeyPair(ctx, "dev-env", &ec2.KeyPairArgs{
			KeyName:   pulumi.String("dev-env"),
			PublicKey: pulumi.String(sshPublicKey),
			Tags:      tags,
		})
		if err != nil {
			return err
		}

		// Create EC2 instance
		instance, err := ec2.NewInstance(ctx, "dev-env", &ec2.InstanceArgs{
			InstanceType:        pulumi.String("c5a.4xlarge"), // AMD: 16 vCPU 32GiB Memory
			Ami:                 pulumi.String(amiResult.Id),
			KeyName:             keyPair.KeyName,
			VpcSecurityGroupIds: pulumi.StringArray{securityGroup.ID()},
			SubnetId:            publicSubnet.ID(),
			RootBlockDevice: &ec2.InstanceRootBlockDeviceArgs{
				VolumeType:          pulumi.String("gp3"),
				VolumeSize:          pulumi.Int(50),
				DeleteOnTermination: pulumi.Bool(true),
				Encrypted:           pulumi.Bool(true),
				Tags:                tags,
			},
			Tags: tags,
		})
		if err != nil {
			return err
		}

		ctx.Export("instanceId", instance.ID())
		ctx.Export("instancePublicIp", instance.PublicIp)

		return nil
	})
}
