require 'chef/resource/aws_resource'
require 'chef/provider/aws_provider'
require 'chef/provisioning/aws_driver'
require 'chef/provisioning/machine_spec'

class Chef::Resource::AwsRoute53Rs < Chef::Resource::AwsResource

    self.resource_name = 'aws_route53_rs'
    #self.databag_name = 'r53_recordsets'

    actions :create, :delete, :modify
    default_action :modify

    #stored_attribute :id, :kind_of => String, :name_attribute => true

    attribute :name, :kind_of => String, :name_attribute => true

    attribute :hosted_zone, :kind_of => String
    attribute :type, :kind_of => String
    attribute :raw_options, :kind_of => Hash
    attribute :alias_target, :kind_of => Hash
    attribute :ttl, :kind_of => Integer
    attribute :weight, :kind_of => Integer
    attribute :use_public_ip, :kind_of =>[TrueClass, FalseClass], :default => true
    attribute :machines
    attribute :addresses

    def initialize(*args)
        super
    end

    def after_created
        super
    end
end
