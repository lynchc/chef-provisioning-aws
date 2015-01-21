require 'chef/provider/aws_provider'
require 'chef/provisioning/machine_spec'
require 'cheffish'

class Chef::Provider::AwsRoute53Rs < Chef::Provider::AwsProvider

    action :create do
        if existing_rs == nil
            converge_by "Creating new Route 53 RecordSet:#{new_resource.name}" do
                begin
                    #create_options
                    rrsets = r53.hosted_zones[new_resource.hosted_zone].rrsets
                    rrsets.create(new_resource.name, new_resource.type, new_resource.options)
                rescue => e
                    Chef::Application.fatal!("Error Creating RecordSet: #{e}")
                end
            end
        else
            new_resource.type existing_rs.type
            #new_resource.options existing_rs.options
        end
    end

    action :modify do
        if existing_rs == nil
            action_create
        else
            converge_by "Updating Route 53 Record Set #{new_resource.name}" do
                begin
                    #Chef::Log.warn(existing_rs.options != new_resource.options)
                    #if existing_rs.options != new_resource.options
                        ip = get_ip new_resource.machine, false
                        Chef::Log.warn(ip)
                        existing_rs.update(new_resource.options)
                    #end
                rescue => e
                    Chef::Application.fatal!("Error Modifying RecordSet: #{e}")
                end
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
        #remove this when chef-provisioning#242 is fixed
        new_resource.hydrate
        #if user didn't add suffix, add it
        if not new_resource.name.end_with? "."
            new_resource.name = new_resource.name + "."
        end
        @existing_rs ||= not(r53.hosted_zones[new_resource.hosted_zone].rrsets["#{new_resource.name}", "#{new_resource.type}"].exists?) ? nil : begin
        #if we find the id stored, we assume we know about this entry. Still, pull data only from aws and compare against what's being passed
        #@existing_rs ||= new_resource.id == nil ? nil : begin
            rs = r53.hosted_zones[new_resource.hosted_zone].rrsets["#{new_resource.name}", "#{new_resource.type}"]
            Chef::Log.warn(rs.ttl)
            rs
        rescue => e
            Chef::Application.fatal!("Error looking for EIP Address: #{e}")
            nil
        end
    end

    def get_ip(machine, public=true)
        begin
            spec = Chef::Provisioning::ChefMachineSpec.get(machine)
            if spec == nil
                Chef::Application.fatal!("Could not find machine #{machine}")
            else
                instance = ec2.instances[spec.location["instance_id"]]
                if instance.exists? #just making sure
                    ip = public ? instance.ip_address : instance.private_ip_address
                    ip
                else
                    Chef::Application.fatal!("Error. Machine #{machine} with instance_id #{spec.location["instance_id"]} cannot be found in EC2")
                end
            end
        rescue => e
            Chef::Application.fatal!("Error Finding Public IP for machine #{machine}: #{e}")
        end
    end
end
