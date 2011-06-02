module ApiHelper
  require 'apic.rb'
  #########################################
  #######Matt's Validation Methods#########
  #########################################
  def valid_request_with_rescue(request, in_action = nil, prms = nil, accesstoken = nil)
    begin
      x = valid_request?(request, in_action, prms, accesstoken)
    rescue Exception => e
       x = {"error" => "#{e.message}"}
    end
    x
  end
  
  def valid_request?(request, in_action = nil, prms = nil, accesstoken = nil)
    #retrieve the API action requested so we can match the right allowed fields
    raise ApiErrors::InvalidRequest if request.try(:path_parameters).nil? && in_action.nil?
    #Next block of code primarily to enable testing
    if request.nil?
      request = Hashie::Mash.new()
      request[:path_parameters] = {:action => nil}
    end
    action = in_action.nil? ?  request.path_parameters[:action] : in_action
    param = prms.nil? ? params : prms
    
    #Handle versioning of API in Apic class
    version = param.try(:version).nil? && ( (param.try(:version).nil? ? 0 : param[:version]) <= Apic::STD_VERSION) ? Apic::STD_VERSION : param[:version]
    version = ["v", version].join
    
    #Let's check to see if the fields query parameter is set first   
    if !param[:fields].nil?
      fields = param[:fields].split(',')
      raise ApiErrors::InvalidFieldError if fields.empty?
      #Let's validate the fields that they entered into the query params
      valid_fields = valid_fields?(fields, action, version)
      if valid_fields.length == fields.length
        raise ApiErrors::IncorrectScopeError unless valid_scope?(valid_fields, action, accesstoken).length == valid_fields.length 
      else raise ApiErrors::InvalidFieldError
      end
    else
      #if no fields supplied, check the scope for the action and go
      raise ApiErrors::IncorrectScopeError if valid_scope?(["all"], action, accesstoken).empty?
      valid_fields = Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym]
    end
  valid_fields
  end
  
  def valid_fields?(fields,action,version)
    #return fields that are valid
     valid_fields = []
    if !Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym].nil?
      validator = Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym]
      valid_fields=[]
      fields.each do |field|
        valid_fields.push(field) if validator.include?(field)    #push all of the fields that match onto valid_fields array
      end
    end
    valid_fields
  end
  
  def valid_scope?(fields, action, access_token = nil)
    #return the fields that are in their allowed scope of those they requested
    access_token = Rack::OAuth2::Server.get_access_token(params[:access_token]) if access_token.nil?
    allowed_scopes = access_token.scope.to_s.split(' ')
    valid_fields_by_scope = []
    fields.each do |field|
      if Apic::SCOPE_REQUIRED[action.to_sym].has_key?(field)
        Apic::SCOPE_REQUIRED[action.to_sym][field].each do |scope|
          valid_fields_by_scope.push(field) if allowed_scopes.include?(scope)
        end
      end
    end
  valid_fields_by_scope
  end
  
  def get_users
    user_ids = []
    user_ids.push params[:id] == "me" ? oauth.identity : params[:id]
    if params[:and]
      ands = params[:and].split(',')
      ands.each do |x|
        user_ids.push x
      end
    end
    users = User.where(:userID => user_ids)
    raise ApiErrors::NoDataReturned unless users
    users
  end
  
end
