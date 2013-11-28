module Click
  class Clicker
    def click!
      observers.each { |o| o.before_click(self) }

      ObjectSpace.garbage_collect

      @state = Hash.new(0)
      ObjectSpace.each_object do |object|
        @state[object.class] += 1
      end

      @state[Symbol] = Symbol.all_symbols.count

      observers.each { |o| o.after_click(self) }
    end

    def instance_count(klass)
      @state.fetch(klass, 0)
    end

    def add_observer(observer)
      observers << observer
    end

    private
    def observers
      @observers ||= []
    end
  end
end
