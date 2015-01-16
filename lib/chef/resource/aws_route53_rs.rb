require 'chef/resource/aws_resource'
require 'chef/provisioning/aws_driver'
require 'chef/provisioning/machine_spec'

class Chef::Resource::AwsR53RecordSet < Chef::Resource::AwsResource
  self.resource_name = 'aws_r53_recordset'
#  self.databag_name = 'r53_recordsets'

  actions :create, :delete, :modify
  default_action :modify

#  stored_attribute :public_ip
#  stored_attribute :domain

  attribute :name, :kind_of => String, :name_attribute => true
  attribute :hosted_zone, :kind_of => String
  attribute :type, :kind_of => String
  attribute :options, :kind_of => Hash

  def initialize(*args)
    super
  end

  def after_created
    super
  end


end
