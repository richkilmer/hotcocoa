HotCocoa::Mappings.map :outline_view => :NSOutlineView do
  defaults :column_resize => :uniform, :frame => CGRectZero, :layout => {}

  constant :column_resize, {
    :none               => NSTableViewNoColumnAutoresizing,
    :uniform            => NSTableViewUniformColumnAutoresizingStyle,
    :sequential         => NSTableViewSequentialColumnAutoresizingStyle,
    :reverse_sequential => NSTableViewReverseSequentialColumnAutoresizingStyle,
    :last_column_only   => NSTableViewLastColumnOnlyAutoresizingStyle,
    :first_column_only  => NSTableViewFirstColumnOnlyAutoresizingStyle
  }

  def init_with_options(outline_view, options)
    outline_view.initWithFrame(options.delete(:frame))
  end

  custom_methods do
    def data=(data_source)
      data_source = HotCocoa::OutlineViewDataSource.new(data_source) if data_source.kind_of?(Array)
      setDataSource(data_source)
    end

    def columns=(columns)
      columns.each do |column|
        addTableColumn(column)
      end

      setOutlineTableColumn(columns[0]) if outlineTableColumn.nil?
    end

    def column=(column)
      addTableColumn(column)
    end

    def reload
      reloadData
    end

    def on_double_action=(behavior)
      if target && (
          target.instance_variable_get("@action_behavior") ||
            target.instance_variable_get("@double_action_behavior"))
        object.instance_variable_set("@double_action_behavior", behavior)
        object = target

      else
        object = Object.new
        object.instance_variable_set("@double_action_behavior", behavior)
        setTarget(object)
      end

      def object.perform_double_action(sender)
        @double_action_behavior.call(sender)
      end
      setDoubleAction("perform_double_action:")
    end

    def on_double_action(&behavior)
      self.on_double_action = behavior
      self
    end
  end
end
