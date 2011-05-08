##
# @todo In this test class, there is a base set of tests
#       that each mapping should have
class TestBonjourMappings < MiniTest::Unit::TestCase
  include HotCocoa

  def test_defaults_kick_in
    b = bonjour_service type:'_http._tcp.', name:'Defaults Test'

    assert_equal '', b.domain
    assert_equal -1, b.port
  end

  def test_defaults_can_be_overridden
    b = bonjour_service type:'_http._tcp.', name:'Defaults Test',
                        domain: 'local.', port: 9090

    assert_equal 'local.', b.domain
    assert_equal 9090,     b.port
  end

  def test_delegation_publishing_success
    b = bonjour_service type:'_http._tcp.', name:'HotCocoa Test', port: 9091
    will_publish = did_publish = did_stop = false

    b.will_publish { will_publish = true }
    b.did_publish { did_publish = true }
    b.did_stop { did_stop = true }

    b.publish
    assert will_publish

    run_run_loop
    assert did_publish

    b.stop
    assert did_stop
  end

  def test_delegation_publishing_failure
    b = bonjour_service type:'fake', name:'HotCocoa Test', port: 9091

    did_not_publish = false

    b.did_not_publish { |error_dict| did_not_publish = error_dict }

    b.publish
    run_run_loop

    assert_equal NSNetServicesBadArgumentError,
      did_not_publish["NSNetServicesErrorCode"]
  end

  def test_delegating_resolving
    service = bonjour_service type:'_fake._tcp.',
                              name:'HotCocoa Test',
                              port: 9091
    service.publish
    found_service = nil

    browser = bonjour_browser
    browser.did_find_service { |new_service, more|
      found_service = new_service
    }
    browser.search_for_services '_fake._tcp.'

    run_run_loop
    refute_nil found_service
    found_service.resolve

    run_run_loop
    assert_equal 9091, found_service.port
  end

  def test_delegation_TXT_record
    skip 'TODO'
  end

end
