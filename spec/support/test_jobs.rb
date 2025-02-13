class DefaultJob
  @queue = :default

  def self.perform
    # do something
  end
end

class FailJob
  @queue = :default

  def self.perform
    raise "I'm a failure"
  end
end
