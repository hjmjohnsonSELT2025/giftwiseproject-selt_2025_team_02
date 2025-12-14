
class RecipientProxy
  def initialize(snapshot)
    @snapshot = snapshot || {}
  end

  def method_missing(method_name, *args, &block)
    key = method_name.to_s
    return @snapshot[key] if @snapshot.key?(key)
    super
  end

  def respond_to_missing?(method_name, include_private = false)
    @snapshot.key?(method_name.to_s) || super
  end


  def attributes
    @snapshot
  end

  def persisted?
    false
  end
end
