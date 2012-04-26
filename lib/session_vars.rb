# Request-persistent variables for your controllers, stored in session.
module SessionVars

  def self.included(base)
    base.send :extend, InstanceMethods
  end
  
  
  module InstanceMethods
    
    # Setups SessionVars in your controller:
    #
    #    session_vars :first, :second
    #
    # means that @first and @second are request-persistent. Dont forget to erase them with 
    #    @first = nil
    # or with 
    #     erase_session_vars
    def session_vars(*variable_names)
      send :include, ClassMethods
      send :prepend_before_filter, :restore_session_vars
      send :append_after_filter, :store_session_vars      
      define_method :session_vars do
        variable_names
      end
    end
    
  end # InstanceMethods
  
  
  module ClassMethods  
    
    def restore_session_vars
      domain = self.class.to_s
      msg= "SessionVars RESTORE (#{domain}.#{params[:action]}): "
      session[domain] ||= {}
      session_vars.each do |var|
        if session[domain][var]
          self.instance_variable_set "@#{var}".to_sym, session[domain][var]
          msg<< "#{var} "
        end          
      end
      logger.debug msg
    end

    def store_session_vars
      domain = self.class.to_s
      msg= "SessionVars STORE (#{domain}.#{params[:action]}): "
      session[domain] ||= {}
      session_vars.each do |var|
        value = self.instance_variable_get "@#{var}".to_sym
   #     if value 
        session[domain][var] = value
        self.instance_variable_set "@#{var}".to_sym, session[domain][var]
        msg<< "#{var} " if value 
  #      end                    
      end
      logger.debug msg
    end

    def erase_session_vars
      domain = self.class.to_s
      msg= "SessionVars ERASE (#{domain}.#{params[:action]}): "
      session[domain] ||= {}
      session_vars.each do |var|
        session[domain][var] = nil
        self.instance_variable_set "@#{var}", nil
        msg<< "#{var} "
      end
      logger.debug msg
    end    
    
  end # ClassMethods
  

end
