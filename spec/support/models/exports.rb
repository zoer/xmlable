class ExportsFullyDescribed
  include XMLable::Document

  root :bill do
    attribute :date, Date

    element :l1 do
      element :l2 do
        attribute :l2a
        content :text
      end
    end

    element :s1 do
      element :s2 do
        attribute :s2a
        content :text
      end
    end

    element :text
    element :status do
      attribute :approved
    end

    element :dynamic do
      attribute :count
    end

    elements :items, tag: 'item' do
      attribute :position
      element :cost, :float
    end
  end
end

class ExportsPartiallyDescribed
  include XMLable::Document

  root :bill do
    # missing date
    #attribute :date, Date

    element :l1 do
      element :l2 do
        # missing l2a attribute
        #attribute :l2a
        content :text
      end
    end

    element :s1 do
      element :s2 do
        attribute :s2a
        content :text
      end
    end

    element :text
    element :status do
      attribute :approved
    end

    element :dynamic do
      attribute :count
    end

    elements :items, tag: 'item' do
      attribute :position
      element :cost, :float
    end
  end
end
