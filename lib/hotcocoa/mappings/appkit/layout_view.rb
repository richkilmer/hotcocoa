HotCocoa::Mappings.map :layout_view => :"HotCocoa::LayoutView" do
  defaults :frame => CGRectZero, :layout => {}

  def init_with_options(view, options)
    view.initWithFrame options.delete(:frame)
  end
end
