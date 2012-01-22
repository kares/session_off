module SessionOff

  def self.included(base)
    base.class_eval do
      
      extend ClassMethods
      
      if instance_methods(false).include?('session_enabled?')
        # remove the "deprecation" Rails 2.3 (can't override) :
        remove_method 'session_enabled?'
      end
      if instance_methods(false).include?('reset_session')
        # we'll have our own that respects session_enabled?
        # Rails 2.3 has this method in ActionController::Base
        remove_method 'reset_session'
      end
      # attr_internal on ActionController::Base for Rails 2.3.x
      # 3+ : `delegate :session, :to => "@_request"` from Metal
      clazz = self
      while clazz && ! clazz.instance_methods(false).include?('session')
        clazz = clazz.superclass
      end
      clazz.send(:remove_method, :'session') if clazz
      
      include InstanceMethods

      alias_method_chain(:process, :session_off)
      # yet another Rails 2.3 specific hook :
      alias_method_chain(:assign_shortcuts, :session_off) rescue NameError
      
    end
  end

  module ClassMethods

    def self.extended(base)
      return if base.respond_to?(:session_options_array)
      if base.respond_to?(:class_attribute)
        base.class_attribute :session_options_array, 
                             :instance_reader => false, :instance_writer => false
      else
        base.class_eval do
          def session_options_array
            read_inheritable_attribute(:session_options)
          end
          def session_options_array=(array)
            write_inheritable_array(:session_options, array)
          end
        end
      end
    end
    
    # Specify how sessions ought to be managed for a subset of the actions on
    # the controller. Like filters, you can specify <tt>:only</tt> and
    # <tt>:except</tt> clauses to restrict the subset, otherwise options
    # apply to all actions on this controller.
    #
    # The session options are inheritable, as well, so if you specify them in
    # a parent controller, they apply to controllers that extend the parent.
    #
    # Usage:
    #
    #   # turn off session management for all actions.
    #   session :off
    #
    #   # turn off session management for all actions _except_ foo and bar.
    #   session :off, :except => %w(foo bar)
    #
    #   # turn off session management for only the foo and bar actions.
    #   session :off, :only => %w(foo bar)
    #
    #   # the session will only work over HTTPS, but only for the foo action
    #   session :only => :foo, :session_secure => true
    #
    #   # the session by default uses HttpOnly sessions for security reasons.
    #   # this can be switched off.
    #   session :only => :foo, :session_http_only => false
    #
    #   # the session will only be disabled for 'foo', and only if it is
    #   # requested as a web service
    #   session :off, :only => :foo,
    #           :if => Proc.new { |req| req.parameters[:ws] }
    #
    #   # the session will be disabled for non html/ajax requests
    #   session :off,
    #     :if => Proc.new { |req| !(req.format.html? || req.format.js?) }
    #
    #   # turn the session back on, useful when it was turned off in the
    #   # application controller, and you need it on in another controller
    #   session :on
    #
    # All session options described for ActionController::Base.process_cgi
    # are valid arguments.
    def session(*args)
      options = args.extract_options!

      options[:disabled] = false if args.delete(:on)
      options[:disabled] = true unless args.empty?
      options[:only] = [*options[:only]].map { |o| o.to_s } if options[:only]
      options[:except] = [*options[:except]].map { |o| o.to_s } if options[:except]
      if options[:only] && options[:except]
        raise ArgumentError, "only one of either :only or :except are allowed"
      end
      
      if session_options_array
        self.session_options_array += [ options ]
      else
        self.session_options_array  = [ options ]
      end
    end

    def session_options_for(request, action)
      session_options = 
        defined?(ActionController::Base.session_options) ? 
          ActionController::Base.session_options.dup : {}

      if session_options_array.blank?
        session_options
      else
        options = session_options

        action = action.to_s
        session_options_array.each do |opts|
          next if opts[:if] && ! opts[:if].call(request)
          if opts[:only] && opts[:only].include?(action)
            options.merge!(opts)
          elsif opts[:except] && ! opts[:except].include?(action)
            options.merge!(opts)
          elsif ! opts[:only] && ! opts[:except]
            options.merge!(opts)
          end
        end
        
        options.delete(:only)
        options.delete(:except)
        options.delete(:if)
        options
      end
    end
    
  end

  module InstanceMethods
    
    def session_enabled?
      @_session != false
    end

    def session
      @_session == false ? nil : @_session ||= request.session
    end

    def reset_session
      if session_enabled?
        request.reset_session
        @_session = nil
      end
    end

    def disable_session
      @_session = false
    end

    if defined?(AbstractController::Base) # Rails 3+

      def process_with_session_off(action, *args)
        session_options = self.class.session_options_for(request, action)
        request.session_options.merge! session_options
        disable_session if session_options[:disabled]
        process_without_session_off(action, *args)
      end

    else # Rails 2.3.x

      def process_with_session_off(request, response, method = :perform_action, *args)
        action = request.parameters["action"] || :index
        session_options = self.class.session_options_for(request, action)
        request.session_options.merge! session_options
        #@_session = false if session_options[:disabled]
        process_without_session_off(request, response, method, *args)
      end

      private
      
        def assign_shortcuts_with_session_off(request, response)
          assign_shortcuts_without_session_off(request, response)
          disable_session if request.session_options[:disabled]
        end

    end
    
  end

end

require 'action_controller/base'
ActionController::Base.send :include, SessionOff