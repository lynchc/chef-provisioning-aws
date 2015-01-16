require 'chef/provider/aws_provider'
require 'chef/provisioning/machine_spec'
require 'cheffish'

class Chef::Provider::AwsR53RecordSet < Chef::Provider::AwsProvider

  action :create do
    if existing_rs == nil
        converge_by "Creating new Route 53 RecordSet:#{new_resource.name}" do
            begin
                rrsets = r53.HostedZone.new(new_resource.hosted_zone).rrsets
                rrsets.create(new_resource.name, new_resource.type, new_resource.options) #:ttl => 300, :resource_records => [{:value => '127.0.0.1'}])
            rescue => e
                Chef::Application.fatal!("Error Creating RecordSet: #{e}")
            end
        end
    else
        new_resource.type = existing_rs.type
        new_resource.options = existing_rs.options
    end
  end

  action :modify do
    if existing_rs == nil
        action_create
    else
        begin
            existing_rs.update(new_resource.options)
        rescue => e
            Chef::Application.fatal!("Error Modifying RecordSet: #{e}")
        end
    end
  end

  action :delete do
    if existing_rs
      converge_by "Deleting Route 53 Record Set #{new_resource.name}" do
        existing_rs.delete
      end
    end
  end

  def existing_rs
    #if user didn't add suffix, add it
    if not new_resource.name.end_with? "."
        new_resource.name = new_resource.name + "."
    end
    @existing_rs ||= r53.HostedZone.new(new_resource.hosted_zone).rrsets["#{new_resource.name}", "#{new_resource.type}"]== nil ? nil : begin
    r53.HostedZone.new(new_resource.hosted_zone).rrsets["#{new_resource.name}", "#{new_resource.type}"]
    rescue => e
      Chef::Application.fatal!("Error looking for EIP Address: #{e}")
      nil
    end
  end
end
