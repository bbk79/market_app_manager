lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minitest/test'
require 'minitest/autorun'
require "service_manager"

class TestServiceManager < MiniTest::Test
  def setup
    @sm = ServiceManager.new 'test/test_config/'
    @all_apps_set = Set.new ["at_pq_ose_001", "at_cmp_ose_002", "at_dm_ose_003", "at_cmp_sgx_ose_001", "at_dm_sgx_001", "at_dm_sgx_002", "at_pq_hkf_001", "at_cmp_hkf_002", "at_dm_hkg_003"]
    @xose_ose_apps_set = Set.new ["at_pq_ose_001", "at_cmp_ose_002", "at_dm_ose_003", "at_cmp_sgx_ose_001"]
    @monday = Date.parse('2015-08-24')
    @saturday = Date.parse('2015-08-29')
    @sunday = Date.parse('2015-08-30')
    @commands_for_week_from_monday = @sm.commands_for_week(@monday)
  end

  def test_no_service_on_saturday
    assert_empty @sm.apps_for_day(@saturday), "No app should be running on a Saturday."
  end

  def test_no_service_on_sunday
    assert_empty @sm.apps_for_day(@sunday), "No app should be running on a Sunday."
  end

  def test_holiday_on_all_markets
    assert_empty @sm.apps_for_day(Date.parse('2015-01-01')), "No app should be running on 2015-01-01, it is defined as a holiday for ALL markets"
  end

  def test_all_services_running
    assert_equal @all_apps_set, @sm.apps_for_day(@monday), "All apps shoud be running on Monday, August 24th 2015"
  end

  def test_one_market_on_xmas_day
     assert_equal @xose_ose_apps_set, @sm.apps_for_day(Date.parse('2014-12-25')), "Only XOSE Market Apps (containing _ose_ pattern) should run on XMas day 2014"
  end

  def test_all_apps_starting_on_this_monday
    assert_equal @all_apps_set, @commands_for_week_from_monday[@monday.to_s][:starting_apps], "All apps should start on Monday, August 24th 2015"
  end

  def test_no_app_should_stop_this_monday
    assert_empty @commands_for_week_from_monday[@monday.to_s][:stopping_apps], "No app should stop on Monday, August 24th 2015"
  end

  def test_all_apps_should_stop_next_saturday
    assert_equal @all_apps_set, @commands_for_week_from_monday[@saturday.to_s][:stopping_apps], "All apps should stop on Saturday, August 29th 2015"
  end

  def test_no_app_should_stop_next_sunday
    assert_empty @commands_for_week_from_monday[@sunday.to_s][:stopping_apps], "No apps should stop on Sunday, August 30th 2015"
  end

  def test_no_app_should_start_next_saturday
    assert_empty @commands_for_week_from_monday[@saturday.to_s][:starting_apps], "No app should start on Saturday, August 29th 2015"
  end

  def test_no_app_should_start_next_sunday
    assert_empty @commands_for_week_from_monday[@sunday.to_s][:starting_apps], "No app should start on Sunday, August 30th 2015"
  end

end
