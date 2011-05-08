HotCocoa::Mappings.map bonjour_browser: NSNetServiceBrowser do

  custom_methods do
    def search_for_services type, domain = ''
      searchForServicesOfType type, inDomain: domain
    end

    def search_for_domains
      searchForBrowsableDomains
    end
  end

  delegating 'netServiceBrowser:didFindDomain:moreComing:',
             :to => 'did_find_domain',
             :parameters => ['didFindDomain', 'moreComing']
  delegating 'netServiceBrowser:didRemoveDomain:moreComing:',
             :to => 'did_remove_domain',
             :parameters => ['didRemoveDomain', 'moreComing']
  delegating 'netServiceBrowser:didFindService:moreComing:',
             :to => 'did_find_service',
             :parameters => ['didFindService', 'moreComing']
  delegating 'netServiceBrowser:didRemoveService:moreComing:',
             :to => 'did_remove_service',
             :parameters => ['didRemoveService', 'moreComing']
  delegating 'netServiceBrowserWillSearch:',
             :to => 'will_search'
  delegating 'netServiceBrowser:didNotSearch:',
             :to => 'did_not_search',
             :parameters => ['didNotSearch']
  delegating 'netServiceBrowserDidStopSearch:',
             :to => 'did_stop_search'

  ##
  # There are no values that need to be set at initialization
  def init_with_options browser, opts
    browser.init
  end

end
