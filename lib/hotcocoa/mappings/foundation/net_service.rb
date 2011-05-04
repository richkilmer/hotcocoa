HotCocoa::Mappings.map bonjour_service: NSNetService do

  defaults domain: ''

  constant :error_keys, {
    code:   NSNetServicesErrorCode,
    domain: NSNetServicesErrorDomain
  }

  constant :error, {
    unknown:              NSNetServicesUnknownError,
    collision:            NSNetServicesCollisionError,
    not_found:            NSNetServicesNotFoundError,
    activity_in_progress: NSNetServicesActivityInProgress,
    bad_argument:         NSNetServicesBadArgumentError,
    cancelled:            NSNetServicesCancelledError,
    invalid:              NSNetServicesInvalidError,
    timeout:              NSNetServicesTimeoutError
  }

  constant :options, {
    no_auto_rename: NSNetServiceNoAutoRename
  }

  delegating 'netServiceWillPublish:',
             :to => :will_publish
  delegating 'netService:didNotPublish:',
             :to => :did_not_publish,
             :parameters => ['didNotPublish']
  delegating 'netServiceDidPublish:',
             :to => :did_publish
  delegating 'netServiceWillResolve:',
             :to => :will_resolve
  delegating 'netService:didNotResolve:',
             :to => :did_not_resolve,
             :parameters => ['didNotResolve']
  delegating 'netServiceDidResolveAddress:',
             :to => :did_resolve
  delegating 'netService:didUpdateTXTRecordData:',
             :to => :did_update_txt_record_data,
             :parameters => ['didUpdateTXTRecordData']
  delegating 'netServiceDidStop:',
             :to => :did_stop

  # @note Right now I have to specify that domain has a default
  #       argument, but the YARD plugin will have to look at the
  #       keys defined in defaults and see if the key is defined
  #       there

  # @key [String] domain specify the domain to advertise in, defaults to
  #                      an empty string which advertises in all domains
  # @key [String] type specify the type of service to advertise, such as
  #                    '_http._tcp.' for an HTTP service or '_ssh._tcp.'
  #                    for SSH; can only be set at initialization
  # @key [String] name specify the name for the service, this can be free
  #                    form but should avoid non-ascii characters; can
  #                    only be set at initialization
  # @key [Fixnum] port specify the port to advertise the service on, must
  #                    be set at initialization
  def init_with_options service, opts
    selector = 'initWithDomain:type:name:'
    args     = [ opts.delete(:domain),
                 opts.delete(:type),
                 opts.delete(:name) ]

    if opts.has_key? :port
      selector << 'port:'
      args     << opts.delete(:port)
    end

    service.send( selector, *args )
  end

end
