require File.expand_path('../../test_helper.rb', __FILE__)
require 'couch_rest/changes'

class CouchChangesTest < MiniTest::Unit::TestCase

  LAST_SEQ = 12

  def setup
    @stream = mock()
    @changes = CouchRest::Changes.new(@stream)
  end

  def test_last_seq
    @stream.expects(:get).
      with('_changes', {:limit => 1, :descending => true}).
      yields(:last_seq => LAST_SEQ)
    assert_equal LAST_SEQ, @changes.last_seq
  end

  def test_follow
    stub_entry = {:new => :result}
    @stream.expects(:get).
      with('_changes', {:limit => 1, :descending => true}).
      yields(:last_seq => LAST_SEQ)
    @stream.expects(:get).
      with('_changes', {:feed => :continuous, :since => LAST_SEQ}).
      yields(stub_entry)
    @changes.follow do |hash|
      assert_equal stub_entry, hash
    end
  end
end
