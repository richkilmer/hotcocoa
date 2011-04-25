class TestKernelExt < MiniTest::Unit::TestCase

  def test_original_framework_loading_semantics_are_preserved
    assert framework 'ApplicationServices'
    refute framework 'Cocoa'

    assert_raises RuntimeError do framework 'MadeUpFrameworkName' end
  end

  def test_framework_makes_proper_callback
    callback_called = false
    HotCocoa::Mappings.on_framework :Accelerate do
      callback_called = true
    end
    framework 'Accelerate'
    assert callback_called
  end

end
