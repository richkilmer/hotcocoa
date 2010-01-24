module HotCocoa
  class OutlineViewDataSource
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def outlineView(view, numberOfChildrenOfItem:item)
      if item.nil?
        data.length
      else
        item[:childRows].length
      end
    end

    def outlineView(view, isItemExpandable:item)
      item.has_key?(:childRows) && item[:childRows].length > 0
    end

    def outlineView(view, child:child, ofItem:item)
      if item.nil?
        data[child]
      else
        item[:childRows][child]
      end
    end

    def outlineView(view, objectValueForTableColumn:column, byItem:item)
      item[column.identifier.intern]
    end
  end
end