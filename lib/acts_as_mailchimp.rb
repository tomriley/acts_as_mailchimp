require 'xmlrpc/client'
require 'hominid'
module Terra
  module Acts #:nodoc:
    module MailChimp #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_mailchimp(opts={})
          include Terra::Acts::MailChimp::InstanceMethods
          extend Terra::Acts::MailChimp::SingletonMethods
          write_inheritable_attribute :email_column,  opts[:email]  || 'email'
          write_inheritable_attribute :type_column,   opts[:type]   || 'email_type'
          write_inheritable_attribute :fname_column,  opts[:fname]  || 'first_name'
          write_inheritable_attribute :lname_column,  opts[:lname]  || 'last_name'
          class_inheritable_reader    :email_column
          class_inheritable_reader    :type_column
          class_inheritable_reader    :fname_column
          class_inheritable_reader    :lname_column
        end
      end

      module SingletonMethods
        # Add class methods here
      end

      module InstanceMethods
        
        # Add a user to a MailChimp mailing list
        def add_to_mailchimp(list_name)
          hominid ||= Hominid.new
          list_id ||= find_mailing_list(list_name)
          vars = {}
          vars.merge!({:FNAME => self[fname_column]}) if self.has_attribute?(fname_column)
          vars.merge!({:LNAME => self[lname_column]}) if self.has_attribute?(lname_column)
          hominid.subscribe(list_id["id"], self[email_column], vars, self[type_column])
        rescue
          false
        end
        
        # Remove a user from a MailChimp mailing list
        def remove_from_mailchimp(list_name)
          hominid ||= Hominid.new
          list_id ||= find_mailing_list(list_name)
          hominid.unsubscribe(list_id["id"], self[email_column])
        rescue
          false
        end
        
        # Update user information at MailChimp
        def update_mailchimp(list_name, current_email = self[email_column])
          hominid ||= Hominid.new
          list_id ||= find_mailing_list(list_name)
          vars = {}
          vars.merge!({:FNAME => self[fname_column]}) if self.has_attribute?(fname_column)
          vars.merge!({:LNAME => self[lname_column]}) if self.has_attribute?(lname_column)
          vars.merge!({:EMAIL => self[email_column]})
          hominid.update_member(list_id["id"], current_email, vars, self[type_column])
        rescue
          false
        end
        
        # Find a mailing list by name
        def find_mailing_list(list_name)
          hominid ||= Hominid.new
          mailing_lists ||= hominid.lists
          mailing_lists.find {|list| list["name"] == list_name} unless mailing_lists.nil?
        end
        
      end
    end
  end
end
