module ActiveAdmin

  #
  # The Active Admin DSL. This class is where all the registration blocks
  # are instance eval'd. This is the central place for the API given to 
  # users of Active Admin
  #
  class DSL

    def initialize(config)
      @config = config
    end

    # Runs the registration block inside this object
    def run_registration_block(&block)
      instance_eval &block if block_given?
    end

    # The instance of ActiveAdmin::Config that's being registered
    # currently. You can use this within your registration blocks to
    # modify options:
    #
    # eg:
    # 
    #   ActiveAdmin.register Post do
    #     config.sort_order = "id_desc"
    #   end
    #
    def config
      @config
    end

    # Include a module with this resource. The modules's `included` method
    # is called with the instance of the `ActiveAdmin::DSL` passed into it.
    #
    # eg:
    #
    #   module HelpSidebar
    #
    #     def self.included(dsl)
    #       dsl.sidebar "Help" do
    #         "Call us for Help"
    #       end
    #     end
    #
    #   end
    #
    #   ActiveAdmin.register Post do
    #     include HelpSidebar
    #   end
    #
    # @param [Module] mod A module to include
    #
    # @returns [Nil]
    def include(mod)
      mod.included(self)
    end

    # Returns the controller for this resource. If you pass a
    # block, it will be eval'd in the controller
    #
    # Example:
    #
    #   ActiveAdmin.register Post do
    #
    #     controller do
    #       def some_method_on_controller
    #         # Method gets added to Admin::PostsController
    #       end
    #     end
    #
    #   end
    #
    def controller(&block)
      @config.controller.class_eval(&block) if block_given?
      @config.controller
    end

    # Add a new action item to the resource
    #
    # @param [Hash] options valid keys include:
    #                 :only:  A single or array of controller actions to display
    #                         this action item on.
    #                 :except: A single or array of controller actions not to
    #                          display this action item on.
    def action_item(options = {}, &block)
      config.add_action_item(options, &block)
    end
    
    # Add a new batch action item to the resource
    # Provide a symbol/string to register the action, options, & block to execute on request
    # 
    # To unregister an existing action, just provide the symbol & pass false as the second param
    #
    # @param [Symbol or String] title
    # @param [Hash] options valid keys include:
    # => :if is a proc that will be called to determine if the BatchAction should be displayed
    # => :sort_order is used to sort the batch actions ascending
    # => :confirm is a string which the user will have to accept in order to process the action
    #
    def batch_action(title, options = {}, &block)
      
      # Create symbol & title information
      if title.is_a?( String )
        sym = title.titleize.gsub(' ', '').underscore.to_sym
      else
        sym = title
        title = sym.to_s.titleize
      end
      
      # Either add/remove the batch action
      unless options == false
        config.add_batch_action( sym, title, options, &block )
      else
        config.remove_batch_action sym
      end
      
    end

    def menu(options = {})
      config.menu(options)
    end

    def sidebar(name, options = {}, &block)
      config.sidebar_sections << ActiveAdmin::SidebarSection.new(name, options, &block)
    end

    def decorate_with(decorator_class)
      # Force storage as a string. This will help us with reloading issues.
      # Assuming decorator_class.to_s will return the name of the class allows
      # us to handle a string or a class.
      config.decorator_class_name = "::#{ decorator_class }"
    end
  end
end
